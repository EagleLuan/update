clear; clc; close all;

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'nn_forward'));
addpath(fullfile(here, 'helper'));

% ---- Load trained network ----
mat_path = fullfile(here, '..', 'data', 'trained_params.mat');
if ~isfile(mat_path)
    error(['Trained parameters not found: %s\n' ...
           'Please run:  cd python && python train.py'], mat_path);
end
P = load(mat_path);
fprintf('Loaded network parameters from %s\n', mat_path);

par = setup_parameters();

X = init_state(par);

dt    = 0.05;
T_end = 0.03*2 * pi / par.n0;    
t     = 0:dt:T_end;

log = struct();
log.t   = t;
log.x   = zeros(6, par.N, numel(t));
log.eta = zeros(3, par.N, numel(t));
log.u   = zeros(3, par.N, numel(t));
log.x(:, :, 1)   = X.plant;
log.eta(:, :, 1) = X.eta;

fprintf('Simulating %d agents for %.1f s (dt=%.3f)\n', ...
        par.N, T_end, dt);

% ---- Main loop ----
for it = 1:numel(t)-1
    tk = t(it);
    
    % ---- planning layer ----
    [X, u_s_net] = formation_layer_step(X, par, tk, dt);

    % ---- plant reference state ----
    x_star     = zeros(6, par.N);
    x_dot_star = zeros(6, par.N);
    for i = 1:par.N
        qi_star = X.eta(:, i) + q_star_func(tk, i, par.omega_pco, par.d, par.alpha_ph);
        pi_star = X.s(:, i)   + q_star_vel_func(tk, i, par.omega_pco, par.d, par.alpha_ph);
        x_star(:, i) = [qi_star; pi_star];
    

        dt_num = 1e-6;
        qi_star_n = X.eta(:, i) + q_star_func(tk + dt_num, i, par.omega_pco, par.d, par.alpha_ph);
        pi_star_n = X.s(:, i)   + q_star_vel_func(tk + dt_num, i, par.omega_pco, par.d, par.alpha_ph);
        x_star_n = [qi_star_n; pi_star_n];
        x_dot_star(:, i) = (x_star_n - x_star(:, i)) / dt_num;
    end

    % ---- plant control ----
    u_plant = zeros(3, par.N);
    for i = 1:par.N
        u_plant(:, i) = neural_ida_pbc(X.plant(:, i), x_star(:, i), ...
                                       x_dot_star(:, i), P, par);
    end

    % ---- plant dynamics (forward Euler) ----
    for i = 1:par.N
        dxi = plant_dynamics(X.plant(:, i), u_plant(:, i), par);
        X.plant(:, i) = X.plant(:, i) + dt * dxi;
    end

    log.x(:, :, it+1)   = X.plant;
    log.eta(:, :, it+1) = X.eta;
    log.u(:, :, it+1)   = u_plant;

    if mod(it, 200) == 0
        e = X.plant(:,1) - x_star(:,1);
        Rd = ltn_eval(X.plant(:,1), P);
        [~, gHd] = icnn_grad(e, P);
        d = gHd / (norm(gHd) + 1e-12);
        eps_h = 1e-4;
        [~, gHd_p] = icnn_grad(e + eps_h*d, P);
        [~, gHd_m] = icnn_grad(e - eps_h*d, P);
        Hd_hess = norm(gHd_p - gHd_m) / (2*eps_h);
        fprintf('t=%.1f  |e|=%.2e  lam_max(Rd)=%.2e  |∇Hd|=%.2e  |∇²Hd·d|=%.2e  lam_max(Rd·∇²Hd)=%.2e\n', ...
            tk, norm(e), max(eig(Rd)), norm(gHd), Hd_hess, max(eig(Rd))*Hd_hess);
    end
end

plot_formation_results(log, par);
fprintf('Simulation done.\n');

