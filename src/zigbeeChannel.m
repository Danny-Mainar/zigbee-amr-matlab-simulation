function [rxSignal, channelInfo] = zigbeeChannel(txSignal, distance, EbNo_dB, bitRate)
    % ZIGBEECHANNEL - Corrected AWGN implementation
    % NO offset, NO fudge factors - pure theoretical model
    
    if nargin < 4, bitRate = 250e3; end
    
    freq = 2.4e9;      % 2.4 GHz
    c = 3e8;           % Speed of light
    
    % Step 1: Path Loss (Friis equation)
    pathLoss_dB = 20*log10(distance) + 20*log10(freq) - 147.55;
    
    % Step 2: Shadowing (optional - set to 0 for deterministic test)
    shadowingStd = 0;  % Set to 0 for now to isolate the issue
    shadowing_dB = shadowingStd * randn();
    totalLoss_dB = pathLoss_dB + shadowing_dB;
    totalLoss_linear = 10^(-totalLoss_dB/10);
    
    % Apply path loss
    attenuatedSignal = txSignal * sqrt(totalLoss_linear);
    
    % Step 3: CORRECT AWGN implementation
    % Calculate signal power
    signalPower = mean(abs(attenuatedSignal).^2);
    
    % Energy per bit
    Eb = signalPower / bitRate;
    
    % Noise power spectral density
    EbNo_linear = 10^(EbNo_dB/10);
    N0 = Eb / EbNo_linear;
    
    % Noise power over bandwidth (2 MHz for ZigBee)
    bandwidth = 2e6;
    noisePower = N0 * bandwidth;
    
    % Generate complex AWGN
    noiseReal = sqrt(noisePower/2) * randn(size(txSignal));
    noiseImag = sqrt(noisePower/2) * randn(size(txSignal));
    noise = noiseReal + 1j * noiseImag;
    
    % Add noise to signal
    rxSignal = attenuatedSignal + noise;
    
    % Calculate actual SNR for verification
    rxPower = mean(abs(rxSignal).^2);
    SNR_dB = 10*log10(rxPower / noisePower);
    
    % Store info
    channelInfo.pathLoss_dB = totalLoss_dB;
    channelInfo.EbNo_dB = EbNo_dB;
    channelInfo.SNR_dB = SNR_dB;
    channelInfo.receivedPower_dBm = 10*log10(rxPower * 1000);
    
    fprintf('Channel: Eb/No=%.1fdB, SNR=%.1fdB, PathLoss=%.1fdB\n', ...
        EbNo_dB, SNR_dB, totalLoss_dB);
end