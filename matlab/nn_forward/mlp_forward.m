function y = mlp_forward(x, P, prefix)
y = x;
n = 0;
while isfield(P, sprintf('%s_W%d', prefix, n + 1))
    W = P.(sprintf('%s_W%d', prefix, n));
    b = P.(sprintf('%s_b%d', prefix, n));
    y = tanh(W * y + b(:));
    n = n + 1;
end
W = P.(sprintf('%s_W%d', prefix, n));
b = P.(sprintf('%s_b%d', prefix, n));
y = W * y + b(:);
end
