function dx = plant_dynamics(x, u, par)
gH = plant_gradH(x, par);
J  = [zeros(3), eye(3); -eye(3), zeros(3)];
R  = zeros(6, 6);
g  = [zeros(3); eye(3)];
dx = (J - R) * gH + g * u;
end
