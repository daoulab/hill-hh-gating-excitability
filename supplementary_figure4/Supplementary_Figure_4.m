function Supplementary_Figure_4()
%% Supplementary Figure 4: the time-constant diagnostics.

clear; close all; clc;

%% ===================== settings =====================
F = 'tau.mat';
if ~isfile(F)
    error(['Supplementary Figure 4 needs %s in the current folder (%s).\n' ...
           'Run panelA_prepare.m first.'],F,pwd);
end
S = load(F);

FS      = 9;
navy    = [0.00 0.13 0.28];      % modified (Hill-HH) model
orange  = [0.86 0.45 0.06];      % classical HH
graycol = [0.45 0.45 0.45];
ALPHA   = 0.30;                  % fan line opacity: higher is a darker fan
LOG_Y   = true;                  % time constants span decades
VLIM    = [-120 40];             % mV window worth showing
NFAN    = 80;                   % fits drawn per panel
SHOW_SHIFTED = true;             % the shifted classical tau, drawn as well

V = S.V(:);

%% ========== the two reference curves ==========
% REF (in the data file) is the classical time constant as published by
% Hodgkin and Huxley, untouched. The second reference is that same curve
% slid along the voltage axis by the amount the mutation moves the midpoint,
% dV = published V_half - classical midpoint, which is exactly the target the
% tau-constrained fits are pulled towards. Comparing a fan against both says
% whether the ensemble merely shifted the classical kinetics or reshaped them.
CLS.m = [0.1  25 10 4 18];       % classical HH rate constants, activation
CLS.h = [0.07 20 30 10 1];       % and inactivation
OFF   = S.OFF;

SHIFT = struct();
for g = {'m','h'}
    gg = g{1};
    [a,b] = clsRates(gg,CLS.(gg),V+OFF);
    xinf  = a./(a+b);
    tau   = 1./(a+b);
    mid   = midpoint(V,xinf,gg);                 % where the classical curve is at 0.5
    for c = {'WT','AP'}
        cc = c{1};
        dV = S.PUB.(gg).(cc)(1) - mid;           % how far the published curve sits
        SHIFT.(gg).(cc) = interp1(V+dV,tau,V,'linear','extrap');
        fprintf('  shifted reference: tau_%s %-3s  dV = %+6.2f mV\n',gg,cc,dV);
    end
end

