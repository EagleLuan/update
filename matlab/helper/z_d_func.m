function z = z_d_func(t, A_d, n0)
z = [ A_d * cos(n0 * t);
     -2 * A_d * sin(n0 * t);
      0 ];
end