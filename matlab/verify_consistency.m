clear; clc;

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, 'nn_forward'));

mat_path    = fullfile(here, '..', 'data', 'trained_params.mat');
golden_path = fullfile(here, '..', 'data', 'golden.mat');
assert(isfile(mat_path),    'Run python/train.py first (missing %s).', mat_path);
assert(isfile(golden_path), 'Run python/train.py first (missing %s).', golden_path);

P = load(mat_path);
G = load(golden_path);

x_test   = G.x_test;           % (n x 6)
H_d_ref  = G.H_d_test(:);      % (n x 1)
gH_d_ref = G.gH_d_test;        % (n x 6)
J_d_ref  = G.J_d_test;         % (n x 6 x 6)
R_d_ref  = G.R_d_test;         % (n x 6 x 6)

n = size(x_test, 1);

H_d_mat  = zeros(n, 1);
gH_d_mat = zeros(n, 6);
J_d_mat  = zeros(n, 6, 6);
R_d_mat  = zeros(n, 6, 6);
phi_mat  = zeros(n, 6);

for i = 1:n
    x = x_test(i, :).';

    [Hi, gHi]      = icnn_grad(x, P);
    H_d_mat(i)     = Hi;
    gH_d_mat(i, :) = gHi.';

    l      = inn_inverse(x, P);
    Jphi   = inn_jacobian(l, P);
    J_d_mat(i, :, :) = Jphi * P.B_matrix * Jphi.';

    R_d_mat(i, :, :) = ltn_eval(x, P);

    phi_mat(i, :) = inn_forward(l, P).';
end

fprintf('--- Consistency check ---\n');
fprintf('H_d          : max err = %.3e\n', max(abs(H_d_mat - H_d_ref)));
fprintf('grad H_d     : max err = %.3e\n', max(abs(gH_d_mat(:) - gH_d_ref(:))));
fprintf('J_d          : max err = %.3e\n', max(abs(J_d_mat(:) - J_d_ref(:))));
fprintf('R_d          : max err = %.3e\n', max(abs(R_d_mat(:) - R_d_ref(:))));
fprintf('Phi o Phi^-1 : max err = %.3e\n', max(abs(phi_mat(:) - x_test(:))));

tol = 1e-6;
ok = max(abs(H_d_mat(:)  - H_d_ref(:))) < tol && ...
     max(abs(gH_d_mat(:) - gH_d_ref(:))) < tol && ...
     max(abs(J_d_mat(:)  - J_d_ref(:))) < tol && ...
     max(abs(R_d_mat(:)  - R_d_ref(:))) < tol && ...
     max(abs(phi_mat(:)  - x_test(:))) < tol;

if ok
    fprintf('PASS  (all errors < %.1e)\n', tol);
else
    fprintf('FAIL  (some errors exceed %.1e)\n', tol);
end
