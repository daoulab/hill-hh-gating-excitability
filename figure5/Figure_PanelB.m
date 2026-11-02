function Figure_PanelB(ax)
%% Figure_PanelB  Panel B of figure 5: implementation sensitivity.

standalone = (nargin < 1) || isempty(ax);

%% ===================== settings =====================
EXP_RATIO = 0.63;        % experimental A863P/WT current-threshold ratio
FS        = 9;
navy      = [0.00 0.13 0.28];
orange    = [0.86 0.45 0.06];
graycol   = [0.45 0.45 0.45];
dash      = [0.25 0.25 0.25];
BW        = 0.55;
% colour per family: 1 = Hill-HH, 2 = classical HH, 3 = consistency check.
% The consistency check is the classical model re-expressed, so it is orange
% too and shares one continuous orange band with the classical strategies.
col       = {navy,orange,orange};
OUTF      = 'PanelB_data.mat';

% how the "single determinate value" marker is explained in the legend
%   'twotone'  one navy dot and one orange dot side by side before the text,
%              so the reader sees the marker is used in both colours
%   'open'     a single hollow dot, text says it is filled in the model colour
SINGLE_LEGEND = 'twotone';

%% ===================== prepare the data =====================
% group 1 = Hill-HH (navy), 2 = classical HH (orange), 3 = consistency check
B = struct('label',{},'group',{},'ratio',{},'src',{});

B(end+1) = item('Hill-HH|direct',1, 7.19/17.69, 'single run (17.69 / 7.19)');

[r,s] = ratiosFrom('Nav17_Hill_results.csv',0.395);
B(end+1) = item('Hill-HH|compl. fixed',1,r,s);

[r,s] = ratiosFrom('Nav17_HillAH_results.csv',[0.346 0.395 0.446]);
B(end+1) = item('Hill-HH|\alpha_h free',1,r,s);

[r,s] = ratiosFrom('Nav17_HH_shift_summary.csv',12.41/37.75);
B(end+1) = item('Classical|voltage shift',2,r,s);

[r,s] = ratiosFrom('Nav17_HH_starts_fixedComp_boltzmann.csv',0.996);
B(end+1) = item('Classical|compl. fixed',2,r,s);

[r,s] = ratiosFrom('Nav17_HH_Boltzmann_summary.csv',[0.53545 0.41261 0.37114]);
B(end+1) = item('Classical|\tau-constrained',2,r,s);

[r,s] = ratiosFrom('Nav17_HH_starts_ensemble_boltz.csv',[0.152 0.298 0.927]);
B(end+1) = item('Classical|all free',2,r,s);

[r,s] = ratiosFrom('Nav17_HH_tau_rescaling_grid.csv',[0.214 0.460 0.991]);
B(end+1) = item('Classical|\tau-rescaled',2,r,s);

B(end+1) = item('Consistency|check',3, 6.75/17.00, 'single run (17.00 / 6.75)');

save(OUTF,'B','EXP_RATIO');

if standalone
    fprintf('Panel B\n');
    fprintf('%-28s %5s %8s %8s %8s   %s\n','strategy','n','median','min','max','source');
    for i = 1:numel(B)
        r = B(i).ratio(isfinite(B(i).ratio));
        fprintf('%-28s %5d %8.3f %8.3f %8.3f   %s\n', ...
            strrep(B(i).label,'|',' '),numel(r),median(r),min(r),max(r),B(i).src);
    end
    fprintf('  saved %s\n',OUTF);
end

%% ===================== draw =====================
if standalone
    fig = figure('Color','w','Units','pixels','Position',[60 60 900 560]);
    ax  = axes('Parent',fig,'Position',[0.10 0.30 0.87 0.66]);
end
hold(ax,'on');

n   = numel(B);
grp = [B.group];

% faint band behind each family. Classical HH and the consistency check share
% one continuous orange band, since the check is the classical model
% re-expressed; only Hill-HH sits on its own.
kNavy = find(grp == 1);
kOrg  = find(grp >= 2);
if ~isempty(kNavy)
    patch(ax,'XData',[min(kNavy)-0.5 max(kNavy)+0.5 max(kNavy)+0.5 min(kNavy)-0.5], ...
             'YData',[-1 -1 3 3],'FaceColor',[0.93 0.95 0.98],'EdgeColor','none');
