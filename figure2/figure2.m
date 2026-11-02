%% Figure 2
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
fig = figure('Units','inches','Position',[0.5 0.5 10.6 4.6],'Color','w');

% ===== Positions: two panels side-by-side =====
axA_pos = [0.10 0.22 0.37 0.68];   % left  (moved right)
axB_pos = [0.58 0.22 0.37 0.68];   % right (moved right)

%% =========================================================
%% A : Current mapping 
%% =========================================================
axA = axes('Position',axA_pos); hold(axA,'on');

x = [10 20 30 40 50 60 70 80 90 100 110 120];
y = [10.2 21.6 33 45 57 68.5 80 92 104 116 127 140];
p = polyfit(x, y, 1);
yfit = polyval(p, x);

plot(x, yfit, 'LineWidth', 1.8, ...
    'Color', navy, ...
    'DisplayName', sprintf('$I_{\\mathrm{mod}} = %.3f I_{\\mathrm{HH}} %+.3f$  ($R^2 \\approx 1)$', ...
                       p(1), p(2)));

plot(x, y, 'o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 5, ...
    'MarkerEdgeColor', orange, ...
    'MarkerFaceColor', orange, ...
    'DisplayName', 'RMSE $< 10$ mV');

xlabel('$I_{\mathrm{app}}$ in original HH ($\mu\mathrm{A/cm}^2$)', ...
    'Interpreter','latex','FontSize',14);
ylabel('$I_{\mathrm{app}}$ in modified HH ($\mu\mathrm{A/cm}^2$)', ...
    'Interpreter','latex','FontSize',14);

grid on
axA.GridAlpha = 0.08;
axA.GridLineStyle = '-';

xlim([min(x) max(x)]);
ylim([min([x y]) max([x y])]);

axA.XLabel.Units = 'normalized';
axA.XLabel.Position(2) = -0.14;

lgA = legend(axA,'Location','northwest','Interpreter','latex','Box','off','FontSize',11);
lgA.ItemTokenSize = [15 18];

%% =========================================================
%% B : f-I curve 
%% =========================================================
axB = axes('Position',axB_pos); hold(axB,'on');

[Iapp_values, num_AP_original, num_AP_modified] = compute_fI_data();

plot(Iapp_values, num_AP_original, '-', 'Color', orange, 'LineWidth',1.6, ...
    'DisplayName','Original HH');
plot(Iapp_values, num_AP_modified, '-', 'Color', navy,   'LineWidth',1.6, ...
    'DisplayName','Modified HH');

plot(Iapp_values, num_AP_original, 'o', ...
    'MarkerFaceColor', orange, 'MarkerEdgeColor', orange, ...
    'MarkerSize',3.5, 'HandleVisibility','off');

plot(Iapp_values, num_AP_modified, 's', ...
    'MarkerFaceColor', navy, 'MarkerEdgeColor', navy, ...
    'MarkerSize',3.5, 'HandleVisibility','off');

xlabel('$I_{\mathrm{app}}$ ($\mu\mathrm{A/cm}^2$)','Interpreter','latex','FontSize',14);
ylabel('Firing frequency (Hz)','FontName','Arial','FontSize',14,'FontWeight','bold');

grid on
axB.GridAlpha = 0.08;
axB.GridLineStyle = '-';

xlim([0 max(Iapp_values)]);
ylim([0 1.05*max([num_AP_original(:); num_AP_modified(:)])]);

axB.XLabel.Units = 'normalized';
axB.XLabel.Position(2) = -0.14;

lg = legend(axB, {'Original HH','Modified HH'}, 'Location','none');
lg.Box = 'off';
lg.FontSize = 11;
lg.ItemTokenSize = [15 18];   % shorter legend lines

set([axA axB],'FontSize',13,'LineWidth',0.9,'FontWeight','normal');
axA.YLabel.Position(1) = axA.YLabel.Position(1) - 1;
axB.YLabel.Position(1) = axB.YLabel.Position(1) - 1;

lg.Units = 'normalized';
pos = lg.Position;
pos(1) = axB.Position(1) + axB.Position(3) - pos(3) ;  % right edge inside axes
pos(2) = axB.Position(2) + axB.Position(4) - pos(4) - 0.06;
lg.Position = pos;

%% =========================================================
%% Panel labels a and b (above y-label)
%% =========================================================
annotation(fig,'textbox', ...
    [axA_pos(1)-0.07, axA_pos(2)+axA_pos(4)+0.035, 0.03, 0.085], ...
    'String','a','LineStyle','none', ...
    'FontName','Arial','FontWeight','bold','FontSize',16);

