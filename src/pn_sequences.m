function sequences = pn_sequences()
    % ZigBee IEEE 802.15.4 Standard 32-chip PN Sequences
    % Returns 16 sequences (one for each symbol 0-15)
    
    sequences = [
        0b11011001110000110101001000101110;  % Sequence for symbol 0
        0b11101101100111000011010100100010;  % Sequence for symbol 1
        0b00101110110110011100001101010010;  % Sequence for symbol 2
        0b00100010111011011001110000110101;  % Sequence for symbol 3
        0b01010010001011101101100111000011;  % Sequence for symbol 4
        0b00110101001000101110110110011100;  % Sequence for symbol 5
        0b11000011010100100010111011011001;  % Sequence for symbol 6
        0b10011100001101010010001011101101;  % Sequence for symbol 7
        0b10001100100101100000011101111011;  % Sequence for symbol 8
        0b10111000110010010110000001110111;  % Sequence for symbol 9
        0b01111011100011001001011000000111;  % Sequence for symbol 10
        0b01110111101110001100100101100000;  % Sequence for symbol 11
        0b00000111011110111000110010010110;  % Sequence for symbol 12
        0b01100000011101111011100011001001;  % Sequence for symbol 13
        0b10010110000001110111101110001100;  % Sequence for symbol 14
        0b11001001011000000111011110111000;  % Sequence for symbol 15
    ];
end