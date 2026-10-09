function z = desired_center(t, par)
n0 = par.n0; A = par.A_d;
z = [ A*cos(n0*t); -2*A*sin(n0*t); 0 ];
end
