clear all; close all; clc;

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║     COMPLETE ZIGBEE AMR SIMULATION                             ║\n');
fprintf('║     Original PHY/MAC + Mesh Routing + Fault Tolerance          ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');

% Create directories for output
if ~exist('presentation_figures/figures', 'dir')
    mkdir('presentation_figures/figures');
end
if ~exist('project_report', 'dir')
    mkdir('project_report');
end

%% ========================================================================
% PART A: ORIGINAL SIMULATION (Your Main_Simulation.m)
% =========================================================================
fprintf('\n\n');
fprintf('████████████████████████████████████████████████████████████████\n');
fprintf('█                    PART A: ORIGINAL SIMULATION                █\n');
fprintf('████████████████████████████████████████████████████████████████\n');

% Run your original Main_Simulation
Main_Simulation;

fprintf('\n✓ Original simulation complete!\n');
fprintf('  Figures saved: ber_plot.png, accuracy_plot.png, meter_pattern.png, throughput_plot.png\n');

%% ========================================================================
% PART B: MESH SIMULATION (Improvements)
% =========================================================================
fprintf('\n\n');
fprintf('████████████████████████████████████████████████████████████████\n');
fprintf('█                    PART B: MESH IMPROVEMENTS                  █\n');
fprintf('████████████████████████████████████████████████████████████████\n');

% Run mesh simulation
meshSimulation;

fprintf('\n✓ Mesh simulation complete!\n');
fprintf('  Figures saved: mesh_topology.png, routing_tree.png, mesh_vs_singlehop.png\n');

%% ========================================================================
% PART C: FAULT TOLERANCE TEST
% =========================================================================
fprintf('\n\n');
fprintf('████████████████████████████████████████████████████████████████\n');
fprintf('█                    PART C: FAULT TOLERANCE TEST               █\n');
fprintf('████████████████████████████████████████████████████████████████\n');

% Run fault tolerance test
faultToleranceTest;

fprintf('\n✓ Fault tolerance test complete!\n');
fprintf('  Figure saved: fault_tolerance.png\n');

%% ========================================================================
% PART D: SCALABILITY ANALYSIS
% =========================================================================
fprintf('\n\n');
fprintf('████████████████████████████████████████████████████████████████\n');
fprintf('█                    PART D: SCALABILITY ANALYSIS               █\n');
fprintf('████████████████████████████████████████████████████████████████\n');

% Run scalability analysis (fixed version)
networkSizes = [5, 10, 15, 20];
deliveryRates = zeros(length(networkSizes), 1);

for idx = 1:length(networkSizes)
    fprintf('\nTesting network size: %d nodes...\n', networkSizes(idx));
    
    [nodes, collector, adjMatrix] = meshNetworkConfig(networkSizes(idx), 150);
    
    maxRange = 50;
    collectorAdj = zeros(networkSizes(idx), 1);
    for i = 1:networkSizes(idx)
        dist = sqrt((nodes(i,1)-collector(1))^2 + (nodes(i,2)-collector(2))^2);
        collectorAdj(i) = (dist <= maxRange);
    end
    
    [~, hopCounts, ~] = aodvRouting(nodes, collector, adjMatrix, collectorAdj);
    deliveryRates(idx) = sum(hopCounts < inf) / networkSizes(idx) * 100;
    fprintf('  Delivery rate: %.1f%%\n', deliveryRates(idx));
end

% Create scalability figure
figure('Name', 'Scalability Analysis', 'Position', [200, 200, 800, 500], 'Visible', 'on');
plot(networkSizes, deliveryRates, 'b-o', 'LineWidth', 2, 'MarkerSize', 10);
grid on;
xlabel('Number of Nodes', 'FontSize', 12);
ylabel('Packet Delivery Ratio (%)', 'FontSize', 12);
title('ZigBee Mesh Scalability', 'FontSize', 14);
ylim([0, 105]);
xlim([0, 22]);
set(gca, 'XTick', networkSizes);

% Add value labels
for i = 1:length(networkSizes)
    text(networkSizes(i), deliveryRates(i) + 2, sprintf('%.1f%%', deliveryRates(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

drawnow;
pause(0.5);
saveas(gcf, 'presentation_figures/figures/scalability.png');

fprintf('\n✓ Scalability analysis complete!\n');
fprintf('  Figure saved: scalability.png\n');

%% ========================================================================
% SUMMARY
% =========================================================================
fprintf('\n\n');
fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║                    SIMULATION SUMMARY                          ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');

fprintf('\n📁 ALL FIGURES GENERATED:\n');
fprintf('   presentation_figures/figures/\n');
fprintf('   ├── ber_plot.png (Original - BER performance)\n');
fprintf('   ├── accuracy_plot.png (Original - Meter accuracy)\n');
fprintf('   ├── meter_pattern.png (Original - Consumption pattern)\n');
fprintf('   ├── throughput_plot.png (Original - Throughput)\n');
fprintf('   ├── mesh_topology.png (Mesh - Network layout)\n');
fprintf('   ├── routing_tree.png (Mesh - AODV paths)\n');
fprintf('   ├── mesh_vs_singlehop.png (Mesh - Coverage comparison)\n');
fprintf('   ├── fault_tolerance.png (Fault - Node failure resilience)\n');
fprintf('   └── scalability.png (Fault - Performance vs network size)\n');

fprintf('\n📄 REPORT SAVED:\n');
fprintf('   project_report/simulation_report.txt\n');

fprintf('\n✅ ALL SIMULATIONS COMPLETE!\n');
fprintf('============================================================\n');