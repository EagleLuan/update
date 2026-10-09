function x = inn_inverse(y, P)
half     = P.inn_half;
n_layers = P.inn_n_layers;

for li = n_layers-1:-1:0
    y1 = y(1:half);
    y2 = y(half+1:end);

    g  = mlp_forward(y1, P, sprintf('inn_L%d_g', li));
    x2 = y2 - g;

    f  = mlp_forward(x2, P, sprintf('inn_L%d_f', li));
    x1 = y1 - f;

    y = [x1; x2];
end
x = y;
end
