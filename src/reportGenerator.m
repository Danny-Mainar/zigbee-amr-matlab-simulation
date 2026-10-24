function reportGenerator(EbNo_dB, ber, accuracy, throughput)
    % REPORTGENERATOR Saves results to CSV and TXT files
    
    % Create directories if they don't exist
    if ~exist('presentation_figures/data', 'dir')
        mkdir('presentation_figures/data');
    end
    if ~exist('project_report', 'dir')
        mkdir('project_report');
    end
    
    % Create results table
    results = table();
    results.EbNo_dB = EbNo_dB';
    results.BER = ber;
    results.Accuracy_Percent = accuracy;
    results.Throughput_Kbps = throughput / 1000;
    
    % Save to CSV
    writetable(results, 'presentation_figures/data/results.csv');
    
    % Save to TXT report
    fid = fopen('project_report/simulation_report.txt', 'w');
    fprintf(fid, '=== ZIGBEE METER READING SYSTEM REPORT ===\n');
    fprintf(fid, 'Date: %s\n\n', datestr(now));
    fprintf(fid, 'RESULTS SUMMARY:\n');
    fprintf(fid, 'Eb/No (dB)\tBER\t\tAccuracy (%%)\tThroughput (Kbps)\n');
    for i = 1:length(EbNo_dB)
        fprintf(fid, '%.1f\t\t%.2e\t%.2f\t\t%.1f\n', ...
            EbNo_dB(i), ber(i), accuracy(i), throughput(i)/1000);
    end
    fclose(fid);
    
    fprintf('Report saved to project_report/simulation_report.txt\n');
end