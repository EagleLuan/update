function plot_formation_results(log, par)


T_exec   = log.t(:).';
T_plan   = log.t(:).';
N_agents = par.N;
A_d      = par.A_d;
n0       = par.n0;
d        = par.d;
alpha    = par.alpha_ph;

z_plan = cell(N_agents, 1);
z_all  = zeros(numel(T_plan), 3, N_agents);
for i = 1:N_agents
    zi = zeros(3, numel(T_plan));
    for k = 1:numel(T_plan)
        zi(:, k) = log.eta(:, i, k) ...
            + q_star_func(T_plan(k), i, par.omega_pco, ...
            par.d, par.alpha_ph);
    end
    z_plan{i} = zi.';                           
    z_all(:, :, i) = z_plan{i};
end

q_all = zeros(numel(T_exec), 3, N_agents);
for i = 1:N_agents
    q_all(:, :, i) = squeeze(log.x(1:3, i, :)).';  
end

z_ave = mean(q_all, 3);                                 


figure('Name', 'Planning Layer: Formation Vector Tracking', ...
       'Position', [60 60 1000 700]);
z_desired = zeros(numel(T_plan), 3, N_agents);
for k = 1:numel(T_plan)
    zd = z_d_func(T_plan(k), A_d, n0);                   
    for i = 1:N_agents
        qs = q_star_func(T_plan(k), i, par.omega_pco, d, alpha);
        z_desired(k, :, i) = (zd + qs).';
    end
end
for coord = 1:3
    subplot(3, 1, coord); hold on; grid on;
    for i = 1:N_agents
        plot(T_plan, z_plan{i}(:, coord));
        plot(T_plan, z_desired(:, coord, i), '--k');
    end
    ylabel(['Coordinate ' num2str(coord)]);
end
xlabel('Time (s)');
sgtitle('Planning Layer: Formation Vector (solid) vs Desired (dashed)');


figure('Name', 'Average Formation Vector Tracking', ...
       'Position', [80 80 1000 700]);
z_ave_plan = mean(z_all, 3);                            
zd_t = zeros(numel(T_plan), 3);
for k = 1:numel(T_plan)
    zd_t(k, :) = z_d_func(T_plan(k), A_d, n0).';
end
for coord = 1:3
    subplot(3, 1, coord); hold on; grid on;
    plot(T_plan, z_ave_plan(:, coord), 'b', 'LineWidth', 1.5);
    plot(T_plan, zd_t(:, coord),      'r--', 'LineWidth', 1.5);
    ylabel(['Coordinate ' num2str(coord)]);
end
xlabel('Time (s)');
legend('z_{ave}^{plan}', 'z_d', 'Location', 'best');
sgtitle('Planning Layer: Average Formation Vector Tracking');


figure('Name', 'Execution Layer: Spacecraft Positions', ...
       'Position', [100 100 1000 700]);
for coord = 1:3
    subplot(3, 1, coord); hold on; grid on;
    for i = 1:N_agents
        z_ref_i = z_plan{i};
        plot(T_exec, q_all(:, coord, i));
        plot(T_exec, z_ref_i(:, coord), '--k');
    end
    ylabel(['Coordinate ' num2str(coord)]);
end
xlabel('Time (s)');
sgtitle('Execution Layer: Spacecraft Positions (solid) vs Planned Reference (dashed)');

figure('Name', '3D Formation Trajectory', ...
       'Position', [120 120 800 700]);
hold on; grid on; axis equal;
colors = lines(N_agents);
plot3(zd_t(:, 1), zd_t(:, 2), zd_t(:, 3), 'k--', 'LineWidth', 2);
plot3(z_ave(:, 1), z_ave(:, 2), z_ave(:, 3), 'r-', 'LineWidth', 2);
for i = 1:N_agents
    plot3(q_all(:, 1, i), q_all(:, 2, i), q_all(:, 3, i), ...
          'Color', colors(i, :), 'LineWidth', 1.5);
end
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('3D Formation Trajectory');
legend_str = [{'Desired Center', 'Actual Center'}, ...
              arrayfun(@(i) sprintf('Spacecraft %d', i), ...
                       1:N_agents, 'UniformOutput', false)];
legend(legend_str, 'Location', 'best');
view(45, 30);

figure('Name', 'Animation', 'Position', [140 140 800 700]);
hold on; grid on; axis equal;
plot3(0, 0, 0, 'ko', 'MarkerSize', 10);
plot3(zd_t(:, 1), zd_t(:, 2), zd_t(:, 3), 'k--', 'LineWidth', 1.5);
h_center = plot3(nan, nan, nan, 'r.', 'MarkerSize', 20);
h_agents = gobjects(N_agents, 1);
for i = 1:N_agents
    h_agents(i) = plot3(nan, nan, nan, 'o', ...
        'Color', colors(i, :), ...
        'MarkerFaceColor', colors(i, :), 'MarkerSize', 6);
end
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Formation Animation'); view(45, 30);

step = max(1, round(numel(T_exec) / 500));   % 500 frames max
for k = 1:step:numel(T_exec)
    set(h_center, 'XData', z_ave(k, 1), ...
                  'YData', z_ave(k, 2), ...
                  'ZData', z_ave(k, 3));
    for i = 1:N_agents
        set(h_agents(i), 'XData', q_all(k, 1, i), ...
                         'YData', q_all(k, 2, i), ...
                         'ZData', q_all(k, 3, i));
    end
    drawnow;
end
end