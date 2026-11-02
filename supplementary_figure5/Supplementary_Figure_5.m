function Supplementary_Figure_5()
%% Supplementary Figure 5: F1449V and A1632G, panel by panel.


clear; close all; clc;

%% ===================== settings =====================
IAPP   = 40;                 % the step current used for the trace panels
FS     = 9;
navy   = [0.00 0.13 0.28];
orange = [0.86 0.45 0.06];
graycol= [0.45 0.45 0.45];

REST_OFFSET = 40;
Dh = 0.07;  Eh = 20;         % classical alpha_h, shared
Dm = 4;     Em = 18;         % classical beta_m, retained
Dn = 0.125; En = 80;         % classical beta_n, retained
C = 1; gNa = 120; ENa = 50; gK = 36; EK = -77; gL = 0.6; EL = -54.4;
tspan = [0 200];  from_ = 50;  to_ = 150;
init_cond = [-50, 0.04, 0.81, 0.32];

% --- the two mutations, exactly as in their own firing-pattern scripts
M(1).name  = 'F1449V';
M(1).csv   = 'FV_fI_curve_second_method.csv';
M(1).mWT   = [-250.0000, 30.6760, -15.2000];
M(1).mMUT  = [-250.0000, 28.1319, -22.8000];
M(1).hWT   = [-150, 4.4, -57.5];
M(1).hMUT  = [-150, 3.5, -39];
M(1).npar  = [-110, 6.333, -15];

M(2).name  = 'A1632G';
M(2).csv   = 'AG_fI_curve_second_method.csv';
M(2).mWT   = [-250.0000, 28.3461, -20.6800];
M(2).mMUT  = [-250.0000, 25.7905, -27.1700];
M(2).hWT   = [-130, 3.4, -96.5760];
M(2).hMUT  = [-120, 2, -70.0242];
M(2).npar  = [-130, 7, -21];

V = linspace(-140,40,1201)';
alpha_h = @(v) Dh.*exp(-(v+REST_OFFSET)./Eh);

%% ===================== simulate and load =====================
opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
fprintf('Supplementary Figure 5\n');
for i = 1:2
    % --- steady states
    M(i).minfWT  = hillIncSafe(M(i).mWT ,V);
    M(i).minfMUT = hillIncSafe(M(i).mMUT,V);
    bhWT  = hillIncSafe(M(i).hWT ,V);
    bhMUT = hillIncSafe(M(i).hMUT,V);
    M(i).hinfWT  = alpha_h(V)./(alpha_h(V)+bhWT);
    M(i).hinfMUT = alpha_h(V)./(alpha_h(V)+bhMUT);

    % --- traces, same model and stimulus as Nav17_firing_pattern.m
    for c = 1:2
        if c == 1, mp = M(i).mWT;  hp = M(i).hWT;  else, mp = M(i).mMUT; hp = M(i).hMUT; end
        [t,sol] = ode113(@(t,y) rhs(t,y,IAPP,mp,hp,M(i).npar,REST_OFFSET, ...
                    Dm,Em,[Dh Eh],Dn,En,C,gNa,ENa,gK,EK,gL,EL,from_,to_), ...
                    tspan,init_cond,opts);
        if c == 1, M(i).tWT = t; M(i).vWT = sol(:,1);
        else,      M(i).tMUT = t; M(i).vMUT = sol(:,1);
        end
    end

    % --- f-I curve
    if ~isfile(M(i).csv)
        error('Supplementary Figure 5 needs %s in %s.',M(i).csv,pwd);
    end
    T = readtable(M(i).csv);
    M(i).I = T.Iapp_uA_cm2;  M(i).fWT = T.f_WT_Hz;  M(i).fMUT = T.f_AP_Hz;

    % --- the numbers worth quoting in the caption
    fprintf('  %-7s spikes at Iapp = %g : WT %d, mutant %d\n',M(i).name,IAPP, ...
            countSpikes(M(i).tWT,M(i).vWT,from_,to_), ...
            countSpikes(M(i).tMUT,M(i).vMUT,from_,to_));
    iWT  = firstNonZero(M(i).I,M(i).fWT);
    iMUT = firstNonZero(M(i).I,M(i).fMUT);
    fprintf('  %-7s first current with firing : WT %g, mutant %g uA/cm^2\n', ...
            M(i).name,iWT,iMUT);
    fprintf('  %-7s peak rate : WT %g Hz, mutant %g Hz; mutant blocks after %g uA/cm^2\n', ...
            M(i).name,max(M(i).fWT),max(M(i).fMUT),blockCurrent(M(i).I,M(i).fMUT));
end
save('Supp5_traces.mat','M','IAPP');

%% ===================== the figure =====================
FIGW = 9.8; FIGH = 6.4;
fig = figure('Units','inches','Position',[0.4 0.4 FIGW FIGH], ...
             'Color','w','MenuBar','none','ToolBar','none');
set(fig,'PaperUnits','inches','PaperSize',[FIGW FIGH], ...
        'PaperPosition',[0 0 FIGW FIGH]);

