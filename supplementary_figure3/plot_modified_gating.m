function plot_modified_gating(ax)
% PLOT_MODIFIED_GATING
%
% Plots modified Hill-HH steady-state sodium activation (m_inf) and
% inactivation (h_inf) curves for WT and A863P into the supplied axes.
%
% Usage:
%   plot_modified_gating(ax)
%
% This function:
%   - computes the curves directly
%   - plots into the provided axes
%   - does NOT create a new figure
%   - does NOT save/export a figure
%   - does NOT write Excel files
%   - does NOT print crossing diagnostics

%% =====================================================================
% Parameters
% ======================================================================

REST_OFFSET = 40;

Dh = 0.07;
Eh = 20;

% ----------------------------------------------------------------------
% Sodium activation m_inf Hill parameters
% [a, l, Vhalf]
% ----------------------------------------------------------------------

mpar_WT = ...
    [-249.9937, 32.1186, -15.9];

mpar_A863P = ...
    [-249.9995, 27.0128, -23.6];

% ----------------------------------------------------------------------
% Sodium inactivation beta_h Hill parameters
% [a, l, Vhalf]
% ----------------------------------------------------------------------

hpar_WT = ...
    [-150, 4.88, -73];

hpar_A863P = ...
    [-150.0000, 4.68, -47];

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
% Activation curves
% ======================================================================

minf_WT = ...
    hillIncSafe(mpar_WT, V);

minf_A863P = ...
    hillIncSafe(mpar_A863P, V);

%% =====================================================================
% Inactivation curves
%
% h_inf = alpha_h / (alpha_h + beta_h)
% ======================================================================

alpha_h = ...
    Dh .* exp(-(V + REST_OFFSET) ./ Eh);

beta_h_WT = ...
    hillIncSafe(hpar_WT, V);

beta_h_A863P = ...
    hillIncSafe(hpar_A863P, V);

hinf_WT = ...
    alpha_h ./ ...
    (alpha_h + beta_h_WT);

hinf_A863P = ...
    alpha_h ./ ...
    (alpha_h + beta_h_A863P);

%% =====================================================================
% Plot
% ======================================================================

hold(ax, 'on');

% ----------------------------------------------------------------------
% Inactivation: dashed
% ----------------------------------------------------------------------

plot(ax, ...
    V, ...
    hinf_WT, ...
    '--', ...
    'Color', navy, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'h_\infty, WT');

plot(ax, ...
    V, ...
    hinf_A863P, ...
    '--', ...
    'Color', orange, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'h_\infty, AP');

% ----------------------------------------------------------------------
% Activation: solid
% ----------------------------------------------------------------------

plot(ax, ...
    V, ...
    minf_WT, ...
    '-', ...
    'Color', navy, ...
    'LineWidth', 1.8, ...
    'DisplayName', 'm_\infty, WT');

plot(ax, ...
    V, ...
    minf_A863P, ...
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
lgd.Position(1) = lgd.Position(1) + 0.03;
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
% Sign-safe increasing Hill function
% ======================================================================

function y = hillIncSafe(p, V)
% p = [a, l, Vhalf]
%
% All voltages are real membrane potentials in mV.
%
% The function enforces y = 0 for V < -a.

a     = p(1);
l     = p(2);
Vhalf = p(3);

V = V(:);

g = V - a;
w = Vhalf - a;

y = ...
    (sign(g).^fix(l) .* abs(g).^l) ./ ...
    ( ...
      sign(w).^fix(l) .* abs(w).^l + ...
      sign(g).^fix(l) .* abs(g).^l ...
    );

y(V < a) = 0;

end