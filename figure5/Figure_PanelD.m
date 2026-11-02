function Figure_PanelD(ax)
%% Figure_PanelD  Panel D of figure 5: three-mutation benchmark.


standalone = (nargin < 1) || isempty(ax);

%% ===================== the data =====================
mut = {'A863P','F1449V','A1632G'};

% experimental current threshold, WT -> mutant, in pA
%   A863P   Harty et al.
%   F1449V  Dib-Hajj et al., Brain 2005;128:1847-1854 (text and Fig. 6E;
%           the summary table of the same paper gives 208 -> 121 pA, which
%           would put the experimental ratio at 0.582 instead of 0.750)
%   A1632G  J Neurosci 2016;36(28):7511-7522
expWT   = [248.0, 124.1, 158.0];
expMUT  = [157.0,  93.1, 102.0];

% Hill-HH low-information prediction, rheobase in uA/cm^2, both shifts applied
predWT  = [17.69, 17.31, 13.78];
predMUT = [ 7.19,  7.97,  5.00];

exp_ratio  = expMUT  ./ expWT;      % experimental current-threshold ratio
pred_ratio = predMUT ./ predWT;     % predicted rheobase ratio

save('PanelD_data.mat','mut','expWT','expMUT','predWT','predMUT', ...
     'exp_ratio','pred_ratio');

if standalone
    fprintf('Panel D\n');
    fprintf('%-8s %22s %22s\n','mutation','experimental ratio','predicted ratio');
    for i = 1:numel(mut)
        fprintf('%-8s %10.3f  (%5.1f/%5.1f pA) %10.3f  (%5.2f/%5.2f uA/cm^2)\n', ...
            mut{i},exp_ratio(i),expMUT(i),expWT(i), ...
            pred_ratio(i),predMUT(i),predWT(i));
    end
    fprintf('  saved PanelD_data.mat\n');
end

%% ===================== settings =====================
FS     = 9;
navy   = [0.00 0.13 0.28];
graycol= [0.45 0.45 0.45];

if standalone
    fig = figure('Color','w','Units','pixels','Position',[60 60 700 520]);
    ax  = axes('Parent',fig,'Position',[0.13 0.26 0.84 0.70]);
end
hold(ax,'on');

%% ===================== the bars =====================
vals = [exp_ratio(:) pred_ratio(:)];
hb = bar(ax,vals,'grouped','BarWidth',0.84);
hb(1).FaceColor = graycol;  hb(1).EdgeColor = 'none';
hb(2).FaceColor = navy;     hb(2).EdgeColor = 'none';

% value above every bar
off = 0.035;
for i = 1:numel(mut)
    text(ax,i-0.21,exp_ratio(i)+off,sprintf('%.2f',exp_ratio(i)), ...
         'HorizontalAlignment','center','FontSize',FS-0.5,'Color',graycol);
    text(ax,i+0.21,pred_ratio(i)+off,sprintf('%.2f',pred_ratio(i)), ...
         'HorizontalAlignment','center','FontSize',FS-0.5,'Color',navy);
end

%% ===================== axes =====================
set(ax,'XTick',1:numel(mut),'XTickLabel',mut,'FontSize',FS, ...
       'TickDir','out','Box','on','Layer','top');
xlim(ax,[0.4 numel(mut)+0.6]);
ylim(ax,[0 max(0.95, 1.18*max(vals(:)))]);
ylabel(ax,'Mutant / WT threshold or rheobase ratio','FontSize',FS+0.5);
grid(ax,'on'); set(ax,'GridAlpha',0.12,'XGrid','off');

% the note asked for, inside the panel
text(ax,0.47,max(0.95,1.18*max(vals(:)))*0.965,'Lower ratio indicates greater excitability', ...
     'FontSize',FS-0.5,'FontAngle','italic','Color',[0.3 0.3 0.3], ...
     'HorizontalAlignment','left','VerticalAlignment','top');

%% ===================== legend, below the axes =====================
lg = legend(ax,{'Experimental current-threshold ratio', ...
                'Hill-HH predicted rheobase ratio'}, ...
            'Orientation','horizontal','Box','off','FontSize',FS);
p = get(ax,'Position');
lg.Position = [p(1) max(0.01,p(2)-0.135) p(3) 0.060];

%% ===================== export =====================
if standalone
    exportgraphics(fig,'PanelD_benchmark.pdf','ContentType','vector');
    exportgraphics(fig,'PanelD_benchmark.png','Resolution',400);
    fprintf('  saved PanelD_benchmark.pdf / .png\n\n');
    fprintf(['caption note: the experimental bars are mutant/WT current-threshold\n' ...
             'ratios measured in DRG neurons; the predicted bars are mutant/WT\n' ...
             'rheobase ratios from the Hill-HH low-information mapping. The model\n' ...
             'reproduces the direction of the phenotype for all three mutations\n' ...
             'while predicting a larger threshold reduction than the one measured.\n']);
end
end