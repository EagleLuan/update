function q = q_star_func(t, i, omega, d, alpha)
a = alpha(i);
q = [ (d/2) * cos(omega * t + a);
     -d      * sin(omega * t + a);
      d      * cos(omega * t + a + pi/2) ];
end