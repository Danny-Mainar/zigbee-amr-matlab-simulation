function resultsVisualizer(EbNo_dB, ber, accuracy, throughput, meterInfo)
    % RESULTSVISUALIZER Creates all project graphs with fixed rendering
    
    % Create figures folder if it doesn't exist
    if ~exist('presentation_figures/figures', 'dir')
        mkdir('presentation_figures/figures');
    end
    
    % Figure 1: BER Performance
    figure(1);
    clf;
    semilogy(EbNo_dB, ber, 'b-o', 'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    grid on;
    xlabel('Eb/No (dB)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
    title('ZigBee Link Performance - BER vs Eb/No', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 11);
    xlim([min(EbNo_dB), max(EbNo_dB)]);
    drawnow;
    set(gcf, 'Renderer', 'painters');
    saveas(gcf, 'presentation_figures/figures/ber_plot.png');
    saveas(gcf, 'presentation_figures/figures/ber_plot.fig');
    fprintf('✓ Saved: ber_plot.png\n');
    
    % Figure 2: Meter Reading Accuracy
    figure(2);
    clf;
    plot(EbNo_dB, accuracy, 'r-s', 'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    grid on;
    xlabel('Eb/No (dB)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Meter Reading Accuracy (%)', 'FontSize', 12, 'FontWeight', 'bold');
    title('ZigBee Meter Reading Accuracy vs Eb/No', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([94, 101]);
    xlim([min(EbNo_dB), max(EbNo_dB)]);
    hold on;
    plot([min(EbNo_dB), max(EbNo_dB)], [99, 99], 'k--', 'LineWidth', 1.5);
    legend('System Accuracy', '99% Target', 'Location', 'southeast', 'FontSize', 10);
    set(gca, 'FontSize', 11);
    drawnow;
    set(gcf, 'Renderer', 'painters');
    saveas(gcf, 'presentation_figures/figures/accuracy_plot.png');
    saveas(gcf, 'presentation_figures/figures/accuracy_plot.fig');
    fprintf('✓ Saved: accuracy_plot.png\n');
    
    % Figure 3: Meter Consumption Pattern
    figure(3);
    clf;
    plot(meterInfo.timeHours, meterInfo.values, 'g-', 'LineWidth', 2.5);
    grid on;
    xlabel('Time (hours)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(['Consumption (', meterInfo.unit, ')'], 'FontSize', 12, 'FontWeight', 'bold');
    title([upper(meterInfo.type), ' Meter - 24 Hour Consumption Pattern'], 'FontSize', 14, 'FontWeight', 'bold');
    xlim([0, 24]);
    set(gca, 'FontSize', 11);
    drawnow;
    set(gcf, 'Renderer', 'painters');
    saveas(gcf, 'presentation_figures/figures/meter_pattern.png');
    saveas(gcf, 'presentation_figures/figures/meter_pattern.fig');
    fprintf('✓ Saved: meter_pattern.png\n');
    
    % Figure 4: Throughput Analysis
    figure(4);
    clf;
    plot(EbNo_dB, throughput/1000, 'm-d', 'LineWidth', 2.5, 'MarkerSize', 10, 'MarkerFaceColor', 'm');
    grid on;
    xlabel('Eb/No (dB)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Throughput (Kbps)', 'FontSize', 12, 'FontWeight', 'bold');
    title('ZigBee System Throughput vs Eb/No', 'FontSize', 14, 'FontWeight', 'bold');
    xlim([min(EbNo_dB), max(EbNo_dB)]);
    ylim([0, 260]);
    hold on;
    plot([min(EbNo_dB), max(EbNo_dB)], [250, 250], 'b--', 'LineWidth', 1.5);
    legend('Effective Throughput', 'Ideal (250 Kbps)', 'Location', 'southeast', 'FontSize', 10);
    set(gca, 'FontSize', 11);
    drawnow;
    set(gcf, 'Renderer', 'painters');
    saveas(gcf, 'presentation_figures/figures/throughput_plot.png');
    saveas(gcf, 'presentation_figures/figures/throughput_plot.fig');
    fprintf('✓ Saved: throughput_plot.png\n');
    
    % Figure 5: Combined Dashboard (All 4 subplots)
    figure(5);
    clf;
    
    % Subplot 1: BER
    subplot(2,2,1);
    semilogy(EbNo_dB, ber, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
    grid on;
    xlabel('Eb/No (dB)');
    ylabel('BER');
    title('Bit Error Rate');
    set(gca, 'FontSize', 9);
    
    % Subplot 2: Accuracy
    subplot(2,2,2);
    plot(EbNo_dB, accuracy, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
    grid on;
    xlabel('Eb/No (dB)');
    ylabel('Accuracy (%)');
    title('Meter Reading Accuracy');
    ylim([94, 101]);
    set(gca, 'FontSize', 9);
    
    % Subplot 3: Throughput
    subplot(2,2,3);
    plot(EbNo_dB, throughput/1000, 'm-d', 'LineWidth', 2, 'MarkerSize', 8);
    grid on;
    xlabel('Eb/No (dB)');
    ylabel('Throughput (Kbps)');
    title('System Throughput');
    ylim([0, 260]);
    set(gca, 'FontSize', 9);
    
    % Subplot 4: Meter Pattern
    subplot(2,2,4);
    plot(meterInfo.timeHours, meterInfo.values, 'g-', 'LineWidth', 2);
    grid on;
    xlabel('Time (hours)');
    ylabel(['Consumption (', meterInfo.unit, ')']);
    title([meterInfo.type, ' Meter Pattern']);
    set(gca, 'FontSize', 9);
    
    sgtitle('ZigBee AMR System - Performance Dashboard', 'FontSize', 14, 'FontWeight', 'bold');
    drawnow;
    set(gcf, 'Renderer', 'painters');
    saveas(gcf, 'presentation_figures/figures/dashboard.png');
    saveas(gcf, 'presentation_figures/figures/dashboard.fig');
    fprintf('✓ Saved: dashboard.png\n');
    
    fprintf('\n✅ All figures saved to presentation_figures/figures/\n');
    fprintf('   To view figures in MATLAB, type: figure(1), figure(2), etc.\n');
end