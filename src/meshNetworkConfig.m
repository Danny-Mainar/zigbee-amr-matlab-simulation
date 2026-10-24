function [nodes, collector, adjMatrix] = meshNetworkConfig(numNodes, areaSize)
    % MESHNETWORKCONFIG Creates random node positions and calculates connectivity
    % Input: numNodes = number of meter nodes (e.g., 20)
    %        areaSize = simulation area in meters (e.g., 200)
    % Output: nodes = [x, y, nodeId, battery, parent]
    %         collector = [x, y] position of collector
    %         adjMatrix = connectivity matrix (who can hear whom)
    
    fprintf('\n=== CREATING MESH NETWORK ===\n');
    
    % Collector at corner or center
    collector = [areaSize/2, areaSize/2];  % Center
    % collector = [0, 0];  % Corner option
    
    % Random node positions
    nodes = zeros(numNodes, 5);  % [x, y, id, battery%, parentId]
    for i = 1:numNodes
        nodes(i,1) = rand() * areaSize;
        nodes(i,2) = rand() * areaSize;
        nodes(i,3) = i;           % Node ID
        nodes(i,4) = 100;         % Battery percentage
        nodes(i,5) = -1;          % Parent (-1 = no parent yet)
    end
    
    % Calculate connectivity based on distance
    maxRange = 50;  % ZigBee typical range in meters
    adjMatrix = zeros(numNodes, numNodes);
    
    % Check node-to-node connectivity
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                dist = sqrt((nodes(i,1)-nodes(j,1))^2 + (nodes(i,2)-nodes(j,2))^2);
                if dist <= maxRange
                    adjMatrix(i,j) = 1;  % Can hear each other
                end
            end
        end
    end
    
    % Check collector-to-node connectivity
    collectorAdj = zeros(numNodes, 1);
    for i = 1:numNodes
        distToCollector = sqrt((nodes(i,1)-collector(1))^2 + (nodes(i,2)-collector(2))^2);
        if distToCollector <= maxRange
            collectorAdj(i) = 1;  % Node can reach collector directly
        end
    end
    
    fprintf('Network created:\n');
    fprintf('  Nodes: %d\n', numNodes);
    fprintf('  Area: %dx%d m\n', areaSize, areaSize);
    fprintf('  Max range: %d m\n', maxRange);
    fprintf('  Direct collector connections: %d/%d\n', sum(collectorAdj), numNodes);
    
    % Visualize
    figure('Name', 'Mesh Network Topology', 'Position', [100, 100, 800, 600]);
    plot(collector(1), collector(2), 'r^', 'MarkerSize', 15, 'LineWidth', 2);
    hold on;
    
    % Draw connections
    for i = 1:numNodes
        for j = i+1:numNodes
            if adjMatrix(i,j) == 1
                plot([nodes(i,1) nodes(j,1)], [nodes(i,2) nodes(j,2)], 'k:', 'LineWidth', 0.5);
            end
        end
    end
    
    % Draw nodes
    for i = 1:numNodes
        if collectorAdj(i) == 1
            plot(nodes(i,1), nodes(i,2), 'go', 'MarkerSize', 8, 'LineWidth', 1.5);
        else
            plot(nodes(i,1), nodes(i,2), 'bo', 'MarkerSize', 8);
        end
        text(nodes(i,1)+2, nodes(i,2)+2, num2str(i), 'FontSize', 8);
    end
    
    title('ZigBee AMR Mesh Network Topology', 'FontSize', 14);
    xlabel('X Position (m)'); ylabel('Y Position (m)');
    legend('Collector', 'Direct connection', 'Multi-hop needed', 'Location', 'best');
    grid on;
    saveas(gcf, 'presentation_figures/figures/mesh_topology.png');
    
    fprintf('✓ Topology figure saved\n');
end