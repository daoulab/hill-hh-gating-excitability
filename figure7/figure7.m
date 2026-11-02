%% ===== Figure: Comparison of Hill, tanh, erf, arctan, and Boltzmann fits =====
clear; close all; clc;

%% ---------------- Colors ----------------
orange = [0.86 0.45 0.06];   % Data
navy   = [0.00 0.13 0.28];   % Hill (main result)

C.yellow = [0.93 0.69 0.13];
C.gray   = [0.4 0.4 0.4];
C.teal   = [0.10 0.60 0.50];
C.purple = [0.49 0.18 0.56];   % Boltzmann

col_tanh      = C.yellow;
col_erf       = C.gray;
col_arctan    = C.teal;
col_boltzmann = C.purple;

%% ---------------- Global style ----------------
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');

%% ---------------- Figure canvas ----------------
fig = figure('Units','inches','Position',[0.5 0.5 10 4.6],'Color','w');

ax1 = axes('Position',[0.07 0.22 0.26 0.70]); hold(ax1,'on');
ax2 = axes('Position',[0.39 0.22 0.26 0.70]); hold(ax2,'on');
ax3 = axes('Position',[0.71 0.22 0.26 0.70]); hold(ax3,'on');

V_fit = linspace(-140,150,1200);

%% =========================================================
%% Panel A: n_inf
%% =========================================================
axes(ax1); hold on;
data = readtable('n_positive.xlsx');
Vn = data.Voltage;
Yn = data.n_inf;

tanh_n      = @(V) 0.5 * (1 + tanh((V - 7.0492) / 46.2768));
arctan_n    = @(V) 0.5 * (1 + 0.63662 * atan((V - 9.3982) / 18.4845));
erf_n       = @(V) 0.5 * (1 + erf((V - 8.0087) / 50));
hill_n      = @(V) arrayfun(@(v) hill_fun(v,-18.3915,8.9938,2), V);
boltzmann_n = @(V) 1 ./ (1 + exp(-(V - 7.0458) ./ 23.1451));

Yn_tanh      = tanh_n(V_fit);
Yn_arctan    = arctan_n(V_fit);
Yn_erf       = erf_n(V_fit);
Yn_hill      = hill_n(V_fit);
Yn_boltzmann = boltzmann_n(V_fit);

err_n_tanh      = compute_errors(Yn, tanh_n(Vn));
err_n_arctan    = compute_errors(Yn, arctan_n(Vn));
err_n_erf       = compute_errors(Yn, erf_n(Vn));
err_n_hill      = compute_errors(Yn, hill_n(Vn));
err_n_boltzmann = compute_errors(Yn, boltzmann_n(Vn));

scatter(Vn, Yn, 17, 'filled', ...
    'MarkerFaceColor', orange, 'MarkerEdgeColor', orange);

plot(V_fit, Yn_hill,      'Color', navy,          'LineWidth',1.2);
plot(V_fit, Yn_tanh,      'Color', col_tanh,      'LineWidth',1.2);
plot(V_fit, Yn_erf,       'Color', col_erf,       'LineWidth',1.2);
plot(V_fit, Yn_arctan,    'Color', col_arctan,    'LineWidth',1.2);
plot(V_fit, Yn_boltzmann, 'Color', col_boltzmann, 'LineWidth',1.2);

xlim([-140 150]); ylim([0 1.02]);
ylabel('$n_{\infty} (V)$','Interpreter','latex','FontSize',14,'FontWeight','bold');
grid on; ax1.GridAlpha = 0.08; ax1.GridLineStyle = '-';

%% =========================================================
%% Panel B: m_inf
%% =========================================================
axes(ax2); hold on;
data = readtable('m_positive.xlsx');
Vm = data.Voltage;
Ym = data.m_inf;

