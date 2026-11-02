%% ===== Plot 3x3 excitability regime maps from saved data =====
clear; close all; clc;

cache_dir = 'cache_excitability';

%% Global style
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');
set(groot,'defaultLineLineWidth',1.1);

%% Colormap
regime_colors = [
    0.80 0.80 0.80
    0.98 0.62 0.16
    0.00 0.13 0.28
    0.00 0.62 0.45
    0.50 0.20 0.10
];

param_names = {
    'a_m'
    'a_n'
    'a_h'
    'vhalf_m'
    'vhalf_n'
    'vhalf_h'
    'hill_n_m'
    'hill_n_n'
    'hill_n_h'
};
labels = {
    '$a_m$'
    '$a_n$'
    '$a_h$'
    '$V_{\mathrm{half},m}$'
    '$V_{\mathrm{half},n}$'
    '$V_{\mathrm{half},h}$'
    '$\ell_m$'
    '$\ell_n$'
    '$\ell_h$'
};

panel_letters = 'abcdefghi';
ref_values = containers.Map( ...
    {'a_m','a_n','a_h','vhalf_m','vhalf_n','vhalf_h','hill_n_m','hill_n_n','hill_n_h'}, ...
    {-81.1593, -18.3915, -93.4064, 24.5661, 8.9938, 29.2459, 11.4235, 2, 16.3345});

%% Figure canvas
fig = figure('Units','inches','Position',[0.4 0.4 9.8 8.0],'Color','w');
t = tiledlayout(fig,3,3,'TileSpacing','compact','Padding','loose');

for k = 1:9

    ax = nexttile(k); 
    hold(ax,'on');

    data_file = fullfile(cache_dir, [param_names{k} '_regime_map.mat']);
    S = load(data_file);

    imagesc(ax, S.xvals, S.Iapp_range, S.regime_map);
    x_ref = ref_values(param_names{k});

    xline(ax, x_ref, '--w', ...
     'LineWidth',1.4);

    
    xlim(ax, [S.xvals(1) S.xvals(end)]);
    set(ax,'YDir','normal');

    colormap(ax, regime_colors);
    caxis(ax, [1 5]);

        if k <= 6
        xlab = [labels{k} ' (mV)'];
    else
        xlab = labels{k};
    end
    xlabel(ax, xlab, 'Interpreter','latex','FontSize',13);
    ylabel(ax, '$I_{\mathrm{app}}$ ($\mu$A/cm$^2$)', 'Interpreter','latex','FontSize',13);
    text(ax, -0.32, 1.15, panel_letters(k), ...
        'Units','normalized', ...
        'FontName','Arial', ...
        'FontWeight','bold', ...
        'FontSize',16, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','top');

    ax.TickDir = 'out';
    ax.Layer = 'top';
end

%% Row group labels

annotation(fig,'textbox',[0.04 0.75 0.12 0.04], ...
    'String','Shift parameters', ...
    'LineStyle','none', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Rotation',90, ...
    'HorizontalAlignment','center');

annotation(fig,'textbox',[0.04 0.47 0.12 0.04], ...
    'String','Half-activation parameters', ...
    'LineStyle','none', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Rotation',90, ...
    'HorizontalAlignment','center');

annotation(fig,'textbox',[0.04 0.16 0.12 0.04], ...
    'String','Hill coefficients', ...
    'LineStyle','none', ...
    'FontWeight','bold', ...
    'FontSize',13, ...
    'Rotation',90, ...
    'HorizontalAlignment','center');

%% Shared colorbar
cb = colorbar;
cb.LineWidth = 0.9;
cb.Layout.Tile = 'east';
cb.Ticks = 1:5;
cb.TickLabels = {'silent','single spike','tonic firing','spontaneous firing','depolarization block'};
cb.FontSize = 11;
%% Export
set(fig,'PaperUnits','inches','PaperSize',[9.8 8.0],'PaperPosition',[0 0 9.8 8.0]);
print(fig,'figure3.pdf','-dpdf','-vector');
exportgraphics(fig,'figure3.png','Resolution',600);