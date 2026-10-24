function [nodeCounts, coveragePercent, avgLatency] = scalabilityAnalysis()
    % SCALABILITY ANALYSIS
    % Tests network performance from 5 to 20 nodes
    % Outputs:
    %   nodeCounts     - Array of node counts tested
    %   coveragePercent - Coverage percentage for each node count
    %   avgLatency     - Average latency in ms for each node count
    
    fprintf('\n========================================\n');
    fprintf('SCALABILITY ANALYSIS\n');
    fprintf('========================================\n');
    
    % Parameters
    areaSize = 150;        % 150m x 150m
    range = 50;            % ZigBee range (meters)
    nodeCounts = 5:5:20;   % Test 5, 10, 15, 20 nodes
    numRuns = 5;           % Multiple runs for statistical significance
    
    coveragePercent = zeros(length(nodeCounts), 1);
    avgHopCount = zeros(length(nodeCounts), 1);
    avgLatency = zeros(length(nodeCounts), 1);
    
    fprintf('\nTesting network sizes: %s\n', mat2str(nodeCounts));
    fprintf('Running %d random topologies per network size...\n', numRuns);
    
    for idx = 1:length(nodeCounts)
        numNodes = nodeCounts(idx);
        fprintf('\n--- Testing %d nodes ---\n', numNodes);
        
        coverageSum = 0;
        hopSum = 0;
        
        for run = 1:numRuns
            % Generate random node positions
            rng(42 + run);  % Different seed for each run
            nodePositions = rand(numNodes, 2) * areaSize;
            nodePositions(1,:) = [areaSize/2, areaSize/2];  % Collector at center
            
            % Calculate distance matrix
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
            
            % Build neighbor matrix (nodes within range)
            neighborMatrix = distances <= range;
            
            % BFS to find reachable nodes from collector (node 1)
            visited = false(numNodes, 1);
            queue = 1;
            visited(1) = true;
            hopCount = zeros(numNodes, 1);
            
            while ~isempty(queue)
                current = queue(1);
                queue(1) = [];
                for neighbor = find(neighborMatrix(current,:))
                    if ~visited(neighbor)
                        visited(neighbor) = true;
                        hopCount(neighbor) = hopCount(current) + 1;
                        queue(end+1) = neighbor;
                    end
                end
            end
            
            % Calculate coverage (excluding collector)
            reachableMeters = sum(visited(2:end));
            totalMeters = numNodes - 1;
            coverage = reachableMeters / totalMeters * 100;
            coverageSum = coverageSum + coverage;
            
            % Calculate average hop count
            avgHops = mean(hopCount(visited & (1:numNodes)' ~= 1));
            if isnan(avgHops)
                avgHops = 0;
            end
            hopSum = hopSum + avgHops;
        end
        
        % Average over runs
        coveragePercent(idx) = coverageSum / numRuns;
        avgHopCount(idx) = hopSum / numRuns;
        avgLatency(idx) = avgHopCount(idx) * 4.6;  % 4.6 ms per hop
        
        fprintf('  Average coverage: %.1f%%\n', coveragePercent(idx));
        fprintf('  Average hop count: %.1f hops\n', avgHopCount(idx));
        fprintf('  Average latency: %.1f ms\n', avgLatency(idx));
    end
    
    % Display results table
    fprintf('\n========================================\n');
    fprintf('SCALABILITY RESULTS SUMMARY\n');
    fprintf('========================================\n');
    fprintf('Nodes\tCoverage\tAvg Hops\tLatency (ms)\n');
    fprintf('-----\t--------\t--------\t------------\n');
    for idx = 1:length(nodeCounts)
        fprintf('%d\t%.1f%%\t\t%.1f\t\t%.1f\n', ...
            nodeCounts(idx), coveragePercent(idx), avgHopCount(idx), avgLatency(idx));
    end
    
    % Find minimum nodes for full coverage (extrapolated)
    fprintf('\n--- Analysis ---\n');
    if coveragePercent(end) >= 99
        fprintf('✓ Full coverage (>99%%) achieved with %d nodes\n', nodeCounts(end));
    else
        % Linear extrapolation to 100%
        if length(nodeCounts) >= 2
            slope = (coveragePercent(end) - coveragePercent(end-1)) / (nodeCounts(end) - nodeCounts(end-1));
            nodes_needed = nodeCounts(end) + (100 - coveragePercent(end)) / slope;
            fprintf('⚠ Extrapolated nodes needed for 100%% coverage: ~%.0f nodes\n', nodes_needed);
        else
            fprintf('⚠ More data points needed for extrapolation\n');
        end
    end
    
    % Node density calculation
    area_m2 = areaSize * areaSize;
    density = nodeCounts ./ (area_m2 / 10000);  % nodes per hectare
    fprintf('\nNode density:\n');
    for idx = 1:length(nodeCounts)
        fprintf('  %d nodes: %.0f nodes/hectare (%.0f m² per node)\n', ...
            nodeCounts(idx), density(idx), area_m2 / nodeCounts(idx));
    end
    
    % Plot scalability results
    figure(10);
    clf;
    
    subplot(2,1,1);
    plot(nodeCounts, coveragePercent, 'bo-', 'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    grid on;
    xlabel('Number of Nodes', 'FontSize', 12);
    ylabel('Coverage (%)', 'FontSize', 12);
    title('Network Coverage vs Number of Nodes', 'FontSize', 14);
    ylim([0, 105]);
    xlim([min(nodeCounts)-1, max(nodeCounts)+1]);
    hold on;
    plot([min(nodeCounts), max(nodeCounts)], [100, 100], 'r--', 'LineWidth', 1.5);
    legend('Coverage', '100% Target', 'Location', 'southeast');
    
    subplot(2,1,2);
    plot(nodeCounts, avgLatency, 'ms-', 'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', 'm');
    grid on;
    xlabel('Number of Nodes', 'FontSize', 12);
    ylabel('Average Latency (ms)', 'FontSize', 12);
    title('End-to-End Latency vs Number of Nodes', 'FontSize', 14);
    xlim([min(nodeCounts)-1, max(nodeCounts)+1]);
    
    sgtitle('ZigBee AMR System - Scalability Analysis', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    if ~exist('presentation_figures/figures', 'dir')
        mkdir('presentation_figures/figures');
    end
    saveas(gcf, 'presentation_figures/figures/scalability.png');
    fprintf('\n✓ Scalability figure saved to presentation_figures/figures/scalability.png\n');
    
    % Save data to CSV
    scalabilityData = table(nodeCounts', coveragePercent, avgHopCount, avgLatency, ...
        'VariableNames', {'NodeCount', 'Coverage_Percent', 'AvgHopCount', 'Latency_ms'});
    writetable(scalabilityData, 'presentation_figures/data/scalability_results.csv');
    fprintf('✓ Scalability data saved to presentation_figures/data/scalability_results.csv\n');
    
    fprintf('\n✅ Scalability analysis complete!\n');
end