function [bits, values, info] = meterDataGenerator(type, hours, interval)
    
    numReadings = ceil(hours * 60 / interval);
    timeHours = (0:numReadings-1) * interval / 60;
    
    % Generate consumption based on meter type
    switch lower(type)
        case 'electricity'
            % Base load + morning peak + evening peak
            baseLoad = 0.5;
            morningPeak = 2.5 * exp(-((mod(timeHours,24)-9)/1.5).^2);
            eveningPeak = 3.0 * exp(-((mod(timeHours,24)-19.5)/1.5).^2);
            noise = 0.1 * randn(1, numReadings);
            values = baseLoad + morningPeak + eveningPeak + noise;
            values = max(values, 0.1);
            unit = 'kW';
            
        case 'water'
            % Morning shower peak + evening usage
            baseFlow = 2.0;
            morningPeak = 12 * exp(-((mod(timeHours,24)-8)/1).^2);
            eveningPeak = 8 * exp(-((mod(timeHours,24)-19)/1.5).^2);
            noise = 0.5 * randn(1, numReadings);
            values = baseFlow + morningPeak + eveningPeak + noise;
            values = max(values, 0.5);
            unit = 'L/min';
            
        case 'gas'
            % Heating based on temperature
            temperature = 15 - 8*sin(2*pi*(timeHours-12)/24);
            heatingDemand = max(0, (18 - temperature) * 0.3);
            cookingPeak = 2 * (abs(mod(timeHours,24)-12) < 1.5);
            values = 0.3 + heatingDemand + cookingPeak;
            values = max(values, 0.2);
            unit = 'm³/h';
            
        otherwise
            error('Type must be: electricity, water, or gas');
    end
    
    % Convert to 12-bit digital values (0-4095)
    maxVal = max(values);
    digitalValues = round(values / maxVal * 4095);
    digitalValues = min(digitalValues, 4095);
    
    % Convert to bits
    bitsPerReading = 12;
    totalBits = numReadings * bitsPerReading;
    bits = zeros(totalBits, 1);
    
    for i = 1:numReadings
        binary = de2bi(digitalValues(i), bitsPerReading, 'left-msb')';
        startIdx = (i-1)*bitsPerReading + 1;
        endIdx = i*bitsPerReading;
        bits(startIdx:endIdx) = binary;
    end
    
    % Create info structure
    info.type = type;
    info.unit = unit;
    info.numReadings = numReadings;
    info.timeHours = timeHours;
    info.values = values;
    info.maxValue = maxVal;
    info.avgValue = mean(values);
    info.totalConsumption = sum(values) * (interval/60);
    
    fprintf('Meter Data Generated: %s\n', upper(type));
    fprintf('  Readings: %d\n', numReadings);
    fprintf('  Average: %.2f %s\n', info.avgValue, unit);
    fprintf('  Total Bits: %d\n', totalBits);
end