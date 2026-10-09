function [y, J] = mlp_grad(x, P, prefix)
y = x;
J = eye(numel(x));
n = 0;
while isfield(P, sprintf('%s_W%d', prefix, n + 1))
    W = P.(sprintf('%s_W%d', prefix, n));
    b = P.(sprintf('%s_b%d', prefix, n));
    z = W * y + b(:);
    y_new = tanh(z);
    J = diag(1 - y_new .^ 2) * W * J;
    y = y_new;
    n = n + 1;
end
W = P.(sprintf('%s_W%d', prefix, n));
b = P.(sprintf('%s_b%d', prefix, n));
J = W * J;
y = W * y + b(:);
end
