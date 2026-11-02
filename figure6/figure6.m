
close all; clc;

% ---------------- Colors ----------------
navy         = [0.00 0.13 0.28];
teal = [0.00 0.50 0.60];
orange_fill  = [0.98 0.62 0.16];
orange_edge  = [0.86 0.45 0.06];
orange2_fill = [1.00 0.82 0.40];
orange2_edge = orange_edge;

% ---------------- Global style ----------------
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');

% ---------------- Figure ----------------
fig = figure('Units','inches','Position',[0.5 0.5 9.0 8.5],'Color','w');
t = tiledlayout(fig,2,3,'Padding','loose','TileSpacing','loose');

xlabel(t,'Membrane potential, $V$ (mV)','Interpreter','latex','FontSize',14,'FontWeight','bold');

markerSize = 24;
edgeWidth  = 0.8;

V_fit_top    = linspace(-50,110,1200);
V_fit_bottom = linspace(-150,150,1200);

% ---------------- HH equations ----------------
alphaN = @(v) 0.01*(10 - v) ./ (exp((10 - v)/10) - 1);
betaN  = @(v) 0.125*exp((-v)/80);

alphaM = @(v) 0.1*(25 - v) ./ (exp((25 - v)/10) - 1);
betaM  = @(v) 4*exp(-v/18);

alphaH = @(v) 0.07*exp((-v)/20);
betaH  = @(v) 1 ./ (1 + exp((30 - v)/10));

% ---------------- Sigmoid ----------------
sigmoid = @(p,V) (sign(V+p(1)).^fix(p(2)).*abs(V+p(1)).^p(2)) ./ ...
                 (sign(p(3)+p(1)).^fix(p(2)).*abs(p(3)+p(1)).^p(2) + ...
                  sign(V+p(1)).^fix(p(2)).*abs(V+p(1)).^p(2));

%% ===================== TOP ROW =====================

% ---------- (A) ----------
ax1 = nexttile(1);
D = readtable('n_positive.xlsx');
V = D.Voltage; a = D.alpha_n; b = D.beta_n;

hA_data = scatter(V,a,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth);
hold on
hB_data = scatter(V,b,markerSize,'s','filled', ...
    'MarkerFaceColor',orange2_fill,'MarkerEdgeColor',orange2_edge, ...
    'LineWidth',edgeWidth);

hA_fit = plot(V_fit_top,alphaN(V_fit_top),'Color',navy,'LineWidth',1.8);
hB_fit = plot(V_fit_top,betaN(V_fit_top),'Color',teal,'LineWidth',1.8);

%ylabel('Rate constant (ms$^{-1}$)','Interpreter','latex');
xlim([-50 110]);
ylim([0 1.0]);
grid on

% gate-specific label near y-axis
text(ax1,-0.25,0.5,'$n$ rate constant (ms$^{-1}$)', ...
    'Units','normalized','Rotation',90, ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'Interpreter','latex','FontSize',13,'FontWeight','bold');

% ---------- (B) ----------
ax2 = nexttile(2);
D = readtable('m_positive.xlsx');
V = D.Voltage; a = D.alpha_m; b = D.beta_m;

