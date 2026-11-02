function figure4()
% ===== Figure 4 alternative layout =====
% Rows: Original HH, Modified HH
% Columns: Amplitude, Threshold, Width, AHP
% Y-tick labels shown only once per row

set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultAxesLineWidth',1);
set(groot,'defaultAxesBox','off');

base = 'cache';

features = { ...
    'amplitude','Amplitude (mV)'; ...
    'threshold','Threshold (mV)'; ...
    'width',    'Width (ms)'; ...
    'ahp',      'AHP (mV)'};

fig = figure('Units','inches','Position',[0.4 0.6 10.5 6.2],'Color','w');

tl = tiledlayout(fig,2,4, ...
    'TileSpacing','compact', ...
    'Padding','compact');

for c = 1:4

    S_HH  = load(fullfile(base,[features{c,1} '_HH.mat']));
    S_MOD = load(fullfile(base,[features{c,1} '_MOD.mat']));

    clim_col = [min([S_HH.M(:); S_MOD.M(:)]), max([S_HH.M(:); S_MOD.M(:)])];

    % ===== Top row: Original HH =====
    ax1 = nexttile(tl,c);
    showLabels = (c == 1);
    draw_one(ax1,S_HH,clim_col,'HH',showLabels);

    t=title(ax1,features{c,2}, ...
        'FontWeight','bold', ...
        'FontName','Arial','FontSize',13);
   drawnow
pos = get(t,'Position');
pos(2) = pos(2) + 0.07;
set(t,'Position',pos);
    if c == 1
        ylabel(ax1,'Original HH','FontWeight','bold','FontSize',15);
        ax1.YLabel.Units = 'normalized';
        ax1.YLabel.Position(1) = -0.3;
    end

    % ===== Bottom row: Modified HH =====
    ax2 = nexttile(tl,4+c);
    showLabels = (c == 1);
    draw_one(ax2,S_MOD,clim_col,'MOD',showLabels);

    if c == 1
        ylabel(ax2,'Modified HH','FontWeight','bold','FontSize',15);
        ax2.YLabel.Units = 'normalized';
        ax2.YLabel.Position(1) = -0.3;
    end

    % one colorbar per feature column
    cb = colorbar(ax2,'Location','southoutside');
    cb.TickDirection = 'out';
    cb.FontName = 'Arial';
    cb.FontSize = 11;
    cb.FontWeight="bold";
end

colormap(fig,'hot');

set(fig,'PaperUnits','inches','PaperSize',[10.5 6.2],'PaperPosition',[0 0 10.5 6.2]);
print(fig,'figure4.pdf','-dpdf','-vector');
exportgraphics(fig,'figure4.png','Resolution',600);
end

function draw_one(ax, S, clim_row, modelType, showLabels)

imagesc(ax,S.M);
set(ax,'YDir','reverse','YAxisLocation','left');
axis(ax,'tight');
caxis(ax,clim_row);
xticks(ax,[]);

% elongated heatmaps
pbaspect(ax,[1 1.4 1]);

ax.FontName = 'Arial';
ax.FontSize = 11;
ax.TickDir = 'out';
ax.Layer = 'top';
ax.FontWeight='bold';

% Remove right-side tick marks
ax.YAxisLocation = 'left';

nrows = size(S.M,1);

if showLabels
    yticks(ax,1:nrows);      % keep ticks only where labels appear
else
    yticks(ax,[]);           % remove ticks from other panels
end

if strcmp(modelType,'HH')
    labels = { ...
        '$A_m$','$B_m$','$C_m$','$D_m$','$E_m$', ...
        '$A_n$','$B_n$','$C_n$','$D_n$','$E_n$', ...
        '$A_h$','$B_h$','$C_h$','$D_h$','$E_h$', ...
        '$I_{\mathrm{app}}$'};
    sep_positions = [5.5 10.5 15.5];

elseif strcmp(modelType,'MOD')
    labels = { ...
        '$a_m$','$a_n$','$a_h$', ...
        '$\ell_m$','$\ell_n$','$\ell_h$', ...
        '$V_{\mathrm{half},m}$','$V_{\mathrm{half},n}$','$V_{\mathrm{half},h}$', ...
        '$I_{\mathrm{app}}$'};
    sep_positions = [3.5 6.5 9.5];
end

if showLabels
    yticklabels(ax,labels);
else
    yticklabels(ax,[]);
end

% Make sure no right-side ticks appear
ax.YAxisLocation = 'left';
ax.Box = 'off';

set(ax,'TickLabelInterpreter','latex');

hold(ax,'on');

xLimits = xlim(ax);

for s = sep_positions
    yline(ax,s,'-', ...
        'Color',[0.15 0.15 0.15], ...
        'LineWidth',1);
end

if isfield(S,'opt_x') && isfield(S,'opt_y')
    plot(ax,S.opt_x,S.opt_y,'k*', ...
        'MarkerSize',5, ...
        'LineWidth',0.8);
end

xlim(ax,xLimits);
hold(ax,'off');

end