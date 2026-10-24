function [routes, metrics] = aodvRouting(numNodes, nodePositions, source, destination)
    % AODV ROUTING PROTOCOL IMPLEMENTATION
    % Inputs:
    %   numNodes      - Number of nodes in network
    %   nodePositions - N x 2 matrix of (x,y) coordinates
    %   source        - Source node ID (1 to numNodes)
    %   destination   - Destination node ID (1 to numNodes)
    % Outputs:
    %   routes        - Cell array containing routes
    %   metrics       - Structure with latency, energy, hop count
    
    fprintf('\n=== AODV ROUTE DISCOVERY ===\n');
    
    % Communication range (meters)
    range = 50;
    
    % Step 1: Calculate distance matrix
    distances = zeros(numNodes);
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                dx = nodePositions(i,1) - nodePositions(j,1);
                dy = nodePositions(i,2) - nodePositions(j,2);
                distances(i,j) = sqrt(dx^2 + dy^2);
            else
                distances(i,j) = inf;
            end
        end
    end
    
    % Step 2: Build neighbor matrix (nodes within range)
    neighborMatrix = distances <= range;
    
    % Step 3: AODV Route Discovery (Dijkstra's algorithm for shortest path)
    numHops = inf(numNodes, 1);
    prevNode = zeros(numNodes, 1);
    visited = false(numNodes, 1);
    
    numHops(source) = 0;
    
    for iter = 1:numNodes
        % Find unvisited node with minimum hop count
        minHops = inf;
        currentNode = -1;
        for i = 1:numNodes
            if ~visited(i) && numHops(i) < minHops
                minHops = numHops(i);
                currentNode = i;
            end
        end
        
        if currentNode == -1 || currentNode == destination
            break;
        end
        
        visited(currentNode) = true;
        
        % Update neighbors
        for neighbor = 1:numNodes
            if neighborMatrix(currentNode, neighbor) && ~visited(neighbor)
                if numHops(currentNode) + 1 < numHops(neighbor)
                    numHops(neighbor) = numHops(currentNode) + 1;
                    prevNode(neighbor) = currentNode;
                end
            end
        end
    end
    
    % Step 4: Extract route from source to destination
    route = [];
    if numHops(destination) < inf
        currentNode = destination;
        while currentNode ~= 0
            route = [currentNode, route];
            currentNode = prevNode(currentNode);
            if currentNode == source
                route = [source, route];
                break;
            end
        end
    else
        fprintf('⚠ No route found from Node %d to Node %d\n', source, destination);
        routes = {};
        metrics.hops = inf;
        metrics.latency_ms = inf;
        metrics.energy_mJ = inf;
        return;
    end
    
    % Step 5: Calculate metrics
    hopCount = length(route) - 1;
    latency_per_hop_ms = 4.6;  % Based on ZigBee standard
    latency_ms = hopCount * latency_per_hop_ms;
    energy_per_hop_mJ = 0.16;
    energy_mJ = hopCount * energy_per_hop_mJ;
    
    % Step 6: Display results
    fprintf('\nRoute from Node %d to Node %d:\n', source, destination);
    fprintf('  Path: ');
    for i = 1:length(route)
        fprintf('%d', route(i));
        if i < length(route), fprintf(' → '); end
    end
    fprintf('\n');
    fprintf('  Hop count: %d\n', hopCount);
    fprintf('  Latency: %.1f ms\n', latency_ms);
    fprintf('  Energy: %.2f mJ\n', energy_mJ);
    
    % Step 7: Display routing table
    fprintf('\nRouting Table (from Node %d perspective):\n', source);
    fprintf('  Destination\tNext Hop\tHops\tLatency(ms)\n');
    for dest = 1:numNodes
        if dest ~= source && numHops(dest) < inf
            % Find next hop
            nextHop = dest;
            while prevNode(nextHop) ~= source && prevNode(nextHop) ~= 0
                nextHop = prevNode(nextHop);
            end
            if prevNode(nextHop) == source
                nextHop = nextHop;
            else
                nextHop = dest;
            end
            fprintf('  %d\t\t%d\t\t%d\t%.1f\n', dest, nextHop, numHops(dest), numHops(dest)*latency_per_hop_ms);
        end
    end
    
    % Step 8: Simple topology visualization (optional, skip if error)
    try
        figure(8);
        clf;
        hold on;
        
        % Plot all nodes
        for i = 1:numNodes
            if i == source
                plot(nodePositions(i,1), nodePositions(i,2), 'gs', 'MarkerSize', 12, 'MarkerFaceColor', 'g');
            elseif i == destination
                plot(nodePositions(i,1), nodePositions(i,2), 'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
            else
                plot(nodePositions(i,1), nodePositions(i,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
            end
        end
        
        % Plot edges (communication links)
        for i = 1:numNodes
            for j = i+1:numNodes
                if neighborMatrix(i,j)
                    plot([nodePositions(i,1), nodePositions(j,1)], ...
                         [nodePositions(i,2), nodePositions(j,2)], 'k-', 'LineWidth', 0.5);
                end
            end
        end
        
        % Highlight the route
        for i = 1:length(route)-1
            plot([nodePositions(route(i),1), nodePositions(route(i+1),1)], ...
                 [nodePositions(route(i),2), nodePositions(route(i+1),2)], 'r-', 'LineWidth', 3);
        end
        
        xlabel('X position (m)');
        ylabel('Y position (m)');
        title(sprintf('AODV Route: Node %d → Node %d (%d hops, %.1f ms)', source, destination, hopCount, latency_ms));
        legend('Source', 'Destination', 'Meter', 'Location', 'best');
        grid on;
        axis equal;
        saveas(gcf, 'presentation_figures/figures/aodv_route.png');
        fprintf('\n✓ Route visualization saved\n');
    catch ME
        fprintf('\n⚠ Visualization skipped: %s\n', ME.message);
    end
    
    % Package outputs
    routes{1} = route;
    metrics.hops = hopCount;
    metrics.latency_ms = latency_ms;
    metrics.energy_mJ = energy_mJ;
    metrics.path = route;
    
    fprintf('\n✅ AODV routing complete!\n');
end