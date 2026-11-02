%% ===== Supplementary Figure S1: spike traces under matched current injection =====
clear; close all; clc;

%% ---------------- Colors ----------------
orange = [0.86 0.45 0.06];   % Original HH
navy   = [0.00 0.13 0.28];   % Modified HH

%% ---------------- Global style ----------------
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultTextFontName','Arial');
set(groot,'defaultAxesFontSize',13);
set(groot,'defaultLineLineWidth',1.8);
set(groot,'defaultAxesLineWidth',0.9);
set(groot,'defaultAxesBox','off');

%% ---------------- Figure canvas ----------------
FIGW = 10; FIGH = 4.3;
fig = figure('Units','inches','Position',[0.5 0.5 FIGW FIGH],'Color','w');

% Three panels side by side (shorter, leaving room on top)
ax1_pos = [0.07 0.24 0.25 0.58];
ax2_pos = [0.38 0.24 0.25 0.58];
ax3_pos = [0.69 0.24 0.25 0.58];

% Current pairs [Original HH, Modified HH]
I_pairs = [30 33; 50 57; 70 80];
axesPos = {ax1_pos, ax2_pos, ax3_pos};

hOrig_all = gobjects(1,3);
hMod_all  = gobjects(1,3);

for i = 1:3
    I_HH  = I_pairs(i,1);
    I_Mod = I_pairs(i,2);

    [t1, V1] = HH(I_HH);
    [t2, V2] = HH_modified(I_Mod);

    ax = axes('Position',axesPos{i}); hold(ax,'on');

    % Traces
    hMod_all(i)  = plot(t2, V2 - 65, 'Color', navy,   'LineWidth',1.1, ...
        'DisplayName','Modified HH');
    hOrig_all(i) = plot(t1, V1 - 65, 'Color', orange, 'LineWidth',1.1, ...
        'DisplayName','Original HH');

    % Axes
    xlim([0 200]);
    ylim([-80 100]);
    xlabel('$\mathrm{Time\ (ms)}$', ...
        'Interpreter','latex', ...
        'FontSize',13, ...
        'FontWeight','bold');

    if i == 1
        ylabel('$\mathrm{Voltage\ (mV)}$', ...
            'Interpreter','latex', ...
            'FontSize',13, ...
            'FontWeight','bold');
    end

    text(ax, -0.22, 1.15, char('a'+i-1), ...
        'Units','normalized', ...
        'FontWeight','bold', ...
        'FontSize',16, ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','top');

    grid on
    ax.GridAlpha = 0.08;
    ax.GridLineStyle = '-';

    % Bring x-label slightly closer
    ax.XLabel.Units = 'normalized';
    ax.XLabel.Position(2) = -0.12;

    % Current injection bar (50 to 150 ms)
    y_bar = 90;
    plot([50 150], [y_bar y_bar], 'k', 'LineWidth', 1.4, 'HandleVisibility','off');

    % Two labels above the bar, stacked (orange on top, navy below)
    text(100, y_bar + 22, sprintf('I_{app} = %d \\muA/cm^2', I_HH), ...
        'Color', orange, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', ...
        'FontSize',11, ...
        'FontWeight','bold');

    text(100, y_bar + 6, sprintf('I_{app} = %d \\muA/cm^2', I_Mod), ...
        'Color', navy, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', ...
        'FontSize',11, ...
        'FontWeight','bold');
end

%% ---------------- One shared legend at bottom ----------------
lg = legend(axes('Position',[0 0 1 1],'Visible','off'), ...
    [hOrig_all(1) hMod_all(1)], {'Original HH','Modified HH'}, ...
    'Orientation','horizontal', ...
    'NumColumns',2, ...
    'Box','off', ...
    'FontSize',13);

lg.Units = 'normalized';
lg.Position = [0.39 0.04 0.22 0.04];

%% ---------------- Export ----------------
set(fig,'PaperUnits','inches','PaperSize',[FIGW FIGH],'PaperPosition',[0 0 FIGW FIGH]);
print(fig,'Supplementary_Figure1.pdf','-dpdf','-vector');
exportgraphics(fig,'Supplementary_Figure1.png','Resolution',600);

%% =========================================================
%% Functions
%% =========================================================

function [t, modelTrace,m,h,n] = HH(Iapp)
    v_i = 0; h_i = 0.815470; n_i = 0.323665; m_i = 0.048643;
    init_cond = [v_i, m_i, h_i, n_i];
    tspan = 0:0.001:200;
    [t, sol] = ode113(@(t, sol) DiffEquations(t, sol, Iapp), tspan, init_cond);
    modelTrace = sol(:, 1);
    m = sol(:, 2);
    h = sol(:, 3);
    n = sol(:, 4);
end

function dsol = DiffEquations(t, sol, Iapp)
    from_ = 50;
    to_ = 150;
    C = 1;
    gNa = 120; vNa = 155;
    gK = 36;  vK = -12;
    gL = 0.3; vL = 10.613;

    v = sol(1);
    m = sol(2);
    h = sol(3);
    n = sol(4);

    alphaM = 0.1*(25-v)/(exp((25-v)/10)-1);
    betaM = 4*exp(-v/18);
    alphaH = 0.07*exp((-v)/20);
    betaH = 1/(1+exp((30-v)/10));

    iNa = gNa * (m^3) * h * (v - vNa);

    alphaN = 0.01*(10-v)/(exp((10-v)/10)-1);
    betaN = 0.125*exp((-v)/80);
    iK = gK * (n^4) * (v - vK);

    iL = gL * (v - vL);

    if from_ <= t && t <= to_
        iap = Iapp;
    else
        iap = 0;
    end

    dVdt = (-iNa - iK - iL + iap) / C;
    dmdt = alphaM * (1 - m) - betaM * m;
    dhdt = alphaH * (1 - h) - betaH * h;
    dndt = alphaN * (1 - n) - betaN * n;

    dsol = [dVdt; dmdt; dhdt; dndt];
end

function [t, modelTrace] = HH_modified(Iapp)
    v_i = 0; h_i = 0.815470; n_i = 0.323665; m_i = 0.048643;
    init_cond = [v_i, m_i, h_i, n_i];
    tspan = 0:0.001:200;
    [t, sol] = ode113(@(t, sol) DiffEquations_modified(t, sol, Iapp), tspan, init_cond);
    modelTrace = sol(:, 1);
end

function dsol = DiffEquations_modified(t, sol, Iapp)
    from_ = 50; to_ = 150;
    C = 1;
    gNa = 120; vNa = 155;
    gK = 36;  vK = -12;
    gL = 0.3; vL = 10.613;

    v = sol(1); m = sol(2); h = sol(3); n = sol(4);

    betaM = 4 * exp(-v / 18);
    a = -81.1593; hill_n = 11.4235; vhalf = 24.5661;
    g = v - a;
    if v >= a
        m_inf = (g.^hill_n) ./ ((vhalf - a).^hill_n + g.^hill_n);
    else
        m_inf = 0;
    end
    alphaM = (betaM .* m_inf) ./ (1 - m_inf);

    alphaH = 0.07 * exp(-v / 20);
    a = -93.4064; hill_n = 16.3345; vhalf = 29.2459;
    g = v - a;
    if v >= a
        betaH = (g.^hill_n) ./ ((vhalf - a).^hill_n + g.^hill_n);
    else
        betaH = 0;
    end

    betaN = 0.125 * exp(-v / 80);
    a = -18.3915; hill_n = 2; vhalf = 8.9938;
    g = v - a;
    if v >= a
        n_inf = (g.^hill_n) ./ ((vhalf - a).^hill_n + g.^hill_n);
    else
        n_inf = 0;
    end
    alphaN = (betaN .* n_inf) ./ (1 - n_inf);

    iNa = gNa * (m^3) * h * (v - vNa);
    iK = gK * (n^4) * (v - vK);
    iL = gL * (v - vL);

    if from_ <= t && t <= to_
        iap = Iapp;
    else
        iap = 0;
    end

    dVdt = (-iNa - iK - iL + iap) / C;
    dmdt = alphaM * (1 - m) - betaM * m;
    dhdt = alphaH * (1 - h) - betaH * h;
    dndt = alphaN * (1 - n) - betaN * n;

    dsol = [dVdt; dmdt; dhdt; dndt];
end