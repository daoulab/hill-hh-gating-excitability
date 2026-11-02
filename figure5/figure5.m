%% figure5.m
clear; close all; clc;

%% ===================== figure size, in inches =====================
FIGW = 10.2;            
FIGH =  9.6;
ASP  = FIGH/FIGW;       

fig = figure('Units','inches','Position',[0.4 0.4 FIGW FIGH], ...
             'Color','w','MenuBar','none','ToolBar','none');
set(fig,'PaperUnits','inches','PaperSize',[FIGW FIGH], ...
        'PaperPosition',[0 0 FIGW FIGH]);

%% ===================== LAYOUT =====================
% --- panel a, the schematic: top left, the tall one
L.A      = [0.050 0.375 0.450 0.580];

% panel c's title is carried by the figure caption, not the panel
SHOW_C_TITLE = false;

% --- panel c's colour bar
CB_GAP     = 0.012;     % space between the map and the bar, figure units
CB_WIDTH   = 0.013;     % thickness of the bar
CB_STRETCH = 1.10;      % 1 = exactly the map's height; >1 makes it longer

% --- the right-hand column: c above d
RIGHT_X  = 0.560;       % left edge of panel d
C_SHIFT  = 0.048;       % panel c sits this much further right than d
C_BOTTOM = 0.655;
C_HEIGHT = 0.295;
D_BOTTOM = 0.415;
D_HEIGHT = 0.195;
D_EXTRA  = 0.050;       % d is widened by the strip c gives to its colour bar

% panel c is square: its width follows from its height
C_WIDTH  = C_HEIGHT*ASP;
L.C      = [RIGHT_X+C_SHIFT C_BOTTOM C_WIDTH C_HEIGHT];
L.D      = [RIGHT_X D_BOTTOM C_WIDTH+D_EXTRA D_HEIGHT];

% --- panel b, across the bottom: raised so its legend clears the tick labels
L.B      = [0.070 0.118 0.895 0.205];

% --- where each panel's legend sits (bottom edge, normalized figure units)
LEGY.B   = 0.016;
LEGY.D   = 0.360;

% --- type sizes set here rather than inside the panel files
PANELA_FONT_SCALE = 0.82;   % <1 shrinks every label of the schematic
LEGEND_FS         = 9;      % both legends
% swatch width per legend, [line marker]; the default is [30 18]. It sets both
% how wide the whole legend runs and how far the navy dot sits from the orange
% one in panel b's two-tone entry, so b is given a roomier token than d.
LEGEND_TOKEN_D    = [10  7];

% Panel b's legend is built as three legends in a row.
%   group 1  the two colour patches      entries 1-2
%   group 2  the navy and orange dots    entries 3-4 (3 has an empty label)
%   group 3  the dashed experimental line entry 5
% Each group gets its own token width, so the dots can almost touch while the
% dash runs long and the patches stay a sensible size.
B_GROUPS = {[1 2],[3 4],5};
B_TOKENS = {[26 18],[6 10],[50 18]};
B_GAP    = 0.0075;           % space between the groups, figure units
% the token width is also the gap between b's navy and orange dots, so the
% width lost by narrowing it is put back as trailing spaces on the labels:
% that spreads the entries apart without pushing the two dots apart
% spacing is now set by B_GAP between the groups, so no padding is needed;
% raise this only to push the entries inside a group further apart
LEGEND_PAD_B      = 0;      % spaces appended to each of b's labels

% --- the panel letters
% a and b share one vertical line, c and d another, so the four letters line
% up in two columns instead of each hanging off its own axes.
LET_X_L   = L.A(1) - 0.023;      % the column for a and b
LET_X_R   = L.D(1) - 0.04;      % c and d column, now above d's y-label
LET_FS    = 16;                  % same as all other figures (was 13)
LET_DY    = 0.038;               % height above the axes top, for b and d
LET_DY_A  = 0.013;               % a sits lower still
LET_DY_C  = 0.017;               % c a little lower than b and d
LET_FS    = 13;