%% ===================== the numbers for the caption =====================
fprintf('Supplementary Figure 4   [%s, Hill source: %s]\n',F,S.HILL_SOURCE);
fprintf('  fits drawn: classical %d, modified %d\n',S.nHH,S.nHL);
cond = {'WT','AP'};
for ic = 1:2
    cc = cond{ic};
    fprintf('  %s  max |m_inf - published| : classical %.4f, modified %.4f\n', cc, ...
        max(max(abs(S.HH.minf.(cc) - S.TGT.m.(cc)'))), ...
        max(max(abs(S.HL.minf.(cc) - S.TGT.m.(cc)'))));
    fprintf('  %s  max |h_inf - published| : classical %.4f, modified %.4f\n', cc, ...
        max(max(abs(S.HH.hinf.(cc) - S.TGT.h.(cc)'))), ...
        max(max(abs(S.HL.hinf.(cc) - S.TGT.h.(cc)'))));
end
fprintf('\n  peak time constant across the ensemble (ms), and the fold spread\n');
fprintf('  %-26s %10s %10s %8s\n','panel','min','max','fold');
rep('classical  tau_m  WT', S.HH.taum.WT);
rep('classical  tau_m  A863P', S.HH.taum.AP);
rep('classical  tau_h  WT', S.HH.tauh.WT);
rep('classical  tau_h  A863P', S.HH.tauh.AP);
rep('modified   tau_m  WT', S.HL.taum.WT);
rep('modified   tau_m  A863P', S.HL.taum.AP);
rep('modified   tau_h  WT', S.HL.tauh.WT);
rep('modified   tau_h  A863P', S.HL.tauh.AP);

%% ===================== the figure =====================
FIGW = 9.6; FIGH = 6.0;                       % inches
fig = figure('Units','inches','Position',[0.4 0.4 FIGW FIGH], ...
             'Color','w','MenuBar','none','ToolBar','none');
set(fig,'PaperUnits','inches','PaperSize',[FIGW FIGH], ...
        'PaperPosition',[0 0 FIGW FIGH]);

% --- layout: two blocks of four. Under each block, in this order: one shared
%     x-axis label, then that row's legend, then the name of the model.
X0 = 0.112;  W = 0.198;  GX = 0.027;          % column geometry
X_NAME = 0.012;                               % the rotated model name
HTOP = 0.300; YTOP = 0.635;                   % classical block
HBOT = 0.300; YBOT = 0.128;                   % modified block
DIV_Y   = 0.500;                              % the grey rule between the blocks
DIV_PAD = 0.028;                              % how far it runs past the panels
LET_DX  = -0.018;                             % panel letters, relative to the
                                              % panel's left edge; less
                                              % negative moves them right
YLAB_Y  = 0.50;                               % y-label height, 0.5 = centred
DY_XLAB = 0.070;                              % the shared x-label, below the panels
DY_LEG  = 0.106;
DY_NAME = 0.058;                              % ABOVE the panels now
BLACK   = [0 0 0];                            % every panel title

panels = { ...
  S.HH.taum.WT, '\tau_m , WT',    orange; ...
  S.HH.taum.AP, '\tau_m , A863P', orange; ...
  S.HH.tauh.WT, '\tau_h , WT',    orange; ...
  S.HH.tauh.AP, '\tau_h , A863P', orange; ...
  S.HL.taum.WT, '\tau_m , WT',    navy;   ...
  S.HL.taum.AP, '\tau_m , A863P', navy;   ...
  S.HL.tauh.WT, '\tau_h , WT',    navy;   ...
  S.HL.tauh.AP, '\tau_h , A863P', navy};

ref = {S.REF.taum,S.REF.taum,S.REF.tauh,S.REF.tauh, ...
       S.REF.taum,S.REF.taum,S.REF.tauh,S.REF.tauh};
shf = {SHIFT.m.WT,SHIFT.m.AP,SHIFT.h.WT,SHIFT.h.AP, ...
       SHIFT.m.WT,SHIFT.m.AP,SHIFT.h.WT,SHIFT.h.AP};

letters = 'abcdefgh';
hRow = cell(1,2);                              % handles for each row's legend
for k = 1:8
    col = mod(k-1,4);
    if k <= 4, y = YTOP; hgt = HTOP; else, y = YBOT; hgt = HBOT; end
    ax = axes('Parent',fig,'Position',[X0+col*(W+GX) y W hgt]); %#ok<LAXES>
    sc = [];
    if SHOW_SHIFTED, sc = shf{k}; end
    hAx = drawFan(ax,V,panels{k,1},panels{k,3},ref{k},sc,graycol,ALPHA,NFAN,LOG_Y,VLIM,FS);
    if col == 0, hRow{1 + (k > 4)} = hAx; end
    title(ax,panels{k,2},'FontSize',FS+0.5,'FontWeight','bold','Color',BLACK);
    if col == 0
        yl = ylabel(ax,'Time constant (ms)','FontSize',FS);
        yl.Units = 'normalized';
        yl.Position(2) = YLAB_Y;      % 0.5 is centred; lower sits further down
    else
        set(ax,'YTickLabel',[]);
    end
    annotation(fig,'textbox',[X0+col*(W+GX)+LET_DX, y+hgt+0.008, 0.04, 0.035], ...
        'String',letters(k),'FontSize',12,'FontWeight','bold', ...
        'EdgeColor','none','Margin',0,'VerticalAlignment','middle');
end

% --- the model name runs vertically down the left of each row, in black;
%     the shared x-axis label and the row's legend sit below the panels
rowY = [YTOP YBOT];
rowH = [HTOP HBOT];
rowName = {'Original HH model','Modified model'};
for r = 1:2
    rotLabel(fig,[X_NAME rowY(r) 0.030 rowH(r)],rowName{r},FS+1.5);

    blockLabel(fig,[X0 rowY(r)-DY_XLAB 4*W+3*GX 0.035], ...
        'Membrane potential (mV)',[0 0 0],FS);

    lg = legend(hRow{r}(1:3), ...
        {'single fit','ensemble median','classical \tau, shifted'}, ...
        'Orientation','horizontal','Box','off','FontSize',FS+0.5);
    lg.ItemTokenSize = [16 9];
    drawnow;                                   % the legend must be sized first
    q = get(lg,'Position');
    set(lg,'Position',[X0 + (4*W+3*GX - q(3))/2, rowY(r)-DY_LEG, q(3), q(4)]);
end

% --- a grey rule between the two blocks, as in the other figures
% it starts a little left of the panel letters and runs just past the last
% column, rather than spanning the whole page
annotation(fig,'line',[X0+LET_DX-DIV_PAD, X0+4*W+3*GX+DIV_PAD*0.4],[DIV_Y DIV_Y], ...
    'Color',[0.75 0.75 0.75],'LineWidth',1.1,'LineStyle','-');

%% ===================== export =====================

drawnow;
exportgraphics(fig,'Supplementary_Figure_4.png','Resolution',600);
% opaque fan lines so the PDF stays vector
setFanOpaque(fig);
drawnow;
print(fig,'Supplementary_Figure_4.pdf','-dpdf','-vector');
fprintf('\n  saved Supplementary_Figure_4.pdf / .png\n');
end

%% ===================== helpers =====================
function rep(name,M)
    pk = max(M,[],2);  pk = pk(isfinite(pk));
    fprintf('  %-26s %10.3g %10.3g %7.1fx\n',name,min(pk),max(pk),max(pk)/min(pk));
end

function h = drawFan(ax,V,M,col,refCurve,shiftCurve,graycol,alpha,nfan,logy,vlim,FS)
% one panel: the ensemble as a fan, its median in bold, and the classical
% time constant both as published and shifted to the published midpoint
    hold(ax,'on');
    h = gobjects(1,4);
    n = size(M,1);
    idx = unique(round(linspace(1,n,min(n,nfan))));
    for i = idx
        pl = plot(ax,V,M(i,:),'-','Color',col,'LineWidth',0.5);
        try, pl.Color(4) = alpha; end                        %#ok<TRYNC>
        if i == idx(1), h(1) = pl; end
    end
    h(2) = plot(ax,V,median(M,1,'omitnan'),'-','Color',col,'LineWidth',1.8);
    % only one reference is drawn: the classical time constant shifted to this
    % condition's published midpoint, which is the "slide the classical
    % kinetics and change nothing else" baseline
    if ~isempty(shiftCurve)
        h(3) = plot(ax,V,shiftCurve,'--','Color',graycol,'LineWidth',1.4);
    else
        h(3) = plot(ax,V,refCurve,'--','Color',graycol,'LineWidth',1.4);
    end
    h(4) = h(3);

    set(ax,'FontSize',FS,'TickDir','out','Box','on','Layer','top');
    xlim(ax,vlim);
    if logy
        set(ax,'YScale','log');
        % the limits must cover the reference curve as well, otherwise a panel
        % whose fan is narrow (f, for instance) cuts the grey dashed line off
        in = V >= vlim(1) & V <= vlim(2);
        allY = M(:,in);
        if ~isempty(shiftCurve)
            allY = [allY; reshape(shiftCurve(in),1,[])];     %#ok<AGROW>
        else
            allY = [allY; reshape(refCurve(in),1,[])];       %#ok<AGROW>
        end
        allY = allY(isfinite(allY) & allY > 0);
        lo = max(1e-4,min(allY));
        hi = max(allY);
        ylim(ax,[lo*0.7 hi*1.4]);
    end
    grid(ax,'on'); set(ax,'GridAlpha',0.12);
    try, ax.Toolbar.Visible = 'off'; end                     %#ok<TRYNC>
end

function [a,b] = clsRates(kind,p,v)
% the classical Hodgkin-Huxley rate functions, in the shifted coordinate the
% rest of the project uses (v already carries the +40 mV offset)
    switch kind
        case {'m','n'}
            a = p(1)*(p(2)-v)./(exp((p(2)-v)/p(3))-1);
            b = p(4)*exp(-v/p(5));
        case 'h'
            a = p(1)*exp(-v/p(2));
            b = p(5)./(1+exp((p(3)-v)/p(4)));
    end
end

function Vm = midpoint(V,xinf,kind)
% voltage at which the steady state crosses 0.5; activation rises with V and
% inactivation falls, so the crossing is found on a monotonic stretch
    x = xinf(:);  V = V(:);
    if strcmp(kind,'h'), x = 1 - x; end
    [xu,iu] = unique(x);
    Vm = interp1(xu,V(iu),0.5,'linear');
end

function rotLabel(fig,pos,txt,fs)
% Vertical text, bold black, centred in the rectangle POS. A textbox
% annotation only gained TextRotation in a later release, so the label is
% drawn as a text object on an invisible axes, which works everywhere.
    ax = axes('Parent',fig,'Position',pos,'Visible','off', ...
              'HandleVisibility','off','XLim',[0 1],'YLim',[0 1]);
    text(ax,0.5,0.5,txt,'Rotation',90,'FontSize',fs,'FontWeight','bold', ...
         'Color',[0 0 0],'HorizontalAlignment','center', ...
         'VerticalAlignment','middle','Clipping','off');
end

function blockLabel(fig,pos,txt,col,fs)
    annotation(fig,'textbox',pos,'String',txt,'FontSize',fs,'FontWeight','bold', ...
        'Color',col,'EdgeColor','none','HorizontalAlignment','center', ...
        'VerticalAlignment','middle','Margin',0);
end

function setFanOpaque(fig)
% Transparency forces MATLAB to rasterise a PDF. For the vector file the fan
% lines are made opaque and very thin instead, which keeps the same look.
    L = findobj(fig,'Type','line');
    for i = 1:numel(L)
        c = L(i).Color;
        if numel(c) == 4 && c(4) < 1
            w = c(4);                                    % the old alpha
            L(i).Color = c(1:3)*w + [1 1 1]*(1-w);       % blend onto white
            L(i).LineWidth = 0.4;
        end
    end
end