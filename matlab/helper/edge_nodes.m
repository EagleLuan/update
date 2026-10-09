function [i, j] = edge_nodes(B, k)
col = B(:, k);
i = find(col > 0, 1);
j = find(col < 0, 1);
end
