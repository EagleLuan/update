function qdot = q_star_vel_func(t, i, omega, d, alpha)
a = alpha(i);
qdot = [ -(d/2)*omega * sin(omega*t + a);
         -d*omega       * cos(omega*t + a);
         -d*omega       * sin(omega*t + a + pi/2) ];
end