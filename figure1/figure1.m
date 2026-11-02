%% ============================================================
% Compare x_inf and tau_x for Original HH vs Modified HH model
% Row 1: x_inf (m, h, n)
% Row 2: tau   (m, h, n)
%% ============================================================
clear; close all; clc;

%% ---------------- Modified-model parameters ----------------
a_m = -81.1593;
a_n = -18.3915;
a_h = -93.4064;

hill_n_m = 11.4235;
hill_n_n = 2;
hill_n_h = 16.3345;

vhalf_m = 24.5661;
vhalf_n = 8.9938;
vhalf_h = 29.2459;

%% ---------------- Voltage range ----------------
% This is the same voltage convention used in your HH code
v = linspace(-100, 150, 2000);

%% ============================================================
% ORIGINAL HH
%% ============================================================
alphaM_HH = alphaM_fun(v);
betaM_HH  = 4 .* exp(-v ./ 18);

alphaH_HH = 0.07 .* exp(-v ./ 20);
betaH_HH  = 1 ./ (1 + exp((30 - v) ./ 10));

alphaN_HH = alphaN_fun(v);
betaN_HH  = 0.125 .* exp(-v ./ 80);

m_inf_HH = alphaM_HH ./ (alphaM_HH + betaM_HH);
h_inf_HH = alphaH_HH ./ (alphaH_HH + betaH_HH);
n_inf_HH = alphaN_HH ./ (alphaN_HH + betaN_HH);

tau_m_HH = 1 ./ (alphaM_HH + betaM_HH);
tau_h_HH = 1 ./ (alphaH_HH + betaH_HH);
tau_n_HH = 1 ./ (alphaN_HH + betaN_HH);

%% ============================================================
% MODIFIED MODEL
%% ============================================================

% ---------- m ----------
betaM_mod = 4 .* exp(-v ./ 18);
m_inf_mod = zeros(size(v));

idx_m = v >= a_m;
g_m = v(idx_m) - a_m;
m_inf_mod(idx_m) = (g_m.^hill_n_m) ./ ((vhalf_m - a_m).^hill_n_m + g_m.^hill_n_m);

alphaM_mod = zeros(size(v));
eps_val = 1e-12;
valid_m = (1 - m_inf_mod) > eps_val;
alphaM_mod(valid_m) = (betaM_mod(valid_m) .* m_inf_mod(valid_m)) ./ (1 - m_inf_mod(valid_m));
alphaM_mod(~valid_m) = NaN;

tau_m_mod = 1 ./ (alphaM_mod + betaM_mod);

% ---------- h ----------
alphaH_mod = 0.07 .* exp(-v ./ 20);
betaH_mod  = zeros(size(v));

idx_h = v >= a_h;
g_h = v(idx_h) - a_h;
betaH_mod(idx_h) = (g_h.^hill_n_h) ./ ((vhalf_h - a_h).^hill_n_h + g_h.^hill_n_h);

h_inf_mod = alphaH_mod ./ (alphaH_mod + betaH_mod);
tau_h_mod = 1 ./ (alphaH_mod + betaH_mod);

% ---------- n ----------
betaN_mod = 0.125 .* exp(-v ./ 80);
n_inf_mod = zeros(size(v));

idx_n = v >= a_n;
g_n = v(idx_n) - a_n;
n_inf_mod(idx_n) = (g_n.^hill_n_n) ./ ((vhalf_n - a_n).^hill_n_n + g_n.^hill_n_n);
                                                                   
alphaN_mod = zeros(size(v));
valid_n = (1 - n_inf_mod) > eps_val;
alphaN_mod(valid_n) = (betaN_mod(valid_n) .* n_inf_mod(valid_n)) ./ (1 - n_inf_mod(valid_n));
alphaN_mod(~valid_n) = NaN;

tau_n_mod = 1 ./ (alphaN_mod + betaN_mod);

%% ============================================================
% PLOTTING
%% ============================================================
% PLOTTING
%% ============================================================

% Colors
color_HH  = [0.85 0.33 0.10];   % orange
color_mod = [0.00 0.13 0.28];   % navy

