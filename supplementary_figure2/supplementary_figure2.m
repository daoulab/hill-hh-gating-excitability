clear all
clc
close all

cache_dir = 'cache_scatter';

files_HH = { ...
    'amplitude_HH_scatter.mat', ...
    'threshold_HH_scatter.mat', ...
    'width_HH_scatter.mat', ...
    'ahp_HH_scatter.mat'};

files_mod = { ...
    'amplitude_scatter_modified.mat', ...
    'threshold_modified_scatter.mat', ...
    'width_modified_scatter.mat', ...
    'ahp_modified_scatter.mat'};

xlabels = {
    'Mean amplitude (mV)'
    'Mean threshold (mV)'
    'Mean width (ms)'
    'Mean AHP (mV)'
};

ylabels = {
    'Amplitude (mV)'
    'Threshold (mV)'
    'Width (ms)'
    'AHP (mV)'
};

labels_HH  = {'a','b','c','d'};
labels_mod = {'e','f','g','h'};

navy   = [0.00 0.13 0.28];
orange = [0.86 0.45 0.06];

%% ---------------- Global style ----------------
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');


figure('Units','centimeters','Position',[2 2 15 35])

t = tiledlayout(4,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
t.OuterPosition = [0.06 0.05 0.88 0.92];
% ===== Column titles =====
annotation('textbox',[0.1 0.95 0.4 0.04], ...
    'String','Original HH Model', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center', ...
    'FontSize',13, ...
    'FontWeight','bold');

annotation('textbox',[0.51 0.95 0.4 0.04], ...
    'String','Modified HH Model', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center', ...
    'FontSize',13, ...
    'FontWeight','bold');

% ===== Plot rows: Original HH left, Modified HH right =====
for k = 1:4

    % ================= Original HH =================
    S = load(fullfile(cache_dir, files_HH{k}));
    ax = nexttile(2*k - 1);
    hold(ax,'on')

    h1_temp = scatter(ax, S.avg_all, S.early1_all, 24, 'o', ...
        'MarkerFaceColor', navy, ...
        'MarkerEdgeColor', navy, ...
        'MarkerFaceAlpha', 0.8);

    h2_temp = scatter(ax, S.avg_all, S.early2_all, 24, 'o', ...
        'MarkerFaceColor', orange, ...
        'MarkerEdgeColor', orange, ...
        'MarkerFaceAlpha', 0.8);

    xmin = min([S.avg_all S.early1_all S.early2_all]);
    xmax = max([S.avg_all S.early1_all S.early2_all]);
    padding = 0.08 * (xmax - xmin);

    xmin_plot = xmin - padding;
    xmax_plot = xmax + padding;

    h3_temp = plot(ax, [xmin_plot xmax_plot], [xmin_plot xmax_plot], ...
        '--k', 'LineWidth', 1.1);

    if k == 1
        h1 = h1_temp;
        h2 = h2_temp;
        h3 = h3_temp;
    end

    xlim(ax,[xmin_plot xmax_plot])
    ylim(ax,[xmin_plot xmax_plot])

    xlabel(ax, xlabels{k},  'FontSize',13,'FontWeight','bold')
    ylabel(ax, ylabels{k},  'FontSize',13,'FontWeight','bold')

    text(ax, -0.30, 1.08, labels_HH{k}, ...
        'Units','normalized', ...
        'FontSize',14, ...
        'FontWeight','bold', ...
        'VerticalAlignment','top')

    grid(ax,'on')
    axis(ax,'square')
    box(ax,'off')
    set(ax,'FontSize',9,'LineWidth',1.0)

    hold(ax,'off')

    % ================= Modified HH =================
    S = load(fullfile(cache_dir, files_mod{k}));
    ax = nexttile(2*k);
    hold(ax,'on')

    scatter(ax, S.avg_all, S.early1_all, 24, 'o', ...
        'MarkerFaceColor', navy, ...
        'MarkerEdgeColor', navy, ...
        'MarkerFaceAlpha', 0.8);

    scatter(ax, S.avg_all, S.early2_all, 24, 'o', ...
        'MarkerFaceColor', orange, ...
        'MarkerEdgeColor', orange, ...
        'MarkerFaceAlpha', 0.8);

    xmin = min([S.avg_all S.early1_all S.early2_all]);
    xmax = max([S.avg_all S.early1_all S.early2_all]);
    padding = 0.08 * (xmax - xmin);

    xmin_plot = xmin - padding;
    xmax_plot = xmax + padding;

    plot(ax, [xmin_plot xmax_plot], [xmin_plot xmax_plot], ...
        '--k', 'LineWidth', 1.1);

    xlim(ax,[xmin_plot xmax_plot])
    ylim(ax,[xmin_plot xmax_plot])

    xlabel(ax, xlabels{k}, 'FontSize',13,'FontWeight','bold')
    ylabel(ax, ylabels{k}, 'FontSize',13,'FontWeight','bold')

    text(ax, -0.30, 1.08, labels_mod{k}, ...
        'Units','normalized', ...
        'FontSize',14, ...
        'FontWeight','bold', ...
        'VerticalAlignment','top')

    grid(ax,'on')
    axis(ax,'square')
    box(ax,'off')
    set(ax,'FontSize',9,'LineWidth',1.0)

    hold(ax,'off')
end

% ===== Common legend =====
lgd = legend([h1 h2 h3], {'Spike 1','Spike 2','y = x'}, ...
    'Orientation','horizontal');

lgd.Box = 'off';
lgd.Position = [0.27 0.01 0.5 0.04];
lgd.FontSize = 11.5;

% ===== Export =====
set(gcf,'PaperUnits','centimeters','PaperSize',[15 35],'PaperPosition',[0 0 15 35]);
print(gcf,'supplementary_figure2.pdf','-dpdf','-vector');
exportgraphics(gcf,'supplementary_figure2.png','Resolution',600)