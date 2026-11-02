function Figure_PanelC(ax)
%% Figure_PanelC  Panel C of figure 5: the tau-rescaling heat map.


standalone = (nargin < 1) || isempty(ax);

%% ===================== settings =====================
EXP_RATIO  = 0.63;        % experimental A863P/WT current-threshold ratio
SHOW_TITLE = true;        % set false if the composite figure carries the text
FS         = 9;
TITLE_TXT  = ['Classical HH: same m_\infty and h_\infty , ' ...
              'different \tau , different predictions'];

CSVF = 'Nav17_HH_tau_rescaling_grid.csv';
MATF = 'Nav17_HH_tau_rescaling_results.mat';
OUTF = 'PanelC_data.mat';

%% ===================== prepare the data =====================
[phi,Ratio,Rwt,Rap,src] = loadGrid(CSVF,MATF);

ErrPct = 100*(Ratio - EXP_RATIO)/EXP_RATIO;

r = Ratio(isfinite(Ratio));
stats.nCells     = numel(Ratio);
stats.nValid     = numel(r);
stats.min        = min(r);
stats.median     = median(r);
stats.max        = max(r);
stats.spreadFold = max(r)/min(r);
stats.fracBelow1 = mean(r < 1);
i1 = find(abs(phi-1) < 1e-9,1);
if ~isempty(i1), stats.atPhi1 = Ratio(i1,i1); else, stats.atPhi1 = NaN; end
stats.errMin = 100*(min(r) - EXP_RATIO)/EXP_RATIO;
stats.errMax = 100*(max(r) - EXP_RATIO)/EXP_RATIO;

save(OUTF,'phi','Ratio','Rwt','Rap','ErrPct','EXP_RATIO','stats','src');

if standalone
    fprintf('Panel C   [source: %s]\n',src);
    fprintf('  grid             : %d x %d, phi from %.3g to %.3g\n', ...
            numel(phi),numel(phi),min(phi),max(phi));
    fprintf('  cells with a ratio: %d of %d\n',stats.nValid,stats.nCells);
    fprintf('  ratio min/med/max : %.3f / %.3f / %.3f   (%.1f-fold spread)\n', ...
            stats.min,stats.median,stats.max,stats.spreadFold);
    fprintf('  ratio at phi = 1  : %.3f\n',stats.atPhi1);
    fprintf('  ratio < 1 in      : %.0f%% of cells\n',100*stats.fracBelow1);
    fprintf('  experimental %.2f -> error %+.1f%% to %+.1f%%\n', ...
            EXP_RATIO,stats.errMin,stats.errMax);
    fprintf('  saved %s\n',OUTF);
end

%% ===================== draw =====================
if standalone
    fig = figure('Color','w','Units','pixels','Position',[60 60 780 600]);
    ax  = axes('Parent',fig,'Position',[0.13 0.13 0.62 0.72]);
end
hold(ax,'on');

n   = numel(phi);
him = imagesc(ax,Ratio);
axis(ax,'xy'); axis(ax,'square');
set(him,'AlphaData',isfinite(Ratio));                 % non-firing cells stay grey
set(ax,'Color',[0.85 0.85 0.85],'XTick',1:n,'YTick',1:n, ...
       'XTickLabel',compose('%.3g',phi),'YTickLabel',compose('%.3g',phi), ...
       'TickLength',[0 0],'FontSize',FS,'Layer','top','Box','on');
colormap(ax,parula);

cmin = min(Ratio(:),[],'omitnan');  cmax = max(Ratio(:),[],'omitnan');
if ~(cmax > cmin), cmax = cmin + 1e-3; end
clim(ax,[cmin cmax]);

xlabel(ax,'\phi_h   (inactivation rate scale)','FontSize',FS+0.5);
ylabel(ax,'\phi_m   (activation rate scale)','FontSize',FS+0.5);
if SHOW_TITLE
    ht = title(ax,TITLE_TXT,'FontSize',FS+1,'FontWeight','bold');
    ht.Units = 'normalized';
    ht.Position(1) = 0.51;
    ht.Position(2) = 1.03;        % 1.00 = right on the axes top; raise to lift