figure('Color','w','Position',[100 100 1400 780]);
%% ---------------- Global style ----------------
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');

% -------- Row 1: x_inf --------
subplot(2,3,1)
plot(v, m_inf_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, m_inf_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$m_{\infty} (V)$','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

subplot(2,3,2)
plot(v, h_inf_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, h_inf_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$h_{\infty} (V)$','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

subplot(2,3,3)
plot(v, n_inf_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, n_inf_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$n_{\infty} (V)$','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

% -------- Row 2: tau --------
subplot(2,3,4)
plot(v, tau_m_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, tau_m_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$\tau_m (V)$ (ms)','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

subplot(2,3,5)
plot(v, tau_h_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, tau_h_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$\tau_h (V)$ (ms)','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

subplot(2,3,6)
plot(v, tau_n_HH, 'Color', color_HH, 'LineWidth', 2); hold on;
plot(v, tau_n_mod, 'Color', color_mod, 'LineWidth', 2);
yl = ylabel('$\tau_n (V)$ (ms)','Interpreter','latex', ...
    'FontSize',14,'FontWeight','bold');
yl.Position(1) = yl.Position(1) - 8;
ax = gca; grid(ax,'on'); ax.GridAlpha = 0.08; ax.GridLineStyle = '-';

% Shared x-axis label for top row
annotation(gcf,'textbox',[0.40 0.51 0.20 0.035], ...
    'String','Voltage (mV)', ...
    'LineStyle','none', ...
    'HorizontalAlignment','center', ...
    'FontName','Arial', ...
    'FontSize',14,'FontWeight','bold');

% Shared x-axis label for bottom row
annotation(gcf,'textbox',[0.41 0.045 0.20 0.035], ...
    'String','Voltage (mV)', ...
    'LineStyle','none', ...
    'HorizontalAlignment','center', ...
    'FontName','Arial', ...
    'FontSize',14,'FontWeight','bold');

%% ---------------- Panel labels ----------------
annotation(gcf,'textbox',[0.08 0.95 0.03 0.03], ...
    'String','a','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

annotation(gcf,'textbox',[0.36 0.95 0.03 0.03], ...
    'String','b','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

annotation(gcf,'textbox',[0.645 0.95 0.03 0.03], ...
    'String','c','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

annotation(gcf,'textbox',[0.08 0.48 0.03 0.03], ...
    'String','d','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

annotation(gcf,'textbox',[0.36 0.48 0.03 0.03], ...
    'String','e','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

annotation(gcf,'textbox',[0.645 0.48 0.03 0.03], ...
    'String','f','LineStyle','none','FontWeight','bold', ...
    'FontName','Arial','FontSize',16);

% --- Legend ---
h1 = plot(nan, nan, 'Color', color_HH, 'LineWidth', 2.2); hold on;
h2 = plot(nan, nan, 'Color', color_mod, 'LineWidth', 2.2);

lgd = legend([h1 h2], {'Original HH','Modified HH'}, ...
    'Orientation','horizontal');
lgd.FontSize = 13;
lgd.Box = 'off';
lgd.Position = [0.41 0.0005 0.2 0.05];

% -------- Export figure --------
exportgraphics(gcf, 'figure1.png', 'Resolution', 300);
exportgraphics(gcf, 'figure1.pdf','Resolution',600);
%% ============================================================
% Helper functions
%% ============================================================
function alphaM = alphaM_fun(v)
    alphaM = zeros(size(v));
    idx = abs(25 - v) > 1e-8;
    alphaM(idx) = 0.1 .* (25 - v(idx)) ./ (exp((25 - v(idx)) ./ 10) - 1);
    
    % limit as v -> 25
    alphaM(~idx) = 1;
end

function alphaN = alphaN_fun(v)
    alphaN = zeros(size(v));
    idx = abs(10 - v) > 1e-8;
    alphaN(idx) = 0.01 .* (10 - v(idx)) ./ (exp((10 - v(idx)) ./ 10) - 1);
    
    % limit as v -> 10
    alphaN(~idx) = 0.1;
end