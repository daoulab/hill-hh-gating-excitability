function Supplementary_Figure_6()
%% Figure_Supp6  Supplementary Figure 6: the accepted-fit diagnostics.

clear; close all; clc;

%% ===================== settings =====================
FC = 'Nav17_HH_starts_ensemble_boltz.mat';
FH = 'Nav17_HillAH_results.mat';
EXP_RATIO = 0.63;

FS      = 9;
navy    = [0.00 0.13 0.28];
orange  = [0.86 0.45 0.06];
graycol = [0.45 0.45 0.45];
dash    = [0.25 0.25 0.25];
SORT_BY_RATIO = false;   % true ranks the fits instead of using fit number
% the x-axis label; 'Fit index (random start)' is the other natural wording
XLABEL   = 'Accepted fit index';
TITLE_Y  = 1.04;         % 1.00 sits on the axes top; higher lifts the title

%% ===================== the data =====================
if ~isfile(FC), error('Supplementary Figure 6 needs %s in %s.',FC,pwd); end
if ~isfile(FH), error('Supplementary Figure 6 needs %s in %s.',FH,pwd); end

C = load(FC,'acc','ratio','rhWT','rhAP');
accC = logical(C.acc(:));
E(1).name  = 'Classical HH, all parameters free';
E(1).ratio = C.ratio(accC);
E(1).rhWT  = C.rhWT(accC);
E(1).rhMUT = C.rhAP(accC);
E(1).col   = orange;
E(1).nTot  = numel(accC);

H = load(FH,'acc','RHEO');
accH = logical(H.acc(:));
E(2).name  = 'Hill-HH, \alpha_h parameters free';
E(2).rhWT  = H.RHEO(accH,1);
E(2).rhMUT = H.RHEO(accH,2);
E(2).ratio = E(2).rhMUT ./ E(2).rhWT;
E(2).col   = navy;
E(2).nTot  = numel(accH);

fprintf('  saved Supplementary_Figure_6.pdf / .png\n');
for i = 1:2
    r = E(i).ratio(isfinite(E(i).ratio));
    E(i).med = median(r);  E(i).lo = min(r);  E(i).hi = max(r);
    E(i).n   = numel(r);
    fprintf('  %-36s %3d of %3d accepted\n',E(i).name,E(i).n,E(i).nTot);
    fprintf('    ratio  median %.3f   range %.3f - %.3f   spread %.1f-fold\n', ...
            E(i).med,E(i).lo,E(i).hi,E(i).hi/E(i).lo);
    fprintf('    rheobase medians  WT %.2f   mutant %.2f uA/cm^2\n', ...
            median(E(i).rhWT),median(E(i).rhMUT));
    fprintf('    fits on each side of the measured %.2f : %d below, %d above\n', ...
            EXP_RATIO,sum(r < EXP_RATIO),sum(r >= EXP_RATIO));
end

YL = [0 1.05*max([E(1).hi E(2).hi EXP_RATIO])];   % one scale for both rows

%% ===================== the figure =====================
FIGW = 8.6; FIGH = 5.8;
fig = figure('Units','inches','Position',[0.4 0.4 FIGW FIGH], ...
             'Color','w','MenuBar','none','ToolBar','none');
set(fig,'PaperUnits','inches','PaperSize',[FIGW FIGH], ...
        'PaperPosition',[0 0 FIGW FIGH]);

X0 = 0.105;  W = 0.865;                            % the panels span the page
HROW = 0.345;  YROW = [0.605 0.108];   % the gap between the rows is
                                       % YROW(1) - (YROW(2)+HROW)
% where each legend's top-right corner sits inside its panel, [across, up]
LEG = [0.995 0.99;        % a   classical HH
       0.995 0.99];       % b   Hill-HH
letters = 'ab';

for i = 1:2
    y = YROW(i);
    r = E(i).ratio(isfinite(E(i).ratio));
    if SORT_BY_RATIO, r = sort(r,'ascend'); end
    k = (1:numel(r))';          % the fit number, in the order they were run

    % ---------------- the sorted scatter ----------------
    ax = axes('Parent',fig,'Position',[X0 y W HROW]); hold(ax,'on');
    hExp = plot(ax,[0 numel(r)+1],[EXP_RATIO EXP_RATIO],'--','Color',dash,'LineWidth',1.4);
    hMed = plot(ax,[0 numel(r)+1],[E(i).med E(i).med],'-','Color',E(i).col,'LineWidth',1.0);
    plot(ax,k,r,'o','MarkerFaceColor',E(i).col,'MarkerEdgeColor','none','MarkerSize',3.2);
    xlim(ax,[0 numel(r)+1]); ylim(ax,YL);
    ylabel(ax,'A863P / WT rheobase ratio','FontSize',FS);
    if SORT_BY_RATIO
        xlabel(ax,'Accepted fits, ranked by predicted ratio','FontSize',FS);
    else
        xlabel(ax,XLABEL,'FontSize',FS);
    end
    set(ax,'FontSize',FS,'TickDir','out','Box','on','Layer','top');
    grid(ax,'on'); set(ax,'GridAlpha',0.12);
    try, ax.Toolbar.Visible = 'off'; end                     %#ok<TRYNC>

    ht = title(ax,E(i).name,'FontSize',FS+0.5,'FontWeight','bold','Color',[0 0 0]);
    ht.Units = 'normalized';
    ht.Position(2) = TITLE_Y;

    % both panels carry the same legend, pinned to the top-right corner
    lg = legend(ax,[hExp hMed],{'experimental ratio','ensemble median'}, ...
                'FontSize',FS-1.5,'Box','off','Location','northeast');
    lg.ItemTokenSize = [14 8];
    placeIn(lg,ax,LEG(i,1),LEG(i,2));

    annotation(fig,'textbox',[X0-0.075, y+HROW+0.010, 0.04, 0.035], ...
        'String',letters(i),'FontSize',12,'FontWeight','bold', ...
        'EdgeColor','none','Margin',0,'VerticalAlignment','middle');

end

%% ===================== export =====================
drawnow;
exportgraphics(fig,'Supplementary_Figure_6.png','Resolution',400);
exportgraphics(fig,'Supplementary_Figure_6.pdf','ContentType','vector');
fprintf('  saved Supp6_accepted_fits.pdf / .png\n');
end

function placeIn(lg,ax,fx,fy)
% Pin a legend inside its own axes: its top-right corner goes to the point
% (fx, fy) of the panel box, as fractions from the panel's left and bottom.
    if isempty(lg) || ~isgraphics(lg), return; end
    drawnow;
    p = get(ax,'Position');  q = get(lg,'Position');
    set(lg,'Position',[p(1) + fx*p(3) - q(3), p(2) + fy*p(4) - q(4), q(3), q(4)]);
end