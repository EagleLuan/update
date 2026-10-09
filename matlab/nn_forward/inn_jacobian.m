function Jphi = inn_jacobian(x, P)
half     = P.inn_half;
n_layers = P.inn_n_layers;
D        = numel(x);

J = eye(D);
y = x;
for li = 0:n_layers-1
    y1 = y(1:half);
    y2 = y(half+1:end);

    [f,  Jf] = mlp_grad(y2,     P, sprintf('inn_L%d_f', li));
    y1_new   = y1 + f;

    [g,  Jg] = mlp_grad(y1_new, P, sprintf('inn_L%d_g', li));
    y2_new   = y2 + g;

    J_local = [ eye(half),   Jf;
                Jg,          eye(half) + Jg * Jf ];

    J = J_local * J;
    y = [y1_new; y2_new];
end
Jphi = J;
end
