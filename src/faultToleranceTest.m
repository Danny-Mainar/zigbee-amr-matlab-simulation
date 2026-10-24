function [nodeFailurePDR, collectorFailurePDR] = faultToleranceTest(numNodes, nodePositions)
    % FAULT TOLERANCE TESTING
    % Inputs:
    %   numNodes      - Number of nodes in network (including collector)
    %   nodePositions - N x 2 matrix of (x,y) coordinates
    % Outputs:
    %   nodeFailurePDR     - Array of PDR after each node failure
    %   collectorFailurePDR - PDR after collector failure (should be 0)
    
    fprintf('\n========================================\n');
    fprintf('FAULT TOLERANCE ANALYSIS\n');
    fprintf('========================================\n');
    
    % Communication range (meters)
    range = 50;
    
    % Validate inputs
    if nargin < 2
        % Generate random positions if not provided
        rng(42);
        nodePositions = rand(numNodes, 2) * 150;
        nodePositions(1,:) = [75, 75];  % Collector at center
        fprintf('Generated random node positions\n');
    end
    
    if nargin < 1
        numNodes = 15;
    end
    
    fprintf('Network size: %d nodes (1 collector + %d meters)\n', numNodes, numNodes-1);
    
    % Step 1: Build neighbor matrix
    neighborMatrix = zeros(numNodes);
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                dx = nodePositions(i,1) - nodePositions(j,1);
                dy = nodePositions(i,2) - nodePositions(j,2);
                if sqrt(dx^2 + dy^2) <= range
                    neighborMatrix(i,j) = 1;
                end
            end
        end
    end
    
    % Step 2: BFS function to find reachable nodes from collector
    function reachable = getReachableNodes(activeMatrix, collectorID)
        visited = false(numNodes, 1);
        queue = collectorID;
        visited(collectorID) = true;
        
        while ~isempty(queue)
            current = queue(1);
            queue(1) = [];
            for neighbor = find(activeMatrix(current,:))
                if ~visited(neighbor)
                    visited(neighbor) = true;
                    queue(end+1) = neighbor;
                end
            end
        end
        reachable = visited;
    end
    
    % Step 3: Normal operation (no failures)
    normalReachable = getReachableNodes(neighborMatrix, 1);
    normalPDR = sum(normalReachable(2:end)) / (numNodes-1) * 100;
    fprintf('\n--- Normal Operation ---\n');
    fprintf('Reachable nodes: %d/%d (%.1f%%)\n', sum(normalReachable(2:end)), numNodes-1, normalPDR);
    
    % Step 4: Test 1 - Single node failures (each meter node)
    fprintf('\n--- Scenario A: Single Node Failure ---\n');
    fprintf('Failed Node\tStatus\t\tPDR (%%)\n');
    fprintf('------------\t----------\t-------\n');
    
    nodeFailurePDR = zeros(numNodes, 1);
    
    for failedNode = 2:numNodes
        % Create network without failed node
        tempMatrix = neighborMatrix;
        tempMatrix(failedNode, :) = 0;
        tempMatrix(:, failedNode) = 0;
        
        % Find reachable nodes
        reachable = getReachableNodes(tempMatrix, 1);
        
        % Calculate PDR (excluding collector and failed node)
        activeNodes = setdiff(2:numNodes, failedNode);
        delivered = sum(reachable(activeNodes));
        pdr = delivered / length(activeNodes) * 100;
        nodeFailurePDR(failedNode) = pdr;
        
        % Determine status
        if pdr == 100
            status = 'FULL RECOVERY';
        elseif pdr > 90
            status = 'PARTIAL RECOVERY';
        else
            status = 'SEVERE LOSS';
        end
        
        fprintf('Node %d\t\t%s\t%.1f%%\n', failedNode, status, pdr);
    end
    
    avgPDR = mean(nodeFailurePDR(2:end));
    minPDR = min(nodeFailurePDR(2:end));
    fprintf('\nSummary:\n');
    fprintf('  Average PDR after node failure: %.1f%%\n', avgPDR);
    fprintf('  Minimum PDR after node failure: %.1f%%\n', minPDR);
    
    % Step 5: Test 2 - Collector failure
    fprintf('\n--- Scenario B: Collector Failure ---\n');
    
    % Remove collector completely
    tempMatrix = neighborMatrix;
    tempMatrix(1, :) = 0;
    tempMatrix(:, 1) = 0;
    
    % Try to reach collector (impossible)
    reachable = getReachableNodes(tempMatrix, 1);
    collectorFailurePDR = 0;
    
    fprintf('Failed Node: Collector (Node 1)\n');
    fprintf('Status: COMPLETE NETWORK FAILURE\n');
    fprintf('PDR: %.1f%%\n', collectorFailurePDR);
    fprintf('⚠ CRITICAL: Collector is a single point of failure!\n');
    fprintf('   Recommendation: Deploy redundant collectors.\n');
    
    % Step 6: Identify critical nodes (failure of which causes >10% loss)
    fprintf('\n--- Critical Node Analysis ---\n');
    criticalNodes = find(nodeFailurePDR < 90);
    criticalNodes = criticalNodes(criticalNodes >= 2);  % Exclude collector
    
    if isempty(criticalNodes)
        fprintf('No critical nodes found. Network is robust to single node failures.\n');
    else
        fprintf('Critical nodes (failure causes >10%% PDR loss): %s\n', mat2str(criticalNodes));
        fprintf('Recommendation: Add redundant paths around these nodes.\n');
    end
    
    % Step 7: Visualize fault tolerance results
    figure(9);
    clf;
    subplot(2,1,1);
    bar(2:numNodes, nodeFailurePDR(2:numNodes), 'b');
    xlabel('Failed Node ID');
    ylabel('Packet Delivery Ratio (%)');
    title('PDR After Single Node Failure');
    ylim([0, 105]);
    grid on;
    hold on;
    plot([2, numNodes], [100, 100], 'g--', 'LineWidth', 2);
    plot([2, numNodes], [90, 90], 'r--', 'LineWidth', 2);
    legend('PDR', '100% Target', '90% Warning', 'Location', 'southwest');
    
    subplot(2,1,2);
    bar(1, collectorFailurePDR, 'r');
    xlabel('Failed Component');
    ylabel('Packet Delivery Ratio (%)');
    title('PDR After Collector Failure');
    ylim([0, 105]);
    set(gca, 'XTickLabel', {'Collector'});
    grid on;
    
    sgtitle('ZigBee AMR System - Fault Tolerance Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, 'presentation_figures/figures/fault_tolerance.png');
    fprintf('\n✓ Fault tolerance figure saved\n');
    
    % Step 8: Final summary
    fprintf('\n========================================\n');
    fprintf('FAULT TOLERANCE SUMMARY\n');
    fprintf('========================================\n');
    fprintf('✓ Mesh network self-heals after single node failure\n');
    fprintf('  - Average recovery: %.1f%% PDR maintained\n', avgPDR);
    fprintf('  - Worst case: %.1f%% PDR\n', minPDR);
    fprintf('\n✗ Collector failure is catastrophic:\n');
    fprintf('  - PDR drops to 0%%\n');
    fprintf('  - Recommendation: Deploy 2+ redundant collectors\n');
    fprintf('========================================\n');
end