X0 = 0.115;  W = 0.245;  GX = 0.065;
HROW = 0.315;  YROW = [0.620 0.165];
X_NAME = 0.012;
% where each legend's top-right corner sits inside its own panel, as
% fractions of the panel box: [across, up]
% One row per mutation, so panel a and panel d can be set apart:
%   row 1 = F1449V (a, b, c), row 2 = A1632G (d, e, f)
LEG_SS = [0.69 0.99;       % a   steady state
          0.66 0.99];      % d
LEG_TR = [1.00 0.99;       % b   voltage trace
          1.00 0.99];      % e
LEG_FI = [0.99 0.99;       % c   f-I curve
          0.99 0.99];      % f
LET_DX = -0.045;  LET_DY = 0.030;
letters = 'abcdef';

for i = 1:2
    y = YROW(i);
    k0 = (i-1)*3;

    % ---------- steady state ----------
    ax = axes('Parent',fig,'Position',[X0 y W HROW]); hold(ax,'on');
    hmWT  = plot(ax,V,M(i).minfWT ,'-' ,'Color',navy  ,'LineWidth',1.6);
    hmMUT = plot(ax,V,M(i).minfMUT,'-' ,'Color',orange,'LineWidth',1.6);
    plot(ax,V,M(i).hinfWT ,'--','Color',navy  ,'LineWidth',1.6);
    plot(ax,V,M(i).hinfMUT,'--','Color',orange,'LineWidth',1.6);
    xlim(ax,[-130 40]); ylim(ax,[0 1.02]);
    ylabel(ax,'Steady-state value','FontSize',FS);
    if i == 2, xlabel(ax,'Membrane potential (mV)','FontSize',FS); end
    tidy(ax,FS);
    % The only genuinely empty region is the right-hand middle: past about
    % 0 mV, m_inf has saturated at 1 and h_inf has fallen to 0, so nothing is
    % drawn between them. Two entries fit there; the line styles are left to
    % the caption rather than doubling the legend's height.
    lg = legend(ax,{'m_\infty, WT',['m_\infty, ' M(i).name], ...
                    'h_\infty, WT',['h_\infty, ' M(i).name]}, ...
                'FontSize',FS-2,'Box','off','Location','east');
    lg.ItemTokenSize = [12 7];
    placeIn(lg,ax,LEG_SS(i,1),LEG_SS(i,2));
    panelLetter(fig,ax,letters(k0+1),LET_DX,LET_DY);

    % ---------- voltage trace ----------
    ax = axes('Parent',fig,'Position',[X0+W+GX y W HROW]); hold(ax,'on');
    plot(ax,M(i).tWT ,M(i).vWT ,'-','Color',navy  ,'LineWidth',1.0);
    plot(ax,M(i).tMUT,M(i).vMUT,'-','Color',orange,'LineWidth',1.0);
    xlim(ax,tspan); ylim(ax,[-80 90]);
    ylabel(ax,'Membrane potential (mV)','FontSize',FS);
    if i == 2, xlabel(ax,'Time (ms)','FontSize',FS); end
    tidy(ax,FS);
    lgT = legend(ax,{'WT',M(i).name},'FontSize',FS-2,'Box','off', ...
                 'Location','northeast');
    lgT.ItemTokenSize = [12 7];
    placeIn(lgT,ax,LEG_TR(i,1),LEG_TR(i,2));
           y_bar = 65;
    panelLetter(fig,ax,letters(k0+2),LET_DX,LET_DY);   
           y_bar = 65;       
    plot(ax,[from_ to_],[y_bar y_bar],'Color','k','LineWidth',1.4, ...
         'HandleVisibility','off');
    text(ax,(from_+to_)/2,y_bar+4,sprintf('I_{app} = %g \\muA/cm^2',IAPP), ...
         'Color','k','FontSize',FS,'FontWeight','normal', ...
         'HorizontalAlignment','center','VerticalAlignment','bottom');

    % ---------- f-I curve ----------
    ax = axes('Parent',fig,'Position',[X0+2*(W+GX) y W HROW]); hold(ax,'on');
    plot(ax,M(i).I,M(i).fWT ,'-o','Color',navy  ,'MarkerFaceColor',navy  , ...
         'MarkerSize',2.6,'LineWidth',1.2);
    plot(ax,M(i).I,M(i).fMUT,'-o','Color',orange,'MarkerFaceColor',orange, ...
         'MarkerSize',2.6,'LineWidth',1.2);
    xlim(ax,[0 max(M(i).I)]); ylim(ax,[0 1.12*max(M(i).fMUT)]);
    ylabel(ax,'Firing frequency (Hz)','FontSize',FS);
    if i == 2, xlabel(ax,'I_{app} (\muA/cm^2)','FontSize',FS); end
    tidy(ax,FS);
    lg = legend(ax,{'WT',M(i).name},'FontSize',FS-2,'Box','off','Location','northeast');
    lg.ItemTokenSize = [12 7];
    placeIn(lg,ax,LEG_FI(i,1),LEG_FI(i,2));
    panelLetter(fig,ax,letters(k0+3),LET_DX,LET_DY);

    % ---------- the mutation name, down the left ----------
    rotLabel(fig,[X_NAME y 0.030 HROW],M(i).name,FS+1.5);