scatter(V,a,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');
hold on
scatter(V,b,markerSize,'s','filled', ...
    'MarkerFaceColor',orange2_fill,'MarkerEdgeColor',orange2_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');

plot(V_fit_top,alphaM(V_fit_top),'Color',navy,'LineWidth',1.8,'HandleVisibility','off');
plot(V_fit_top,betaM(V_fit_top),'Color',teal,'LineWidth',1.8,'HandleVisibility','off');

xlim([-10 110]);
ylim([0 10]);
grid on

text(ax2,-0.22,0.5,'$m$ rate constant (ms$^{-1}$)', ...
    'Units','normalized','Rotation',90, ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'Interpreter','latex','FontSize',13,'FontWeight','bold');

% ---------- (C) ----------
ax3 = nexttile(3);
D = readtable('h_positive.xlsx');
V = D.Voltage; a = D.alpha_h; b = D.beta_h;

scatter(V,a,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');
hold on
scatter(V,b,markerSize,'s','filled', ...
    'MarkerFaceColor',orange2_fill,'MarkerEdgeColor',orange2_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');

plot(V_fit_top,alphaH(V_fit_top),'Color',navy,'LineWidth',1.8,'HandleVisibility','off');
plot(V_fit_top,betaH(V_fit_top),'Color',teal,'LineWidth',1.8,'HandleVisibility','off');

xlim([-30 110]);
ylim([0 1.5]);
grid on

text(ax3,-0.22,0.5,'$h$ rate constant (ms$^{-1}$)', ...
    'Units','normalized','Rotation',90, ...
    'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'Interpreter','latex','FontSize',13,'FontWeight','bold');

%% ===================== BOTTOM ROW =====================

% ---------- (D) n_inf ----------
ax4 = nexttile(4);
data1 = readtable('n_positive.xlsx');
voltage = data1.Voltage;
n_inf = data1.n_inf;

p0 = [200,4.6,20];
lb = [0,2,-100];
ub = [1000,20,10];
params1 = lsqcurvefit(sigmoid,p0,voltage,n_inf,lb,ub);
fit1 = sigmoid(params1,V_fit_bottom);
fit1(V_fit_bottom < -params1(1)) = 0;

hPts = scatter(voltage,n_inf,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth);
hold on
hFit = plot(V_fit_bottom,fit1,'Color',navy,'LineWidth',1.8);

ylabel('$n_{\infty}$','Interpreter','latex','FontSize',15,'FontWeight','bold');
xlim([-150 150]);
ylim([0 1.02]);
grid on

% ---------- (E) m_inf ----------
ax5 = nexttile(5);
data2 = readtable('m_positive.xlsx');
voltage = data2.Voltage;
m_inf = data2.m_inf;

p0 = [220,10,-25];
lb = [-300,0,-100];
ub = [300,25,100];
params2 = lsqcurvefit(sigmoid,p0,voltage,m_inf,lb,ub);
fit2 = sigmoid(params2,V_fit_bottom);
fit2(V_fit_bottom < -params2(1)) = 0;

scatter(voltage,m_inf,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');
hold on
plot(V_fit_bottom,fit2,'Color',navy,'LineWidth',1.8,'HandleVisibility','off');

ylabel('$m_{\infty}$','Interpreter','latex','FontSize',15,'FontWeight','bold');
xlim([-150 150]);
ylim([0 1.02]);
grid on

% ---------- (F) beta_h ----------
ax6 = nexttile(6);
data3 = readtable('beta_h.xlsx');
voltage = data3.Voltage;
bh = data3.beta_h;

p0 = [200,4.6,20];
lb = [-300,2,-100];
ub = [600,30,100];
params3 = lsqcurvefit(sigmoid,p0,voltage,bh,lb,ub);
fit3 = sigmoid(params3,V_fit_bottom);
fit3(V_fit_bottom < -params3(1)) = 0;

scatter(voltage,bh,markerSize,'filled', ...
    'MarkerFaceColor',orange_fill,'MarkerEdgeColor',orange_edge, ...
    'LineWidth',edgeWidth,'HandleVisibility','off');
hold on
plot(V_fit_bottom,fit3,'Color',navy,'LineWidth',1.8,'HandleVisibility','off');

ylabel('$\beta_h$ (ms$^{-1}$)','Interpreter','latex','FontSize',15,'FontWeight','bold');
xlim([-150 150]);
ylim([0 1.02]);
grid on

%% ===================== CLEANUP =====================
ax2.YLabel.String = '';
ax3.YLabel.String = '';
set([ax1 ax2 ax3 ax4 ax5 ax6],'Layer','top');

set([ax1 ax2 ax3 ax4 ax5 ax6], ...
    'XGrid','on','YGrid','on','GridLineStyle','-','GridAlpha',0.08);



%% ===================== PANEL LABELS =====================
drawnow;

labels = {'a','b','c','d','e','f'};
axesList = [ax1 ax2 ax3 ax4 ax5 ax6];

for i = 1:6
    annotation(fig,'textbox', ...
        [axesList(i).Position(1)-0.06, ...
         axesList(i).Position(2)+axesList(i).Position(4)-0.005, ...
         0.03, 0.03], ...
        'String',labels{i}, ...
        'LineStyle','none', ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','top', ...
        'FontWeight','bold', ...
        'FontSize',16);
end

%% ===================== ROW LABELS =====================

annotation(fig,'textbox', ...
    [0.315 0.96 0.40 0.03], ...
    'String','Classical HH rate functions', ...
    'LineStyle','none', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',13);

annotation(fig,'textbox', ...
    [0.265 0.48 0.52 0.03], ...
    'String','Hill fits to HH-derived quantities', ...
    'LineStyle','none', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold', ...
    'FontSize',13);
annotation(fig,'line',[0.08 0.92],[0.515 0.515], ...
    'Color',[0.85 0.85 0.85], ...
    'LineStyle','-');

%% ===================== ONE LEGEND PER ROW =====================

% Top row legend
lg1 = legend(ax2,[hA_data hB_data hA_fit hB_fit], ...
    {'$\alpha$ rate data','$\beta$ rate data','$ \alpha$ fit','$ \beta$ fit'}, ...
    'Interpreter','latex', ...
    'Orientation','horizontal', ...
    'NumColumns',4, ...
    'Location','southoutside');
lg1.Box = 'off';
lg1.FontSize = 13;

% Bottom row legend
lg2 = legend(ax5,[hPts hFit],{'Data','Hill fit'}, ...
    'Interpreter','latex', ...
    'Orientation','horizontal', ...
    'NumColumns',2, ...
    'Location','southoutside');
lg2.Box = 'off';
lg2.FontSize = 13;

%% ===================== EXPORT =====================
set(fig,'PaperUnits','inches','PaperSize',[9.0 8.5],'PaperPosition',[0 0 9.0 8.5]);
print(fig,'figure6.pdf','-dpdf','-vector');
exportgraphics(fig,'figure6.png','Resolution',600);