% panel d is narrow in the composite, so its y-label is shortened here rather
% than in Figure_PanelD.m, which keeps the full wording when run on its own
D_YLABEL = 'Mutant / WT ratio';

%% ===================== draw the panels =====================
% panel a, the schematic
axA = axes('Parent',fig,'Position',L.A);
panelA_schematic_draw(axA);
scaleText(axA,PANELA_FONT_SCALE);

% panel c, the heat map
axC = axes('Parent',fig,'Position',L.C);
Figure_PanelC(axC);
if ~SHOW_C_TITLE, title(axC,''); end   % dropped here, not in Figure_PanelC.m
fitColorbarToMap(axC,FIGW,FIGH,CB_GAP,CB_WIDTH,CB_STRETCH);

% panel d, the benchmark
axD = axes('Parent',fig,'Position',L.D);
[~,lgD] = withNewLegend(@() Figure_PanelD(axD), fig);
ylabel(axD,D_YLABEL);
% the bars give the legend tall rectangular swatches; square ones read better
% at this size, so the legend is rebuilt from two square markers
lgD = squareSwatchLegend(axD,lgD, ...
        {[0.45 0.45 0.45],[0.00 0.13 0.28]}, ...
        {'Experimental current-threshold ratio','Hill-HH predicted rheobase ratio'});

% panel b, the sensitivity plot
axB = axes('Parent',fig,'Position',L.B);
[~,lgB] = withNewLegend(@() Figure_PanelB(axB), fig);

% the hover toolbar is interactive furniture, not part of the figure
for a = [axA axB axC axD]
    try, a.Toolbar.Visible = 'off'; end                      %#ok<TRYNC>
    try, disableDefaultInteractivity(a); end                 %#ok<TRYNC>
end

%% ===================== the legends =====================
% Each panel function sizes and places its legend assuming it owns the whole
% figure. In the composite they are shrunk and moved here: centred under
% their own axes, at the height set in LEGY above.
% the type size applies to both; d also takes its token here, while b's three
% token widths are set by splitLegend further down
for lg = [lgD lgB]
    if isempty(lg) || ~isgraphics(lg), continue; end
    set(lg,'FontSize',LEGEND_FS);
end
if ~isempty(lgD) && isgraphics(lgD)
    try, lgD.ItemTokenSize = LEGEND_TOKEN_D; end             %#ok<TRYNC>
end
% pad b's labels so the entries spread out while the dot pair stays tight
if ~isempty(lgB) && isgraphics(lgB) && LEGEND_PAD_B > 0
    s = get(lgB,'String');
    pad = repmat(' ',1,LEGEND_PAD_B);
    for i = 1:numel(s)
        if ~isempty(strtrim(s{i})), s{i} = [s{i} pad]; end
    end
    set(lgB,'String',s);
end

% b's legend becomes three legends in a row, each with its own token width
lgBs = splitLegend(fig,axB,lgB,B_GROUPS,B_TOKENS,LEGEND_FS);

drawnow;   % a legend knows its own width only once it has been drawn
centreLegend(lgD,axD,LEGY.D);
centreRow(lgBs,axB,LEGY.B,B_GAP);

%% ===================== the panel letters =====================
letter(fig,axA,'a',LET_X_L,LET_DY_A,LET_FS);
letter(fig,axB,'b',LET_X_L,LET_DY  ,LET_FS);
letter(fig,axC,'c',LET_X_R,LET_DY_C,LET_FS);
letter(fig,axD,'d',LET_X_R,LET_DY  ,LET_FS);

%% ===================== export =====================
drawnow;
fitColorbarToMap(axC,FIGW,FIGH,CB_GAP,CB_WIDTH,CB_STRETCH);   % again, after everything settled
drawnow;
print(fig,'figure5.pdf','-dpdf','-vector');
exportgraphics(fig,'figure5.png','Resolution',600);
fprintf('saved MainFigure.pdf / MainFigure.png  (%.1f x %.1f in)\n',FIGW,FIGH);

