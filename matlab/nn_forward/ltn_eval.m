function R = ltn_eval(x, P)

dim   = P.rd_dim;
half  = P.rd_half;
c_min = P.rd_c_min;
c_max = P.rd_c_max;

y = x;
n = 0;
while isfield(P, sprintf('rd_W%d', n + 1))
    W = P.(sprintf('rd_W%d', n));
    b = P.(sprintf('rd_b%d', n));
    y = tanh(W * y + b(:));
    n = n + 1;
end
W = P.(sprintf('rd_W%d', n));
b = P.(sprintf('rd_b%d', n));
y = W * y + b(:);

c = c_min + (c_max - c_min) / (1 + exp(-y(1)));

R = zeros(dim, dim);
for i = 1:half
    R(half + i, half + i) = c;
end
end