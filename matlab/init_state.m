function X = init_state(par)
rng(42);   

X.plant = zeros(6, par.N);
X.eta   = zeros(3, par.N);
X.s     = zeros(3, par.N);

z_d_0 = desired_center(0, par);       

R_plant_init = 50;    
R_eta_init   = 20;    
sigma_v      = 0.05;  

for i = 1:par.N
    qi_star_0 = q_star_func(0, i, par.omega_pco, par.d, par.alpha_ph);
    X.plant(1:3, i) = z_d_0 + qi_star_0 + R_plant_init * (2*rand(3,1) - 1);
    X.plant(4:6, i) = sigma_v          * (2*rand(3,1) - 1);

    X.eta(:, i) = z_d_0 + R_eta_init * (2*rand(3,1) - 1);
    X.s(:, i)   = sigma_v * (2*rand(3,1) - 1);
end

X.zeta = zeros(3, par.E);
X.xi   = zeros(3, par.E);
for k = 1:par.E
    [i, j] = edge_nodes(par.B_inc, k);
    X.zeta(:, k) = X.eta(:, i) - X.eta(:, j);
    X.xi(:, k)   = X.zeta(:, k);      
end

X.zeta_ref = X.eta(:, 1) - z_d_0;
X.xi_ref   = X.zeta_ref;           
end