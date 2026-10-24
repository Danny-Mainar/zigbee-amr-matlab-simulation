clear all; close all; clc; rng(42);

fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
fprintf('║     ZIGBEE AUTOMATIC METER READING SYSTEM                  ║\n');
fprintf('║              COMPLETE SIMULATION SUITE                     ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');

startTime = tic;

%% ========== PART 1: PHY LAYER SIMULATION ==========
fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('PART 1: PHYSICAL LAYER PERFORMANCE (BER, Accuracy, Throughput)\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
Main_Simulation;

%% ========== PART 2: MESH NETWORK COVERAGE ==========
fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('PART 2: MESH NETWORK COVERAGE ANALYSIS\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

% Generate fixed node positions for reproducibility
rng(42);
numNodes = 15;
nodePositions = rand(numNodes, 2) * 150;
nodePositions(1,:) = [75, 75];  % Collector at center

% Display node positions
fprintf('\nNode Positions (15 nodes in 150x150m area):\n');
fprintf('Node\tX(m)\tY(m)\tDist to Collector(m)\n');
for i = 1:numNodes
    dist = sqrt((nodePositions(i,1)-75)^2 + (nodePositions(i,2)-75)^2);
    fprintf('%d\t%.0f\t%.0f\t%.1f\n', i, nodePositions(i,1), nodePositions(i,2), dist);
end

% Calculate single-hop coverage
directCoverage = sqrt((nodePositions(:,1)-75).^2 + (nodePositions(:,2)-75).^2) <= 50;
singleHopCount = sum(directCoverage(2:end));
singleHopPercent = singleHopCount / (numNodes-1) * 100;

% Build neighbor matrix
neighborMatrix = zeros(numNodes);
for i = 1:numNodes
    for j = 1:numNodes
        if i ~= j
            dx = nodePositions(i,1) - nodePositions(j,1);
            dy = nodePositions(i,2) - nodePositions(j,2);
            if sqrt(dx^2 + dy^2) <= 50
                neighborMatrix(i,j) = 1;
            end
        end
    end
end

% BFS from collector
visited = false(numNodes, 1);
queue = 1;
visited(1) = true;
while ~isempty(queue)
    current = queue(1);
    queue(1) = [];
    for neighbor = find(neighborMatrix(current,:))
        if ~visited(neighbor)
            visited(neighbor) = true;
            queue(end+1) = neighbor;
        end
    end
end

meshCount = sum(visited(2:end));
meshPercent = meshCount / (numNodes-1) * 100;

fprintf('\n--- COVERAGE RESULTS ---\n');
fprintf('Single-hop coverage: %d/%d nodes (%.1f%%)\n', singleHopCount, numNodes-1, singleHopPercent);
fprintf('Mesh coverage: %d/%d nodes (%.1f%%)\n', meshCount, numNodes-1, meshPercent);
fprintf('Improvement: +%.1f percentage points (%.1fx)\n', meshPercent-singleHopPercent, meshPercent/singleHopPercent);

if meshCount < numNodes-1
    isolated = find(~visited);
    fprintf('Isolated nodes: %s\n', mat2str(isolated(isolated~=1)'));
else
    fprintf('✓ All nodes connected!\n');
end

%% ========== PART 3: AODV ROUTING ==========
fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('PART 3: AODV ROUTING PROTOCOL\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
aodvRouting(numNodes, nodePositions, 2, 1);

%% ========== PART 4: FAULT TOLERANCE ==========
fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('PART 4: FAULT TOLERANCE ANALYSIS\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
faultToleranceTest(numNodes, nodePositions);

%% ========== PART 5: SCALABILITY ANALYSIS ==========
fprintf('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('PART 5: SCALABILITY ANALYSIS (5 to 20 nodes)\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
scalabilityAnalysis;

%% ========== FINAL SUMMARY ==========
totalTime = toc(startTime);

fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
fprintf('║                    SIMULATION COMPLETE                     ║\n');
fprintf('╠════════════════════════════════════════════════════════════╣\n');
fprintf('║ Total execution time: %.2f seconds                         ║\n', totalTime);
fprintf('║                                                           ║\n');
fprintf('║ Results saved to:                                         ║\n');
fprintf('║   📁 presentation_figures/figures/  (PNG images)          ║\n');
fprintf('║   📁 presentation_figures/data/     (CSV files)           ║\n');
fprintf('║   📄 project_report/simulation_report.txt                 ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');

% Play sound to indicate completion (optional)
beep;

fprintf('\n✅ Ready for presentation!\n');