%% ===================== helpers =====================
function scaleText(ax,s)
% Multiply the font size of every label drawn inside an axes. Used for the
% schematic, whose type sizes are written into panelA_schematic_draw.m for
% a full-page panel and are too large once it shares the figure.
    if s == 1, return; end
    t = findobj(ax,'Type','text');
    for i = 1:numel(t)
        t(i).FontSize = max(4, t(i).FontSize*s);
    end
    ax.FontSize = max(4, ax.FontSize*s);
end

function lg = squareSwatchLegend(ax,lgOld,cols,labels)
% Replace a legend whose swatches are tall bar rectangles with one built from
% square markers, keeping the same wording. Panel d's own file is untouched.
    if ~isempty(lgOld) && isgraphics(lgOld), delete(lgOld); end
    hold(ax,'on');
    h = gobjects(1,numel(cols));
    for i = 1:numel(cols)
        h(i) = plot(ax,NaN,NaN,'s','MarkerFaceColor',cols{i}, ...
                    'MarkerEdgeColor',cols{i},'MarkerSize',8,'LineStyle','none');
    end
    lg = legend(ax,h,labels,'Orientation','horizontal','Box','off');
end

function fitColorbarToMap(ax,figW,figH,gap,width,stretch)
% Make panel c's colour bar as tall as the heat map. The axes is 'axis
% square', so the map is a square centred inside the axes rectangle; the bar
% is set to that square's height, not the rectangle's. STRETCH scales that
% height about the map's centre, so 1.10 gives a bar a tenth longer than the
% map, overhanging equally top and bottom.
    if nargin < 6 || isempty(stretch), stretch = 1; end
    cb = [];
    f  = ancestor(ax,'figure');
    cbs = findobj(f,'Type','ColorBar');
    for i = 1:numel(cbs)
        if isequal(cbs(i).Axes,ax), cb = cbs(i); break; end
    end
    if isempty(cb), return; end

    p = get(ax,'Position');
    % the square's side, worked out in inches so the two axes units agree
    sideIn = min(p(3)*figW, p(4)*figH);
    hNorm  = sideIn/figH;                 % its height in figure units
    wNorm  = sideIn/figW;                 % its width  in figure units
    y0 = p(2) + (p(4)-hNorm)/2;           % the square is centred in the axes
    x0 = p(1) + (p(3)-wNorm)/2;
    hBar = hNorm*stretch;                 % the bar may be longer than the map
    yBar = y0 - (hBar-hNorm)/2;           % kept centred on the map
    set(cb,'Position',[x0 + wNorm + gap, yBar, width, hBar]);
end

function [out,lg] = withNewLegend(fcn,fig)
% Run a panel function and hand back whichever legend it created, so the
% composite can resize and move it. Identifying it this way means the panel
% files stay exactly as they are.
    before = findobj(fig,'Type','Legend');
    out = [];
    fcn();
    after  = findobj(fig,'Type','Legend');
    newOnes = setdiff(after,before);
    if isempty(newOnes), lg = gobjects(0); else, lg = newOnes(1); end
end

