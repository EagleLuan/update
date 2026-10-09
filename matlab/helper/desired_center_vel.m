function z = desired_center_vel(t, par)
n0 = par.n0; A = par.A_d;
z = [ -A*n0*sin(n0*t); -2*A*n0*cos(n0*t); 0 ];
end
