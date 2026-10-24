function [deliveryStatus, latency, hopsUsed, energyUsed] = packetForwarder(sourceNode, meterBits, routes, pn_seqs, bitRate, EbNo_dB)
    % PACKETFORWARDER Simulates multi-hop packet forwarding
    % Input: sourceNode = ID of meter sending data
    %        meterBits = data to send
    %        routes = routing table
    %        pn_seqs = PN sequences for modulation
    %        bitRate, EbNo_dB = channel parameters
    % Output: deliveryStatus = 1 if delivered, 0 if lost
    %         latency = end-to-end delay in seconds
    %         hopsUsed = number of hops taken
    %         energyUsed = total energy consumed (Joules)
    
    path = routes{sourceNode};
    
    if isempty(path)
        fprintf('Node %d has no route to collector!\n', sourceNode);
        deliveryStatus = 0;
        latency = inf;
        hopsUsed = 0;
        energyUsed = 0;
        return;
    end
    
    % Path: [node1, node2, ..., nodeN, 0] where 0 = collector
    hopsUsed = length(path) - 1;
    fprintf('\n--- Forwarding from Node %d: %d hops ---\n', sourceNode, hopsUsed);
    
    currentBits = meterBits;
    totalLatency = 0;
    totalEnergy = 0;
    
    for hop = 1:hopsUsed
        txNode = path(hop);
        rxNode = path(hop+1);
        
        % Distance between nodes
        if rxNode == 0
            % Collector position (need to get from global or pass as parameter)
            % For now, assume distance = 30m (typical)
            distance = 30;
            fprintf('  Hop %d: Node %d -> Collector (%.0fm)\n', hop, txNode, distance);
        else
            % Need node positions - for simplicity, use typical distance
            distance = 20;
            fprintf('  Hop %d: Node %d -> Node %d (%.0fm)\n', hop, txNode, rxNode, distance);
        end
        
        % Calculate per-hop metrics
        [hopLatency, hopEnergy, success] = singleHopTransmission(currentBits, distance, bitRate, EbNo_dB, pn_seqs);
        
        totalLatency = totalLatency + hopLatency;
        totalEnergy = totalEnergy + hopEnergy;
        
        if success == 0
            fprintf('  ✗ Transmission failed at hop %d!\n', hop);
            deliveryStatus = 0;
            latency = totalLatency;
            hopsUsed = hop;
            energyUsed = totalEnergy;
            return;
        end
        
        fprintf('  ✓ Hop %d success (%.0f ms, %.1f mJ)\n', hop, hopLatency*1000, hopEnergy*1000);
    end
    
    deliveryStatus = 1;
    latency = totalLatency;
    energyUsed = totalEnergy;
    
    fprintf('\n✓ Packet delivered! Total: %.0f ms, %.1f mJ\n', latency*1000, energyUsed*1000);
end

function [latency, energy, success] = singleHopTransmission(bits, distance, bitRate, EbNo_dB, pn_seqs)
    % Simulate one hop transmission
    % Returns: latency (s), energy (J), success (1/0)
    
    % Transmission time
    numBits = length(bits);
    latency = numBits / bitRate;
    
    % Energy model (typical ZigBee values)
    txPower = 0.035;   % 35 mW transmit power
    energy = txPower * latency;  % Joules
    
    % Channel simulation (reuse your existing functions)
    [txSignal, ~] = zigbeeTransmitter(bits, pn_seqs);
    [rxSignal, ~] = zigbeeChannel(txSignal, distance, EbNo_dB, bitRate);
    [~, ber, ~] = zigbeeReceiver(rxSignal, bits, pn_seqs);
    
    % Success if BER is very low (add some margin)
    success = (ber < 0.001);  % 0.1% BER threshold
end