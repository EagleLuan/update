function [X, u_s_net] = formation_layer_step(X, par, t, dt)

N  = par.N;
nz = par.nz;
E  = par.E;

F_s = zeros(nz, E);
for k = 1:E
    zeta = X.zeta(:, k);
    xi   = X.xi(:, k);
    gz   = par.gamma0 * zeta + par.gamma1 * (zeta - xi);
    gx   = par.gamma1 * (xi - zeta) + par.alpha_spring * xi;
    F_s(:, k) = gz;
    dxi = (par.Jxi - par.Rxi) * gx;
    X.xi(:, k) = X.xi(:, k) + dt * dxi;
end

gz_ref = par.gamma0 * X.zeta_ref + par.gamma1 * (X.zeta_ref - X.xi_ref);
gx_ref = par.gamma1 * (X.xi_ref - X.zeta_ref) + par.alpha_spring * X.xi_ref;
F_ref = gz_ref;
dxi_ref = (par.Jxi - par.Rxi) * gx_ref;
X.xi_ref = X.xi_ref + dt * dxi_ref;

B_bar = zeros(N + 1, E + 1);
B_bar(2:N+1, 1:E) = par.B_inc;
B_bar(2, E+1)     =  1;
B_bar(1, E+1)     = -1;

F_all = [F_s, F_ref];      
u_all = -(kron(B_bar, eye(nz))) * F_all(:);
u_all = reshape(u_all, nz, N + 1);
u_s_net = u_all(:, 2:end);  

for i = 1:N
    ds = -par.Rs * X.s(:, i) + u_s_net(:, i);
    X.s(:, i)   = X.s(:, i)   + dt * ds;
    X.eta(:, i) = X.eta(:, i) + dt * X.s(:, i);
end

for k = 1:E
    [i, j] = edge_nodes(par.B_inc, k);
    v_k = X.s(:, i) - X.s(:, j);
    X.zeta(:, k) = X.zeta(:, k) + dt * v_k;
end

v_ref = X.s(:, 1) - desired_center_vel(t, par);
X.zeta_ref = X.zeta_ref + dt * v_ref;
end