annotation(fig,'textbox', ...
    [axB_pos(1)-0.07, axB_pos(2)+axB_pos(4)+0.035, 0.03, 0.085], ...
    'String','b','LineStyle','none', ...
    'FontName','Arial','FontWeight','bold','FontSize',16);

%% =========================================================
%% Panel titles
%% =========================================================
annotation(fig,'textbox', ...
    [axA_pos(1)+0.07, axA_pos(2)+axA_pos(4)+0.035, 0.22, 0.075], ...
    'String','Current remapping','LineStyle','none', ...
    'HorizontalAlignment','center','FontName','Arial', ...
    'FontWeight','bold','FontSize',14);

annotation(fig,'textbox', ...
    [axB_pos(1), axB_pos(2)+axB_pos(4)+0.035, 0.37, 0.075], ...
    'String','Frequency-current relationship','LineStyle','none', ...
    'HorizontalAlignment','center','FontName','Arial', ...
    'FontWeight','bold','FontSize',14);

%% =========================================================
%% Export
%% =========================================================
exportgraphics(fig,'figure2.pdf','ContentType','vector');
exportgraphics(fig,'figure2.png','Resolution',600);
%% =========================================================
%% Functions
%% =========================================================

function [Iapp_values, num_AP_original, num_AP_modified] = compute_fI_data()
    global v_i h_i n_i m_i from_ to_ C gNa vNa gK vK gL vL

     v_i = 0; h_i = 0.815470; n_i = 0.323665; m_i = 0.048643;
   
    from_ = 50; to_ = 150;
    C = 1;
    gNa = 120; vNa = 155;
    gK = 36;  vK = -12;
    gL = 0.3; vL = 10.613;

    Iapp_values = 0:5:200;
    num_AP_original = zeros(size(Iapp_values));
    num_AP_modified = zeros(size(Iapp_values));

    for i = 1:length(Iapp_values)
        Iapp = Iapp_values(i);

        [t1, voltage1] = HH_model_with_Iapp(Iapp);
        [t2, voltage2] = HH_modified_model_with_Iapp(Iapp);

        time_indices = (t1 >= from_ & t1 <= to_);
        voltage_segment1 = voltage1(time_indices);
        voltage_segment2 = voltage2(time_indices);
        time_segment1 = t1(time_indices);
        time_segment2 = t2(time_indices);

        [peaks1, ~] = findpeaks(voltage_segment1-65, time_segment1, 'MinPeakProminence', 5);
        peaks1 = peaks1(peaks1 >= 0);
        num_AP_original(i) = length(peaks1)/0.1;

        [peaks2, ~] = findpeaks(voltage_segment2-65, time_segment2, 'MinPeakProminence', 5);
        peaks2 = peaks2(peaks2 >= 0);
        num_AP_modified(i) = length(peaks2)/0.1;
    end
end



function [t, voltage] = HH_model_with_Iapp(Iapp)
    global v_i h_i n_i m_i
    init_cond = [v_i, m_i, h_i, n_i];
    tspan = 0:0.01:200;
    [t, sol] = ode113(@(t, sol) DiffEquations_HH_with_Iapp(t, sol, Iapp), tspan, init_cond);
    voltage = sol(:, 1);
end

function [t, voltage] = HH_modified_model_with_Iapp(Iapp)
    global v_i h_i n_i m_i
    init_cond = [v_i, m_i, h_i, n_i];
    tspan = 0:0.01:200;
    [t, sol] = ode113(@(t, sol) DiffEquations_modified_with_Iapp(t, sol, Iapp), tspan, init_cond);
    voltage = sol(:, 1);
end

function dsol = DiffEquations_HH_with_Iapp(t, sol, Iapp)
    global from_ to_ C gNa vNa gK vK gL vL

    v = sol(1); m = sol(2); h = sol(3); n = sol(4);

    alphaM = 0.1 * (25 - v) / (exp((25 - v) / 10) - 1);
    betaM = 4 * exp(-v / 18);
    alphaH = 0.07 * exp(-v / 20);
    betaH = 1 / (1 + exp((30 - v) / 10));

    iNa = gNa * (m^3) * h * (v - vNa);

    alphaN = 0.01 * (10 - v) / (exp((10 - v) / 10) - 1);
    betaN = 0.125 * exp(-v / 80);
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

function dsol = DiffEquations_modified_with_Iapp(t, sol, Iapp)
    global from_ to_ C gNa vNa gK vK gL vL

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