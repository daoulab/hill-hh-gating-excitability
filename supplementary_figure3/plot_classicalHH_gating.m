function plot_classicalHH_gating(ax)
% PLOT_CLASSICALHH_GATING
%
% Plots classical HH steady-state sodium activation (m_inf) and
% inactivation (h_inf) curves for WT and A863P into the supplied axes.
%
% Usage:
%   plot_classicalHH_gating(ax)
%
% Example:
%   fig = figure;
%   ax = axes(fig);
%   plot_classicalHH_gating(ax);
%
% This function:
%   - computes the curves directly
%   - plots into the provided axes
%   - does NOT create a new figure
%   - does NOT save/export a figure
%   - does NOT run any ODE simulation

%% =====================================================================
% Parameters
% ======================================================================

REST_OFFSET = 40;

% Sodium activation parameters
% [Am Bm Cm Dm Em]

mpar_WT = ...
    [499.901133, 146.493886, 11.155153, 4.000000, 18.000000];

mpar_A863P = ...
    [498.638342, 170.217998, 14.281340, 4.000000, 18.000000];

% Sodium inactivation parameters
% [Dh Eh Bh Ch Ah]

hpar_WT = ...
    [0.07, 20.000000, -37.614172, 11.980625, 0.850421];

hpar_A863P = ...
    [0.07, 20.000000, -19.023709, 14.471338, 0.727992];

%% =====================================================================
% Voltage range
% ======================================================================

V = linspace(-130, 40, 1201).';

%% =====================================================================
% Colors
% ======================================================================

navy   = [0.00 0.13 0.28];
orange = [0.86 0.45 0.06];

%% =====================================================================
% WT steady-state curves
% ======================================================================

alpha_m_WT = ...
    alphaM(mpar_WT, V, REST_OFFSET);

beta_m_WT = ...
    betaM(mpar_WT, V, REST_OFFSET);

minf_WT = ...
    alpha_m_WT ./ ...
    (alpha_m_WT + beta_m_WT);


alpha_h_WT = ...
    alphaH(hpar_WT, V, REST_OFFSET);

beta_h_WT = ...
    betaH(hpar_WT, V, REST_OFFSET);

hinf_WT = ...
    alpha_h_WT ./ ...
    (alpha_h_WT + beta_h_WT);

%% =====================================================================
% A863P steady-state curves
% ======================================================================

alpha_m_A863P = ...
    alphaM(mpar_A863P, V, REST_OFFSET);

beta_m_A863P = ...
    betaM(mpar_A863P, V, REST_OFFSET);

minf_A863P = ...
    alpha_m_A863P ./ ...
    (alpha_m_A863P + beta_m_A863P);


alpha_h_A863P = ...
    alphaH(hpar_A863P, V, REST_OFFSET);

beta_h_A863P = ...
    betaH(hpar_A863P, V, REST_OFFSET);

hinf_A863P = ...
    alpha_h_A863P ./ ...
    (alpha_h_A863P + beta_h_A863P);

%% =====================================================================
% Plot
% ======================================================================

hold(ax, 'on');

% Inactivation: dashed lines

plot(ax, ...
    V, hinf_WT, ...
    '--', ...
    'Color', navy, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'h_\infty, WT');

plot(ax, ...
    V, hinf_A863P, ...
    '--', ...
    'Color', orange, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'h_\infty, AP');

% Activation: solid lines

plot(ax, ...
    V, minf_WT, ...
    '-', ...
    'Color', navy, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'm_\infty, WT');

plot(ax, ...
    V, minf_A863P, ...
    '-', ...
    'Color', orange, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'm_\infty, AP');

%% =====================================================================
% Axes formatting
% ======================================================================

xlabel(ax, 'Membrane potential (mV)');
ylabel(ax, 'Steady-state value');

xlim(ax, [-130 40]);
ylim(ax, [0 1.02]);

lgd=legend(ax, ...
    'Location', 'east', ...
    'Box', 'off');
lgd.Position(1) = lgd.Position(1) + 0.025;
grid(ax, 'on');

set(ax, ...
    'FontName', 'Arial', ...
    'FontSize', 10, ...
    'LineWidth', 1, ...
    'Box', 'off', ...
    'XGrid', 'on', ...
    'YGrid', 'on', ...
    'GridLineStyle', '-', ...
    'GridAlpha', 0.08);

hold(ax, 'off');

end


%% =====================================================================
% alpha_m
% ======================================================================

function a = alphaM(p, V, off)

Am = p(1);
Bm = p(2);
Cm = p(3);

v = V + off;

z = ...
    (Bm - v) ./ Cm;

a = ...
    Am .* (Bm - v) ./ (exp(z) - 1);



end


%% =====================================================================
% beta_m
% ======================================================================

function b = betaM(p, V, off)

Dm = p(4);
Em = p(5);

v = V + off;

b = ...
    Dm .* exp(-v ./ Em);

end


%% =====================================================================
% alpha_h
% ======================================================================

function a = alphaH(p, V, off)

Dh = p(1);
Eh = p(2);

v = V + off;

a = ...
    Dh .* exp(-v ./ Eh);

end


%% =====================================================================
% beta_h
% ======================================================================

function b = betaH(p, V, off)

Bh = p(3);
Ch = p(4);
Ah = p(5);

v = V + off;

b = ...
    Ah ./ ...
    (1 + exp((Bh - v) ./ Ch));

end