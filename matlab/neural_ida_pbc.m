function u = neural_ida_pbc(x, x_star, x_dot_star, P, par)

e = x - x_star;


[~, gHd] = icnn_grad(e, P);

l    = inn_inverse(x, P);
Jphi = inn_jacobian(l, P);
Jd   = Jphi * P.B_matrix * Jphi.';

Rd = ltn_eval(x, P);


Jp  = [zeros(3), eye(3); -eye(3), zeros(3)];
Rp  = zeros(6, 6);
gHp = plant_gradH(x, par);

res = (Jd - Rd) * gHd - (Jp - Rp) * gHp + x_dot_star;

u = res(4:6);
end