tanh_m      = @(V) 0.5 * (1 + tanh((V - 24.9484) / 18.4042));
arctan_m    = @(V) 0.5 * (1 + 0.63662 * atan((V - 24.7247) / 8.155));
erf_m       = @(V) 0.5 * (1 + erf((V - 24.976) / 21.7786));
hill_m      = @(V) arrayfun(@(v) hill_fun(v,-81.1593,24.5661,11.4235), V);
boltzmann_m = @(V) 1 ./ (1 + exp(-(V - 24.9508) ./ 9.2129));

Ym_tanh      = tanh_m(V_fit);
Ym_arctan    = arctan_m(V_fit);
Ym_erf       = erf_m(V_fit);
Ym_hill      = hill_m(V_fit);
Ym_boltzmann = boltzmann_m(V_fit);

err_m_tanh      = compute_errors(Ym, tanh_m(Vm));
err_m_arctan    = compute_errors(Ym, arctan_m(Vm));
err_m_erf       = compute_errors(Ym, erf_m(Vm));
err_m_hill      = compute_errors(Ym, hill_m(Vm));
err_m_boltzmann = compute_errors(Ym, boltzmann_m(Vm));

scatter(Vm, Ym, 17, 'filled', ...
    'MarkerFaceColor', orange, 'MarkerEdgeColor', orange);

plot(V_fit, Ym_hill,      'Color', navy,          'LineWidth',1.2);
plot(V_fit, Ym_tanh,      'Color', col_tanh,      'LineWidth',1.2);
plot(V_fit, Ym_erf,       'Color', col_erf,       'LineWidth',1.2);
plot(V_fit, Ym_arctan,    'Color', col_arctan,    'LineWidth',1.2);
plot(V_fit, Ym_boltzmann, 'Color', col_boltzmann, 'LineWidth',1.2);

xlim([-140 150]); ylim([0 1.02]);
ylabel('$m_{\infty} (V)$','Interpreter','latex','FontSize',14,'FontWeight','bold');
grid on; ax2.GridAlpha = 0.08; ax2.GridLineStyle = '-';

%% =========================================================
%% Panel C: beta_h
%% =========================================================
axes(ax3); hold on;
data = readtable('beta_h.xlsx');
Vh = data.Voltage;
Yh = data.beta_h;

tanh_h      = @(V) 0.5 * (1 + tanh((V - 29.501) / 15.7105));
arctan_h    = @(V) 0.5 * (1 + 0.63662 * atan((V - 28.684) / 4.5875));
erf_h       = @(V) 0.5 * (1 + erf((V - 29.7426) / 19.8905));
hill_h      = @(V) arrayfun(@(v) hill_fun(v,-93.4064,29.2459,16.3345), V);
boltzmann_h = @(V) 1 ./ (1 + exp(-(V - 29.6293) ./ 8.3139));

Yh_tanh      = tanh_h(V_fit);
Yh_arctan    = arctan_h(V_fit);
Yh_erf       = erf_h(V_fit);
Yh_hill      = hill_h(V_fit);
Yh_boltzmann = boltzmann_h(V_fit);

err_h_tanh      = compute_errors(Yh, tanh_h(Vh));
err_h_arctan    = compute_errors(Yh, arctan_h(Vh));
err_h_erf       = compute_errors(Yh, erf_h(Vh));
err_h_hill      = compute_errors(Yh, hill_h(Vh));
err_h_boltzmann = compute_errors(Yh, boltzmann_h(Vh));

scatter(Vh, Yh, 17, 'filled', ...
    'MarkerFaceColor', orange, 'MarkerEdgeColor', orange);

plot(V_fit, Yh_hill,      'Color', navy,          'LineWidth',1.2);
plot(V_fit, Yh_tanh,      'Color', col_tanh,      'LineWidth',1.2);
plot(V_fit, Yh_erf,       'Color', col_erf,       'LineWidth',1.2);
plot(V_fit, Yh_arctan,    'Color', col_arctan,    'LineWidth',1.2);
plot(V_fit, Yh_boltzmann, 'Color', col_boltzmann, 'LineWidth',1.2);

