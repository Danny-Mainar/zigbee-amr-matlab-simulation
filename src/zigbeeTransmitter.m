function [txSignal, txInfo] = zigbeeTransmitter(bits, pn_seqs)
    % ZIGBEETRANSMITTER Implements ZigBee DSSS modulation
    
    samplesPerChip = 4;
    chipsPerSymbol = 32;
    bitsPerSymbol = 4;
    
    % Check input length
    if mod(length(bits), bitsPerSymbol) ~= 0
        error('Bits must be multiple of 4');
    end
    
    numSymbols = length(bits) / bitsPerSymbol;
    
    % Step 1: Bit to Symbol (4 bits -> 0-15)
    symbols = zeros(numSymbols, 1);
    for i = 1:numSymbols
        startIdx = (i-1)*bitsPerSymbol + 1;
        endIdx = i*bitsPerSymbol;
        bitGroup = bits(startIdx:endIdx);
        symbols(i) = bi2de(bitGroup', 'left-msb');
    end
    
    % Step 2: Symbol to PN Sequence (DSSS Spreading)
    chips = zeros(numSymbols * chipsPerSymbol, 1);
    for i = 1:numSymbols
        seqIdx = symbols(i) + 1;
        pnInt = pn_seqs(seqIdx);
        pnBinary = de2bi(pnInt, chipsPerSymbol, 'left-msb')';
        startIdx = (i-1)*chipsPerSymbol + 1;
        endIdx = i*chipsPerSymbol;
        chips(startIdx:endIdx) = pnBinary;
    end
    
    % Step 3: BPSK Modulation (0 -> +1, 1 -> -1)
    totalSamples = length(chips) * samplesPerChip;
    txSignal = zeros(totalSamples, 1);
    
    for i = 1:length(chips)
        % Map chip to BPSK symbol
        if chips(i) == 0
            symbol = 1;
        else
            symbol = -1;
        end
        
        % Apply pulse shaping (rectangular pulse for simplicity)
        startIdx = (i-1)*samplesPerChip + 1;
        endIdx = i * samplesPerChip;
        txSignal(startIdx:endIdx) = symbol;
    end
    
    % Normalize power
    power = mean(txSignal.^2);
    if power > 0
        txSignal = txSignal / sqrt(power);
    end
    
    % Store info
    txInfo.numSymbols = numSymbols;
    txInfo.symbols = symbols;
    txInfo.chips = chips;
    txInfo.signalPower = power;
    
    fprintf('Transmitter: %d symbols, %d chips, %d samples\n', ...
        numSymbols, length(chips), totalSamples);
end