end

% the value in every cell
for i = 1:n
    for j = 1:n
        if isfinite(Ratio(i,j))
            if Ratio(i,j) < (cmin+cmax)/2, tc = 'w'; else, tc = 'k'; end
            text(ax,j,i,sprintf('%.2f',Ratio(i,j)),'HorizontalAlignment','center', ...
                 'VerticalAlignment','middle','Color',tc, ...
                 'FontWeight','bold','FontSize',FS-0.5);
        else
            text(ax,j,i,'n.s.','HorizontalAlignment','center', ...
                 'VerticalAlignment','middle','Color',[0.3 0.3 0.3],'FontSize',FS-0.5);
        end
    end
end

% reference cell (phi_m, phi_h) = (1,1): black square outline
if ~isempty(i1)
    rectangle(ax,'Position',[i1-0.5 i1-0.5 1 1],'EdgeColor','k','LineWidth',2.2);
end

% pin the limits to the image itself: 'hold on' stops imagesc from doing this,
% and the rectangle above would otherwise widen the axes and show the grey
% background as a margin on either side
xlim(ax,[0.5 n+0.5]);  ylim(ax,[0.5 n+0.5]);

% colour bar, kept outside the axes so the square stays square
cb = colorbar(ax);
cb.Label.String   = 'A863P / WT rheobase ratio';
cb.Label.FontSize = FS+0.5;
cb.FontSize       = FS;
p = get(ax,'Position');
cb.Position = [p(1)+p(3)+0.025 p(2) 0.030 p(4)];
set(ax,'Position',p);

%% ===================== export =====================
if standalone
    exportgraphics(fig,'PanelC_heatmap.pdf','ContentType','vector');
    exportgraphics(fig,'PanelC_heatmap.png','Resolution',400);
    fprintf('  saved PanelC_heatmap.pdf / .png\n\n');
    fprintf(['caption note: every cell reproduces the same published steady-state\n' ...
             'curves and differs only in its time constants; the red square marks\n' ...
             '(phi_m, phi_h) = (1,1) in black. The experimental ratio is %.2f, which\n' ...
             'the classical model can match only through kinetic choices the\n' ...
             'experimental data do not specify.\n'],EXP_RATIO);
end
end

%% ===================== helpers =====================
function [phi,Ratio,Rwt,Rap,src] = loadGrid(CSVF,MATF)
% Rebuild the (phi_m, phi_h) grid from whichever simulation output is present.
    if isfile(CSVF)
        T   = readtable(CSVF);
        phi = unique([T.phi_m; T.phi_h])';
        n   = numel(phi);
        Ratio = nan(n); Rwt = nan(n); Rap = nan(n);
        for k = 1:height(T)
            i = find(abs(phi - T.phi_m(k)) < 1e-9,1);    % row index: phi_m
            j = find(abs(phi - T.phi_h(k)) < 1e-9,1);    % col index: phi_h
            Ratio(i,j) = T.Ratio_AP_WT(k);
            Rwt(i,j)   = T.Rheo_WT(k);
            Rap(i,j)   = T.Rheo_AP(k);
        end
        src = CSVF;
        return;
    end
    if isfile(MATF)
        v = who('-file',MATF);
        if all(ismember({'PHI_GRID','Ratio'},v))
            S = load(MATF);
            phi   = S.PHI_GRID(:)';
            Ratio = S.Ratio;
            if ismember('Rwt',v), Rwt = S.Rwt; else, Rwt = nan(size(Ratio)); end
            if ismember('Rap',v), Rap = S.Rap; else, Rap = nan(size(Ratio)); end
            src = MATF;
            return;
        end
    end
    error(['Panel C needs %s (preferred) or %s with PHI_GRID and Ratio.\n' ...
           'Neither was found in %s. Run Nav17_HH_tau_rescaling_Boltzmann.m first.'], ...
           CSVF,MATF,pwd);
end