function gH = plant_gradH(x, par)
q = x(1:3);
p = x(4:6);
gH = [ par.n0^2 * q; p ];
end
