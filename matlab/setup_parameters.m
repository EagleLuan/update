function par = setup_parameters()

par.mu = 3.986004418e14;
par.Re = 6378.137e3;
par.J2 = 1.08262668e-3;
par.r0 = 6978.137e3;
par.n0 = 1.083e-3;         
par.omega_pco = 10 * par.n0;
par.N  = 4;               
par.nz = 3;                


par.A_d = 200;            
par.d   = 30;           
par.alpha_ph = 2*pi*(0:par.N-1)/par.N;
par.zbar = zeros(3, par.N);
for i = 1:par.N
    a = par.alpha_ph(i);
    par.zbar(:, i) = [ (par.d/2)*cos(a);
                       -par.d*sin(a);
                        par.d*cos(a + pi/2) ];
end

par.B_inc = [-1  0  0  1;
              1 -1  0  0;
              0  1 -1  0;
              0  0  1 -1];
par.E = size(par.B_inc, 2);

par.Rs          = 2.0 * eye(3);
par.gamma0      = 1.0;
par.gamma1      = 0.5;
par.alpha_spring = 0.3;
par.Rxi         = 5.0 * eye(3);
par.Jxi         = 0.005 * [ 0 -1  0;
                            1  0  0;
                            0  0  0];
end
