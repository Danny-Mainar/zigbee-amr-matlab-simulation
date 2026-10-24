clear all; close all; clc;

fprintf('\n========================================\n');
fprintf('ZIGBEE METER READING SYSTEM SIMULATION\n');
fprintf('========================================\n\n');

%% Parameters
bitRate = 250e3;           % 250 kbps
numBits = 4000;             % Bits to simulate
EbNo_dB = 0:2:14;           % Eb/No range
distance = 30;              % Meters
meterType = 'electricity';  % electricity, water, or gas

%% Generate PN Sequences
pn_seqs = pn_sequences();
fprintf('✓ PN sequences loaded\n');

%% Generate Meter Data
[meterBits, meterValues, meterInfo] = meterDataGenerator(meterType, 24, 15);
if length(meterBits) < numBits
    meterBits = repmat(meterBits, ceil(numBits/length(meterBits)), 1);
end
meterBits = meterBits(1:numBits);
fprintf('✓ Meter data generated\n');

%% Run Simulation
fprintf('\nRunning simulation for %d Eb/No points...\n', length(EbNo_dB));

ber_results = zeros(length(EbNo_dB), 1);
accuracy_results = zeros(length(EbNo_dB), 1);
throughput_results = zeros(length(EbNo_dB), 1);

for idx = 1:length(EbNo_dB)
    fprintf('  Eb/No = %.1f dB...', EbNo_dB(idx));
    
    % Transmit
    [txSignal, ~] = zigbeeTransmitter(meterBits, pn_seqs);
    
    % Channel
    [rxSignal, ~] = zigbeeChannel(txSignal, distance, EbNo_dB(idx), bitRate);
    
    % Receive
    [rxBits, ber, ~] = zigbeeReceiver(rxSignal, meterBits, pn_seqs);
    
    % Store results
    ber_results(idx) = ber;
    accuracy_results(idx) = (1 - ber) * 100;
    throughput_results(idx) = bitRate * (1 - ber);
    
    fprintf(' BER=%.2e, Accuracy=%.1f%%\n', ber, accuracy_results(idx));
end

%% Display Results Summary
fprintf('\n========================================\n');
fprintf('RESULTS SUMMARY\n');
fprintf('========================================\n');
fprintf('Eb/No(dB)\tBER\t\tAccuracy(%%)\tThroughput(Kbps)\n');
for i = 1:length(EbNo_dB)
    fprintf('%.1f\t\t%.2e\t%.2f\t\t%.1f\n', ...
        EbNo_dB(i), ber_results(i), accuracy_results(i), throughput_results(i)/1000);
end

%% Generate Visualizations
resultsVisualizer(EbNo_dB, ber_results, accuracy_results, throughput_results, meterInfo);

%% Generate Report
reportGenerator(EbNo_dB, ber_results, accuracy_results, throughput_results);

%% Find Optimal Operating Point
[~, bestIdx] = min(abs(accuracy_results - 99));
fprintf('\n========================================\n');
fprintf('RECOMMENDED OPERATING POINT\n');
fprintf('========================================\n');
fprintf('Eb/No = %.1f dB\n', EbNo_dB(bestIdx));
fprintf('BER = %.2e\n', ber_results(bestIdx));
fprintf('Accuracy = %.1f%%\n', accuracy_results(bestIdx));
fprintf('Throughput = %.1f Kbps\n\n', throughput_results(bestIdx)/1000);

fprintf('✅ SIMULATION COMPLETE!\n');