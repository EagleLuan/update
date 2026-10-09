function [H, gH] = icnn_grad(e, P)
e = e(:);
D = numel(e);

pre = P.icnn_A1_W * e + P.icnn_A1_b(:) + P.icnn_b1(:);
z   = softplus_local(pre);
s1  = sigmoid_local(pre);
dz  = diag(s1) * P.icnn_A1_W;   

n_hidden = P.icnn_n_hidden;
for i = 2:n_hidden
    Ai_W = P.(sprintf('icnn_A%d_W', i));
    Ai_b = P.(sprintf('icnn_A%d_b', i));
    Wi   = P.(sprintf('icnn_W%d',   i));
    bi   = P.(sprintf('icnn_b%d',   i));
    Wpos = softplus_local(Wi);
    pre  = Wpos * z + Ai_W * e + Ai_b(:) + bi(:);
    z    = softplus_local(pre);
    s    = sigmoid_local(pre);
    dz   = diag(s) * (Wpos * dz + Ai_W);
end

out = P.icnn_w_out(:).' * z + P.icnn_b_out;
H   = softplus_local(out) + 0.5 * P.icnn_eps * (e.' * e);

dout_de = P.icnn_w_out(:).' * dz;
dH_de   = sigmoid_local(out) * dout_de + P.icnn_eps * e.';
gH = dH_de(:);

end

function y = softplus_local(x)
y = log(1 + exp(-abs(x))) + max(x, 0);
end

function y = sigmoid_local(x)
y = 1 ./ (1 + exp(-x));
end
