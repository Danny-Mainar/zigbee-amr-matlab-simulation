function meshSimulation()
    % MESHSIMULATION Main entry point for mesh network simulation
    
    fprintf('\n========================================\n');
    fprintf('ZIGBEE MESH AMR SIMULATION\n');
    fprintf('========================================\n');
    
    %% Configuration
    numNodes = 15;           % Number of meter nodes
    areaSize = 150;          % 150m x 150m area
    bitRate = 250e3;         % 250 kbps
    EbNo_dB = 12;            % Fixed Eb/No for all links
    meterType = 'electricity';
    
    %% Step 1: Create mesh network
    [nodes, collector, adjMatrix] = meshNetworkConfig(numNodes, areaSize);
    
    %% Step 2: Calculate connectivity to collector
    maxRange = 50;
    collectorAdj = zeros(numNodes, 1);
    for i = 1:numNodes
        dist = sqrt((nodes(i,1)-collector(1))^2 + (nodes(i,2)-collector(2))^2);
        collectorAdj(i) = (dist <= maxRange);
    end
    
    %% Step 3: Run AODV routing
    [routes, hopCounts, parentMap] = aodvRouting(nodes, collector, adjMatrix, collectorAdj);
    
    %% Step 4: Generate meter data
    pn_seqs = pn_sequences();
    [meterBits, ~, meterInfo] = meterDataGenerator(meterType, 24, 15);
    % Take first 4000 bits
    if length(meterBits) > 4000
        meterBits = meterBits(1:4000);
    end
    
    %% Step 5: Simulate all nodes sending data
    fprintf('\n=== SIMULATING PACKET TRANSMISSIONS ===\n');
    
    results = struct();
    results.nodeId = [];
    results.hops = [];
    results.delivered = [];
    results.latency_ms = [];
    results.energy_mJ = [];
    
    for node = 1:numNodes
        if hopCounts(node) < inf
            [delivered, latency, hops, energy] = packetForwarder(node, meterBits, routes, pn_seqs, bitRate, EbNo_dB);
        else
            delivered = 0;
            latency = inf;
            hops = 0;
            energy = 0;
        end
        
        results.nodeId(end+1) = node;
        results.hops(end+1) = hops;
        results.delivered(end+1) = delivered;
        results.latency_ms(end+1) = latency * 1000;
        results.energy_mJ(end+1) = energy * 1000;
    end
    
    %% Step 6: Display summary
    fprintf('\n========================================\n');
    fprintf('MESH SIMULATION RESULTS\n');
    fprintf('========================================\n');
    fprintf('%-6s %-8s %-10s %-12s %s\n', 'Node', 'Hops', 'Delivered', 'Latency(ms)', 'Energy(mJ)');
    fprintf('%s\n', repmat('-', 55, 1));
    
    for i = 1:length(results.nodeId)
        if results.delivered(i) == 1
            status = 'YES';
        else
            status = 'NO';
        end
        fprintf('%-6d %-8d %-10s %-12.1f %.2f\n', ...
            results.nodeId(i), results.hops(i), status, ...
            results.latency_ms(i), results.energy_mJ(i));
    end
    
    %% Step 7: Calculate network statistics
    deliveryRate = sum(results.delivered) / length(results.delivered) * 100;
    avgLatency = mean(results.latency_ms(results.delivered == 1));
    avgEnergy = mean(results.energy_mJ(results.delivered == 1));
    
    fprintf('\n=== NETWORK STATISTICS ===\n');
    fprintf('Packet Delivery Ratio: %.1f%%\n', deliveryRate);
    fprintf('Average Latency (successful): %.1f ms\n', avgLatency);
    fprintf('Average Energy per packet: %.2f mJ\n', avgEnergy);
    fprintf('Nodes with routes: %d/%d\n', sum(hopCounts < inf), numNodes);
    
    %% Step 8: Create comparison figure (single-hop vs mesh)
    figure('Name', 'Mesh vs Single-Hop Comparison', 'Position', [200, 200, 1000, 400]);
    
    % Subplot 1: Delivery Rate
    subplot(1,2,1);
    singleHopRate = sum(collectorAdj) / numNodes * 100;
    bar([singleHopRate, deliveryRate]);
    set(gca, 'XTickLabel', {'Single-Hop', 'Mesh'});
    ylabel('Delivery Rate (%)');
    title('Packet Delivery Comparison');
    ylim([0, 105]);
    grid on;
    
    % Subplot 2: Reachable Nodes
    subplot(1,2,2);
    singleHopReachable = sum(collectorAdj);
    meshReachable = sum(hopCounts < inf);
    bar([singleHopReachable, meshReachable]);
    set(gca, 'XTickLabel', {'Single-Hop', 'Mesh'});
    ylabel('Reachable Nodes');
    title('Network Coverage');
    grid on;
    
    saveas(gcf, 'presentation_figures/figures/mesh_vs_singlehop.png');
    
    fprintf('\n✓ Figures saved to presentation_figures/figures/\n');
    fprintf('\n✅ MESH SIMULATION COMPLETE!\n');
end