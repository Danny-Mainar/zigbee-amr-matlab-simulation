function [rxBits, ber, rxInfo] = zigbeeReceiver(rxSignal, originalBits, pn_seqs)
    % ZIGBEERECEIVER Demodulates and despreads ZigBee signal
    % FIXED VERSION - Correct correlation logic
    
    chipsPerSymbol = 32;
    bitsPerSymbol = 4;
    samplesPerChip = 4;
    
    % Step 1: Extract chips from received signal (simplified BPSK detection)
    totalSamples = length(rxSignal);
    numChips = floor(totalSamples / samplesPerChip);
    chips = zeros(numChips, 1);
    
    for i = 1:numChips
        % Sample at the center of each chip period
        sampleIdx = (i-1)*samplesPerChip + round(samplesPerChip/2);
        if sampleIdx <= totalSamples
            % Use real part for decision (BPSK simplified)
            if real(rxSignal(sampleIdx)) > 0
                chips(i) = 0;
            else
                chips(i) = 1;
            end
        end
    end
    
    % Step 2: Despread using correlation
    numSymbols = floor(numChips / chipsPerSymbol);
    detectedSymbols = zeros(numSymbols, 1);
    
    % Pre-convert PN sequences to binary arrays for faster comparison
    pn_binary = zeros(16, chipsPerSymbol);
    for seqIdx = 1:16
        pn_binary(seqIdx, :) = de2bi(pn_seqs(seqIdx), chipsPerSymbol, 'left-msb');
    end
    
    for symIdx = 1:numSymbols
        startChip = (symIdx-1)*chipsPerSymbol + 1;
        endChip = symIdx * chipsPerSymbol;
        rxChips = chips(startChip:endChip);
        
        % Calculate correlation with each PN sequence
        correlations = zeros(16, 1);
        for seqIdx = 1:16
            % Count matching chips (higher = better match)
            matches = sum(rxChips == pn_binary(seqIdx, :)');
            correlations(seqIdx) = matches;
        end
        
        % Find the sequence with highest correlation
        [bestMatchValue, bestMatchIdx] = max(correlations);
        detectedSymbols(symIdx) = bestMatchIdx - 1;
    end
    
    % Step 3: Convert symbols back to bits
    rxBits = zeros(numSymbols * bitsPerSymbol, 1);
    for i = 1:numSymbols
        bits = de2bi(detectedSymbols(i), bitsPerSymbol, 'left-msb')';
        startIdx = (i-1)*bitsPerSymbol + 1;
        endIdx = i * bitsPerSymbol;
        rxBits(startIdx:endIdx) = bits;
    end
    
    % Step 4: Calculate BER (make sure lengths match)
    minLen = min(length(originalBits), length(rxBits));
    if minLen > 0
        errors = sum(originalBits(1:minLen) ~= rxBits(1:minLen));
        ber = errors / minLen;
    else
        ber = 1;
        errors = minLen;
    end
    
    % Store info
    rxInfo.numSymbols = numSymbols;
    rxInfo.detectedSymbols = detectedSymbols;
    rxInfo.ber = ber;
    rxInfo.errors = errors;
    
    fprintf('Receiver: %d symbols, BER = %.2e\n', numSymbols, ber);
end