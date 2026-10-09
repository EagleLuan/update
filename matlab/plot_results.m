function plot_results(log, par)
t = log.t;

figure('Name', 'Formation', 'Position', [100 100 900 650]);

subplot(2, 2, [1 3]);
hold on; grid on; box on;
colors = lines(par.N);
for i = 1:par.N
    xi = squeeze(log.x(:, i, :)).';
    plot3(xi(:, 1), xi(:, 2), xi(:, 3), ...
          'Color', colors(i, :), 'LineWidth', 1.5);
end
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Agent trajectories in Hill frame');
view(45, 20);

subplot(2, 2, 2);
hold on; grid on; box on;
for i = 1:par.N
    plot(t, squeeze(log.eta(1, i, :)), 'Color', colors(i, :));
end
xlabel('t (s)'); ylabel('\eta_x (m)');
title('Formation-center estimate \eta_x');

subplot(2, 2, 4);
hold on; grid on; box on;
eta_mean = mean(log.eta, 2);
for i = 1:par.N
    err = squeeze(log.eta(:, i, :) - eta_mean(:, 1, :));
    plot(t, vecnorm(err, 2, 1), 'Color', colors(i, :));
end
xlabel('t (s)'); ylabel('||\eta_i - \eta_{ave}||');
title('Consensus error');
end