end
if ~isempty(kOrg)
    patch(ax,'XData',[min(kOrg)-0.5 max(kOrg)+0.5 max(kOrg)+0.5 min(kOrg)-0.5], ...
             'YData',[-1 -1 3 3],'FaceColor',[0.99 0.95 0.90],'EdgeColor','none');
end

% experimental reference
hExp = plot(ax,[0.4 n+0.6],[EXP_RATIO EXP_RATIO],'--','Color',dash,'LineWidth',1.5);

% which strategies have a distribution to summarise
isSingle = false(1,n);
for i = 1:n
    isSingle(i) = numel(B(i).ratio(isfinite(B(i).ratio))) < 2;
end

useBoxchart = exist('boxchart','file') == 2 || exist('boxchart','builtin') == 5;
if useBoxchart
    % one BOXCHART call per colour group, so each family keeps its colour
    for g = 1:3
        k = find(grp == g & ~isSingle);
        if isempty(k), continue; end
        xs = []; ys = [];
        for i = k
            r  = B(i).ratio(isfinite(B(i).ratio));
            xs = [xs; repmat(i,numel(r),1)];   %#ok<AGROW>
            ys = [ys; r(:)];                   %#ok<AGROW>
        end
        h = boxchart(ax,xs,ys,'BoxWidth',BW, ...
                     'BoxFaceColor',col{g},'BoxFaceAlpha',0.25, ...
                     'WhiskerLineColor',col{g},'MarkerColor',col{g}, ...
                     'MarkerSize',3,'LineWidth',1.1);
        try, h.BoxEdgeColor = col{g}; end                   %#ok<TRYNC> R2021a+
        try, h.BoxMedianLineColor = col{g}; end             %#ok<TRYNC> R2023a+
    end
else
    if exist('boxplot','file') ~= 2
        error(['Neither boxchart (R2020b+) nor boxplot (Statistics Toolbox) is ' ...
               'available in this MATLAB installation.']);
    end
    xs = []; ys = [];
    for i = find(~isSingle)
        r  = B(i).ratio(isfinite(B(i).ratio));
        xs = [xs; repmat(i,numel(r),1)];  ys = [ys; r(:)];   %#ok<AGROW>
    end
    boxplot(ax,ys,xs,'Positions',unique(xs),'Widths',BW,'Colors','k','Symbol','.');
end

% strategies that produced one determinate value
for i = find(isSingle)
    r = B(i).ratio(isfinite(B(i).ratio));
    plot(ax,i,r(1),'o','MarkerFaceColor',col{B(i).group}, ...
         'MarkerEdgeColor',col{B(i).group},'MarkerSize',7);
end

%% ===================== axes =====================
lab = cellfun(@(s) strsplit(s,'|'),{B.label},'UniformOutput',false);
lab = cellfun(@(c) sprintf('%s\\newline%s',c{1},c{2}),lab,'UniformOutput',false);
set(ax,'XTick',1:n,'XTickLabel',lab,'TickLabelInterpreter','tex', ...
       'FontSize',FS,'TickDir','out','Box','on','Layer','top');
xlim(ax,[0.4 n+0.6]);
allr = vertcat(B.ratio);  allr = allr(isfinite(allr));
ylim(ax,[0 max(1.05, 1.08*max([allr(:); EXP_RATIO]))]);
ylabel(ax,'A863P / WT rheobase ratio','FontSize',FS+0.5);
grid(ax,'on'); set(ax,'GridAlpha',0.12,'XGrid','off');

%% ===================== legend, below the axes =====================
hs = []; ls = {};
h = patch(ax,'XData',NaN,'YData',NaN,'FaceColor',navy,'FaceAlpha',0.25, ...
          'EdgeColor',navy,'LineWidth',1.1);   hs(end+1)=h; ls{end+1}='Hill-HH';