function lgs = splitLegend(fig,ax,lg,groups,tokens,fs)
% Break one legend into several, so each group of entries can have its own
% swatch width. One ItemTokenSize governs a whole legend, and panel b needs a
% short one for the two dots and a long one for the dashed line, which a
% single legend cannot do.
%
% GROUPS is a cell of index vectors into the original entry order; TOKENS
% holds one ItemTokenSize per group. Entries not listed in any group are
% dropped. The first group keeps the real axes; the others are hung on
% invisible axes of their own, since an axes can carry only one legend.
    lgs = gobjects(0);
    if isempty(lg) || ~isgraphics(lg), return; end

    h = lg.PlotChildren;  s = lg.String;
    delete(lg);

    for g = 1:numel(groups)
        k = groups{g};
        k = k(k >= 1 & k <= numel(h));
        if isempty(k), continue; end

        if g == 1
            axG = ax;                      % the first group keeps the axes
            hG  = h(k);
        else
            axG = axes('Parent',fig,'Position',get(ax,'Position'), ...
                       'Visible','off','HandleVisibility','off');
            hold(axG,'on');
            hG = copyProxies(axG,h(k));    % the others get copies to point at
        end

        lgG = legend(axG,hG,s(k),'Orientation','horizontal', ...
                     'NumColumns',numel(k),'Box','off','FontSize',fs);
        try, lgG.ItemTokenSize = tokens{min(g,numel(tokens))}; end   %#ok<TRYNC>
        lgs(end+1) = lgG;                                            %#ok<AGROW>
    end
end

function hc = copyProxies(ax,h)
% Redraw legend proxies on another axes: lines and markers as a line object,
% patches as a patch, keeping colour, style and width.
    hc = gobjects(1,numel(h));
    for i = 1:numel(h)
        src = h(i);
        if isa(src,'matlab.graphics.primitive.Patch')
            hc(i) = patch(ax,'XData',NaN,'YData',NaN, ...
                          'FaceColor',src.FaceColor,'FaceAlpha',src.FaceAlpha, ...
                          'EdgeColor',src.EdgeColor,'LineWidth',src.LineWidth);
        else
            hc(i) = plot(ax,NaN,NaN,'LineStyle',src.LineStyle,'Color',src.Color, ...
                         'LineWidth',src.LineWidth,'Marker',src.Marker, ...
                         'MarkerSize',src.MarkerSize, ...
                         'MarkerFaceColor',src.MarkerFaceColor, ...
                         'MarkerEdgeColor',src.MarkerEdgeColor);
        end
    end
end

function centreRow(lgs,ax,ybottom,gap)
% Lay several legends out in one row and centre the row on the axes, with
% their text sitting on a common line.
    lgs = lgs(isgraphics(lgs));
    if isempty(lgs), return; end
    if numel(lgs) == 1, centreLegend(lgs(1),ax,ybottom); return; end

    p = get(ax,'Position');
    w = zeros(1,numel(lgs));  hh = zeros(1,numel(lgs));
    for i = 1:numel(lgs)
        q = get(lgs(i),'Position');  w(i) = q(3);  hh(i) = q(4);
    end
    total = sum(w) + gap*(numel(lgs)-1);
    x  = p(1) + (p(3)-total)/2;
    yc = ybottom + max(hh)/2;
    for i = 1:numel(lgs)
        set(lgs(i),'Units','normalized');
        set(lgs(i),'Position',[x, yc-hh(i)/2, w(i), hh(i)]);
        x = x + w(i) + gap;
    end
end

function centreLegend(lg,ax,ybottom)
% Centre a legend horizontally on its own axes and set its bottom edge.
    if isempty(lg) || ~isgraphics(lg), return; end
    p   = get(ax,'Position');
    lgp = get(lg,'Position');
    set(lg,'Units','normalized');
    set(lg,'Position',[p(1) + (p(3)-lgp(3))/2, ybottom, lgp(3), lgp(4)]);
end

function letter(fig,ax,txt,x,dy,fs)
% Panel letter. X is an absolute figure coordinate, shared by the two panels
% of a column so they line up; DY is the height above that panel's own top.
% X is clamped so a letter can never fall off the page.
    p = get(ax,'Position');
    x = max(0.004, x);
        annotation(fig,'textbox',[x, p(2)+p(4)+dy-0.03, 0.04, 0.03], ...
        'String',txt,'FontName','Arial','FontSize',fs,'FontWeight','bold', ...
        'EdgeColor','none','HorizontalAlignment','left', ...
        'VerticalAlignment','middle','Margin',0);
end