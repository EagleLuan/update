function y = inn_forward(x, P)
half     = P.inn_half;
n_layers = P.inn_n_layers;

y = x;
for li = 0:n_layers-1
    y1 = y(1:half);
    y2 = y(half+1:end);

    f = mlp_forward(y2, P, sprintf('inn_L%d_f', li));
    y1_new = y1 + f;

    g = mlp_forward(y1_new, P, sprintf('inn_L%d_g', li));
    y2_new = y2 + g;

    y = [y1_new; y2_new];
end
end