h = patch(ax,'XData',NaN,'YData',NaN,'FaceColor',orange,'FaceAlpha',0.25, ...
          'EdgeColor',orange,'LineWidth',1.1); hs(end+1)=h; ls{end+1}='classical HH';
switch lower(SINGLE_LEGEND)
    case 'twotone'
        % two dots, then the text. The first entry carries an empty label, so
        % the pair reads as one item and shows that the same marker appears in
        % whichever colour the strategy's model family uses.
        h = plot(ax,NaN,NaN,'o','MarkerFaceColor',navy,'MarkerEdgeColor',navy, ...
                 'MarkerSize',6);              hs(end+1)=h; ls{end+1}='';
        h = plot(ax,NaN,NaN,'o','MarkerFaceColor',orange,'MarkerEdgeColor',orange, ...
                 'MarkerSize',6);              hs(end+1)=h; ls{end+1}='single determinate value';
    otherwise
        h = plot(ax,NaN,NaN,'o','MarkerFaceColor','w','MarkerEdgeColor',graycol, ...
                 'MarkerSize',6,'LineWidth',1.2);
        hs(end+1)=h; ls{end+1}='single determinate value (filled in the model colour)';
end
hs(end+1) = hExp;                              ls{end+1}='experimental ratio';
lg = legend(ax,hs,ls,'Orientation','horizontal','NumColumns',numel(hs), ...
            'Box','off','FontSize',FS);

% tighten the swatch-to-text spacing: this is what sets the gap between the
% navy dot and the orange dot of the two-tone entry (default is [30 18])
try, lg.ItemTokenSize = [12 8]; end                          %#ok<TRYNC>

% centre the legend horizontally under the axes, using its own measured width
drawnow;                         % MATLAB sizes the legend only once it is drawn
p   = get(ax,'Position');
lgp = get(lg,'Position');
set(lg,'Position',[p(1) + (p(3) - lgp(3))/2, max(0.01,p(2)-0.16), lgp(3), lgp(4)]);

%% ===================== export =====================
if standalone
    exportgraphics(fig,'PanelB_sensitivity.pdf','ContentType','vector');
    exportgraphics(fig,'PanelB_sensitivity.png','Resolution',400);
    fprintf('  saved PanelB_sensitivity.pdf / .png\n\n');
    fprintf(['caption note: every strategy shown reproduces the same published\n' ...
             'steady-state curves for A863P; the spread within the classical\n' ...
             'family comes entirely from kinetic choices the experimental papers\n' ...
             'do not specify. The dashed line is the experimental ratio %.2f.\n'],EXP_RATIO);
end
end

%% ===================== helpers =====================
function e = item(label,group,ratio,src)
    e.label = label;  e.group = group;  e.ratio = ratio(:);  e.src = src;
end

function [r,src] = ratiosFrom(csvf,fallback)
% Pull the column of A863P/WT rheobase ratios out of a CSV written by one of
% the simulation scripts, building it from the two rheobase columns when the
% ratio itself was not written out. Falls back to the values already recorded
% in the summary table, and says so.
    r = [];  src = '';
    if isfile(csvf)
        T = readtable(csvf);
        c = pickCol(T,{'Ratio_AP_WT','ratio_AP_WT','Ratio','ratio'});
        if ~isempty(c)
            r = T.(c);
        else
            cW = pickCol(T,{'Rheo_WT','rheo_WT','Rheobase_WT'});
            cA = pickCol(T,{'Rheo_AP','rheo_AP','Rheobase_AP'});
            if ~isempty(cW) && ~isempty(cA), r = T.(cA)./T.(cW); end
        end
        if ~isempty(r)
            r = r(isfinite(r));
            src = sprintf('%s (n=%d)',csvf,numel(r));
        end
    end
    if isempty(r)
        r = fallback(:);
        src = sprintf('FALLBACK, %s not read',csvf);
    end
end

function nm = pickCol(T,cands)
    nm = '';
    for i = 1:numel(cands)
        if ismember(cands{i},T.Properties.VariableNames), nm = cands{i}; return; end
    end
end