end

% a grey rule between the two mutations
annotation(fig,'line',[X0+LET_DX-0.02, X0+3*W+2*GX],[0.540 0.540], ...
    'Color',[0.75 0.75 0.75],'LineWidth',1.1);

%% ===================== export =====================

drawnow;
exportgraphics(fig,'Supplementary_Figure_5.png','Resolution',600);
print(fig,'Supplementary_Figure_5.pdf','-dpdf','-vector');
fprintf('  saved Supplementary_Figure_5.pdf / .png and Supp5_traces.mat\n');
end

%% ===================== helpers =====================
function placeIn(lg,ax,fx,fy)
% Pin a legend inside its own axes: its top-right corner goes to the point
% (fx, fy) of the panel box, measured as fractions from the panel's left and
% bottom. The legend has to be drawn before MATLAB knows its size.
    if isempty(lg) || ~isgraphics(lg), return; end
    drawnow;
    p = get(ax,'Position');  q = get(lg,'Position');
    set(lg,'Position',[p(1) + fx*p(3) - q(3), p(2) + fy*p(4) - q(4), q(3), q(4)]);
end

function tidy(ax,FS)
    set(ax,'FontSize',FS,'TickDir','out','Box','on','Layer','top');
    grid(ax,'on'); set(ax,'GridAlpha',0.12);
    try, ax.Toolbar.Visible = 'off'; end                     %#ok<TRYNC>
end

function panelLetter(fig,ax,txt,dx,dy)
    p = get(ax,'Position');
    annotation(fig,'textbox',[max(0.004,p(1)+dx), p(2)+p(4)+dy-0.03, 0.04, 0.035], ...
        'String',txt,'FontSize',12,'FontWeight','bold','EdgeColor','none', ...
        'Margin',0,'VerticalAlignment','middle');
end

function rotLabel(fig,pos,txt,fs)
    ax = axes('Parent',fig,'Position',pos,'Visible','off', ...
              'HandleVisibility','off','XLim',[0 1],'YLim',[0 1]);
    text(ax,0.5,0.5,txt,'Rotation',90,'FontSize',fs,'FontWeight','bold', ...
         'Color',[0 0 0],'HorizontalAlignment','center', ...
         'VerticalAlignment','middle','Clipping','off');
end

function n = countSpikes(t,v,from_,to_)
    in = t >= from_ & t <= to_;
    tv = t(in); vv = v(in);
    n = sum(vv(2:end-1) > 0 & vv(2:end-1) > vv(1:end-2) & vv(2:end-1) >= vv(3:end));
    if isempty(tv), n = 0; end
end

function I = firstNonZero(I,f)
    k = find(f > 0,1,'first');
    if isempty(k), I = NaN; else, I = I(k); end
end

function Ib = blockCurrent(I,f)
% the current at which the mutant's rate collapses (the last point before a
% drop of more than half)
    d = diff(f);
    k = find(d < -0.5*max(f),1,'first');
    if isempty(k), Ib = NaN; else, Ib = I(k); end
end

function y = hillIncSafe(p,Vq)
    a = p(1); l = p(2); Vhalf = p(3);
    Vq = Vq(:);
    g = Vq - a;  w = Vhalf - a;
    y = (sign(g).^fix(l) .* abs(g).^l) ./ ...
        (sign(w).^fix(l) .* abs(w).^l + sign(g).^fix(l) .* abs(g).^l);
    y(Vq < a) = 0;
end

function dsol = rhs(t,sol,Iapp,mpar,hpar,npar,REST_OFFSET, ...
                    Dm,Em,alphaHpar,Dn,En,C,gNa,ENa,gK,EK,gL,EL,from_,to_)
    V = sol(1); m = sol(2); h = sol(3); n = sol(4);

    m_inf   = hillIncSafe(mpar,V);
    beta_m  = Dm*exp(-(V+REST_OFFSET)/Em);
    alpha_m = beta_m*m_inf/(1-m_inf);

    Dh = alphaHpar(1); Eh = alphaHpar(2);
    alpha_h = Dh*exp(-(V+REST_OFFSET)/Eh);
    beta_h  = hillIncSafe(hpar,V);

    n_inf   = hillIncSafe(npar,V);
    beta_n  = Dn*exp(-(V+REST_OFFSET)/En);
    alpha_n = beta_n*n_inf/(1-n_inf);

    iNa = gNa*(m^3)*h*(V-ENa);
    iK  = gK*(n^4)*(V-EK);
    iL  = gL*(V-EL);

    if from_ <= t && t <= to_, iap = Iapp; else, iap = 0; end

    dsol = [(-iNa - iK - iL + iap)/C;
            alpha_m*(1-m) - beta_m*m;
            alpha_h*(1-h) - beta_h*h;
            alpha_n*(1-n) - beta_n*n];
end