xlim([-140 150]); ylim([0 1.02]);
ylabel('$\beta_h (V)$ (ms$^{-1}$)','Interpreter','latex','FontSize',14,'FontWeight','bold');
grid on; ax3.GridAlpha = 0.08; ax3.GridLineStyle = '-';

%% ===================== ZOOM BOXES + INSETS =====================

zoomGray = [0.45 0.45 0.45];

% ===== Panel A zoom region =====
xA = [10 55];
yA = [0.6 0.90];

rectangle(ax1,'Position',[xA(1), yA(1), diff(xA), diff(yA)], ...
    'EdgeColor',zoomGray, ...
    'LineStyle','--', ...
    'LineWidth',1.0);

in1 = axes('Position',[0.10 0.6 0.08 0.29]);
hold(in1,'on'); box(in1,'on');

scatter(in1,Vn,Yn,10,'filled', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor',orange);

plot(in1,V_fit,Yn_hill,      'Color',navy,          'LineWidth',1.0);
plot(in1,V_fit,Yn_tanh,      'Color',col_tanh,      'LineWidth',1.0);
plot(in1,V_fit,Yn_erf,       'Color',col_erf,       'LineWidth',1.0);
plot(in1,V_fit,Yn_arctan,    'Color',col_arctan,    'LineWidth',1.0);
plot(in1,V_fit,Yn_boltzmann, 'Color',col_boltzmann, 'LineWidth',1.0);

xlim(in1,xA); ylim(in1,yA);
set(in1,'FontSize',10,'FontWeight','bold','Box','on');
grid(in1,'on'); in1.GridAlpha = 0.08;
annotation(fig,'line',[0.18 0.205],[0.65 0.78], ...
    'Color',zoomGray,'LineWidth',0.8);

% ===== Panel B zoom region =====
xB = [45 120];
yB = [0.85 1];

rectangle(ax2,'Position',[xB(1), yB(1), diff(xB), diff(yB)], ...
    'EdgeColor',zoomGray, ...
    'LineStyle','--', ...
    'LineWidth',1.0);

in2 = axes('Position',[0.42 0.7 0.115 0.2]);
hold(in2,'on'); box(in2,'on');

scatter(in2,Vm,Ym,10,'filled', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor',orange);

plot(in2,V_fit,Ym_hill,      'Color',navy,          'LineWidth',1.0);
plot(in2,V_fit,Ym_tanh,      'Color',col_tanh,      'LineWidth',1.0);
plot(in2,V_fit,Ym_erf,       'Color',col_erf,       'LineWidth',1.0);
plot(in2,V_fit,Ym_arctan,    'Color',col_arctan,    'LineWidth',1.0);
plot(in2,V_fit,Ym_boltzmann, 'Color',col_boltzmann, 'LineWidth',1.0);

xlim(in2,xB); ylim(in2,yB);
set(in2,'FontSize',10,'FontWeight','bold','Box','on');
grid(in2,'on'); in2.GridAlpha = 0.08;
annotation(fig,'line',[0.535 0.555],[0.75 0.88], ...
    'Color',zoomGray,'LineWidth',0.8);

% ===== Panel C zoom region =====
xC = [8 28];
yC = [0.05 0.45];

rectangle(ax3,'Position',[xC(1), yC(1), diff(xC), diff(yC)], ...
    'EdgeColor',zoomGray, ...
    'LineStyle','--', ...
    'LineWidth',1.0);

in3 = axes('Position',[0.74 0.6 0.05 0.3]);
hold(in3,'on'); box(in3,'on');

scatter(in3,Vh,Yh,10,'filled', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor',orange);

plot(in3,V_fit,Yh_hill,      'Color',navy,          'LineWidth',1.0);
plot(in3,V_fit,Yh_tanh,      'Color',col_tanh,      'LineWidth',1.0);
plot(in3,V_fit,Yh_erf,       'Color',col_erf,       'LineWidth',1.0);
plot(in3,V_fit,Yh_arctan,    'Color',col_arctan,    'LineWidth',1.0);
plot(in3,V_fit,Yh_boltzmann, 'Color',col_boltzmann, 'LineWidth',1.0);

xlim(in3,xC); ylim(in3,yC);
set(in3,'FontSize',10,'Box','on','FontWeight','bold');
grid(in3,'on'); in3.GridAlpha = 0.08;
annotation(fig,'line',[0.789 0.842],[0.7 0.39], ...
    'Color',zoomGray,'LineWidth',0.8);

%% ===================== SSE TEXT BOXES =====================

sseFont = 7.5;
boxColor = [1 1 1];

txtA = sprintf(['SSE\n' ...
                'Hill   %.4g\n' ...
                'tanh   %.4g\n' ...
                'erf    %.4g\n' ...
                'arctan %.4g\n' ...
                'Boltz  %.4g'], ...
                err_n_hill.SSE, err_n_tanh.SSE, err_n_erf.SSE, ...
                err_n_arctan.SSE, err_n_boltzmann.SSE);

text(ax1,0.6,0.06,txtA, ...
    'Units','normalized', ...
    'FontSize',sseFont, ...
    'FontName','Courier New', ...
    'Color',[0 0 0], ...
    'BackgroundColor',boxColor, ...
    'EdgeColor',[0.85 0.85 0.85], ...
    'Margin',3, ...
    'VerticalAlignment','bottom');

txtB = sprintf(['SSE\n' ...
                'Hill   %.4g\n' ...
                'tanh   %.4g\n' ...
                'erf    %.4g\n' ...
                'arctan %.4g\n' ...
                'Boltz  %.4g'], ...
                err_m_hill.SSE, err_m_tanh.SSE, err_m_erf.SSE, ...
                err_m_arctan.SSE, err_m_boltzmann.SSE);

text(ax2,0.6,0.06,txtB, ...
    'Units','normalized', ...
    'FontSize',sseFont, ...
    'FontName','Courier New', ...
    'Color',[0 0 0], ...
    'BackgroundColor',boxColor, ...
    'EdgeColor',[0.85 0.85 0.85], ...
    'Margin',3, ...
    'VerticalAlignment','bottom');

txtC = sprintf(['SSE\n' ...
                'Hill   %.4g\n' ...
                'tanh   %.4g\n' ...
                'erf    %.4g\n' ...
                'arctan %.4g\n' ...
                'Boltz  %.4g'], ...
                err_h_hill.SSE, err_h_tanh.SSE, err_h_erf.SSE, ...
                err_h_arctan.SSE, err_h_boltzmann.SSE);

text(ax3,0.62,0.06,txtC, ...
    'Units','normalized', ...
    'FontSize',sseFont, ...
    'FontName','Courier New', ...
    'Color',[0 0 0], ...
    'BackgroundColor',boxColor, ...
    'EdgeColor',[0.85 0.85 0.85], ...
    'Margin',3, ...
    'VerticalAlignment','bottom');

%% x-axis
annotation(fig,'textbox',[0.435 0.105 0.2 0.05], ...
    'String','Voltage (mV)', ...
    'LineStyle','none', ...
    'HorizontalAlignment','center', ...
    'FontSize',14);

%% legend
h1 = plot(nan,nan,'o','Color',orange,'MarkerFaceColor',orange);
h2 = plot(nan,nan,'-','Color',navy,'LineWidth',1.5);
h3 = plot(nan,nan,'-','Color',col_tanh,'LineWidth',1.5);
h4 = plot(nan,nan,'-','Color',col_erf,'LineWidth',1.5);
h5 = plot(nan,nan,'-','Color',col_arctan,'LineWidth',1.5);
h6 = plot(nan,nan,'-','Color',col_boltzmann,'LineWidth',1.5);

lg = legend([h1 h2 h3 h4 h5 h6], ...
    {'Data','Hill','tanh','erf','arctan','Boltzmann'}, ...
    'Orientation','horizontal', ...
    'NumColumns',6, ...
    'FontSize',11,'Box','off');

lg.Units = 'normalized';
lg.Position = [0.24 0.018 0.64 0.05];

%% panel letters
annotation(fig,'textbox',[0.015 0.97 0.03 0.03],'String','a', ...
    'LineStyle','none','FontWeight','bold','FontSize',16);

annotation(fig,'textbox',[0.335 0.97 0.03 0.03],'String','b', ...
    'LineStyle','none','FontWeight','bold','FontSize',16);

annotation(fig,'textbox',[0.655 0.97 0.03 0.03],'String','c', ...
    'LineStyle','none','FontWeight','bold','FontSize',16);

%% ---------------- Export ----------------
set(fig,'PaperUnits','inches','PaperSize',[10 4.6],'PaperPosition',[0 0 10 4.6]);
print(fig,'figure7.pdf','-dpdf','-vector');
exportgraphics(fig,'figure7.png','Resolution',600);
%% =========================================================
%% Local functions
%% =========================================================

function y = hill_fun(v,a,vhalf,n)
    g = v - a;
    if v >= a
        y = (g.^n) ./ ((vhalf - a).^n + g.^n);
    else
        y = 0;
    end
end

function err = compute_errors(y_true,y_pred)
    residual = y_true - y_pred;
    err.SSE  = sum(residual.^2);
    err.RMSE = sqrt(mean(residual.^2));
end

%% ================= ERROR TABLE =================

fprintf('\n===== Fit Error Comparison =====\n');

fprintf('\n--- n_inf ---\n');
fprintf('Hill      : SSE = %.4g, RMSE = %.4g\n', err_n_hill.SSE, err_n_hill.RMSE);
fprintf('tanh      : SSE = %.4g, RMSE = %.4g\n', err_n_tanh.SSE, err_n_tanh.RMSE);
fprintf('erf       : SSE = %.4g, RMSE = %.4g\n', err_n_erf.SSE, err_n_erf.RMSE);
fprintf('arctan    : SSE = %.4g, RMSE = %.4g\n', err_n_arctan.SSE, err_n_arctan.RMSE);
fprintf('Boltzmann : SSE = %.4g, RMSE = %.4g\n', err_n_boltzmann.SSE, err_n_boltzmann.RMSE);

fprintf('\n--- m_inf ---\n');
fprintf('Hill      : SSE = %.4g, RMSE = %.4g\n', err_m_hill.SSE, err_m_hill.RMSE);
fprintf('tanh      : SSE = %.4g, RMSE = %.4g\n', err_m_tanh.SSE, err_m_tanh.RMSE);
fprintf('erf       : SSE = %.4g, RMSE = %.4g\n', err_m_erf.SSE, err_m_erf.RMSE);
fprintf('arctan    : SSE = %.4g, RMSE = %.4g\n', err_m_arctan.SSE, err_m_arctan.RMSE);
fprintf('Boltzmann : SSE = %.4g, RMSE = %.4g\n', err_m_boltzmann.SSE, err_m_boltzmann.RMSE);

fprintf('\n--- beta_h ---\n');
fprintf('Hill      : SSE = %.4g, RMSE = %.4g\n', err_h_hill.SSE, err_h_hill.RMSE);
fprintf('tanh      : SSE = %.4g, RMSE = %.4g\n', err_h_tanh.SSE, err_h_tanh.RMSE);
fprintf('erf       : SSE = %.4g, RMSE = %.4g\n', err_h_erf.SSE, err_h_erf.RMSE);
fprintf('arctan    : SSE = %.4g, RMSE = %.4g\n', err_h_arctan.SSE, err_h_arctan.RMSE);
fprintf('Boltzmann : SSE = %.4g, RMSE = %.4g\n', err_h_boltzmann.SSE, err_h_boltzmann.RMSE);