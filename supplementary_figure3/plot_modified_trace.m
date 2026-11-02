function plot_modified_trace(ax, Iapp)
% PLOT_MODIFIED_TRACE
%
% Simulates and plots representative WT and A863P voltage traces for the
% modified Hill-HH Nav1.7 implementation into the supplied axes.
%
% Usage:
%   plot_modified_trace(ax)
%   plot_modified_trace(ax, Iapp)
%
% Default:
%   Iapp = 40 uA/cm^2
%
% This function:
%   - runs one WT simulation
%   - runs one A863P simulation
%   - plots directly into the supplied axes
%   - does NOT create a new figure
%   - does NOT save/export anything

if nargin < 2
    Iapp = 40;
end

%% =====================================================================
% Coordinate convention
% ======================================================================

REST_OFFSET = 40;

%% =====================================================================
% Sodium activation m_inf Hill parameters
% [a, l, Vhalf]
% ======================================================================

mpar_WT = ...
    [-249.9937, 32.1186, -15.9];

mpar_A863P = ...
    [-249.9995, 27.0128, -23.6];

%% =====================================================================
% Sodium inactivation beta_h Hill parameters
% [a, l, Vhalf]
% ======================================================================

hpar_WT = ...
    [-150, 4.88, -73];

hpar_A863P = ...
    [-150.0000, 4.68, -47];

%% =====================================================================
% Classical alpha_h parameters
% Shared by WT and A863P
% ======================================================================

alphaHpar = ...
    [0.07, 20];

%% =====================================================================
% Retained classical rate constants
% ======================================================================

Dm = 4;
Em = 18;

Dn = 0.125;
En = 80;

%% =====================================================================
% Potassium n_inf Hill parameters
% Shared by WT and A863P
% ======================================================================

Vhalf_n = -15;
a_n     = -110;
l_n     = 6.333;

npar = ...
    [a_n, l_n, Vhalf_n];

%% =====================================================================
% Membrane parameters
% ======================================================================

C   = 1;

gNa = 120;
ENa = 50;

gK  = 36;
EK  = -77;

gL  = 0.6;
EL  = -54.4;

%% =====================================================================
% Simulation settings
% ======================================================================

tspan = [0 200];

stim_start = 50;
stim_end   = 150;

%% =====================================================================
% Initial conditions
% ======================================================================

V0 = -50;
m0 = 0.04;
h0 = 0.81;
n0 = 0.32;

init_cond = ...
    [V0, m0, h0, n0];

%% =====================================================================
% ODE settings
% ======================================================================

opts_ode = odeset( ...
    'RelTol', 1e-6, ...
    'AbsTol', 1e-8);

%% =====================================================================
% Simulate WT
% ======================================================================

[t_WT, sol_WT] = ode113( ...
    @(t,y) DiffEquations_Nav17( ...
        t, y, Iapp, ...
        mpar_WT, ...
        hpar_WT, ...
        npar, ...
        REST_OFFSET, ...
        Dm, Em, ...
        alphaHpar, ...
        Dn, En, ...
        C, ...
        gNa, ENa, ...
        gK, EK, ...
        gL, EL, ...
        stim_start, ...
        stim_end), ...
    tspan, ...
    init_cond, ...
    opts_ode);

V_WT = ...
    sol_WT(:,1);

%% =====================================================================
% Simulate A863P
% ======================================================================

[t_A863P, sol_A863P] = ode113( ...
    @(t,y) DiffEquations_Nav17( ...
        t, y, Iapp, ...
        mpar_A863P, ...
        hpar_A863P, ...
        npar, ...
        REST_OFFSET, ...
        Dm, Em, ...
        alphaHpar, ...
        Dn, En, ...
        C, ...
        gNa, ENa, ...
        gK, EK, ...
        gL, EL, ...
        stim_start, ...
        stim_end), ...
    tspan, ...
    init_cond, ...
    opts_ode);

V_A863P = ...
    sol_A863P(:,1);

%% =====================================================================
% Colors
% ======================================================================

navy   = [0.00 0.13 0.28];
orange = [0.86 0.45 0.06];

%% =====================================================================
% Plot
% ======================================================================

hold(ax, 'on');

plot(ax, ...
    t_WT, ...
    V_WT, ...
    'Color', navy, ...
    'LineWidth', 1.2, ...
    'DisplayName', 'WT');

plot(ax, ...
    t_A863P, ...
    V_A863P, ...
    'Color', orange, ...
    'LineWidth', 1.2, ...
    'DisplayName', 'AP');

%% =====================================================================
% Axes formatting
% ======================================================================

xlabel(ax, 'Time (ms)');
ylabel(ax, 'Voltage (mV)');

xlim(ax, tspan);

legend(ax, ...
    'Location', 'northeast', ...
    'Box', 'off');

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

a     = p(1);
l     = p(2);
Vhalf = p(3);

g = ...
    V - a;

w = ...
    Vhalf - a;

y = ...
    (sign(g).^fix(l) .* abs(g).^l) ./ ...
    ( ...
      sign(w).^fix(l) .* abs(w).^l + ...
      sign(g).^fix(l) .* abs(g).^l ...
    );

if V < a
    y = 0;
end

end


%% =====================================================================
% Modified Hill-HH differential equations
% ======================================================================

function dsol = DiffEquations_Nav17( ...
    t, ...
    sol, ...
    Iapp, ...
    mpar, ...
    hpar, ...
    npar, ...
    REST_OFFSET, ...
    Dm, Em, ...
    alphaHpar, ...
    Dn, En, ...
    C, ...
    gNa, ENa, ...
    gK, EK, ...
    gL, EL, ...
    stim_start, ...
    stim_end)

V = sol(1);
m = sol(2);
h = sol(3);
n = sol(4);

%% =====================================================================
% m gate
%
% Hill m_inf + retained classical beta_m
% ======================================================================

m_inf = ...
    hillIncSafe(mpar, V);



beta_m = ...
    Dm * exp( ...
        -(V + REST_OFFSET) / Em);

alpha_m = ...
    beta_m * m_inf / ...
    (1 - m_inf);

%% =====================================================================
% h gate
%
% Classical alpha_h + Hill beta_h
% ======================================================================

Dh = ...
    alphaHpar(1);

Eh = ...
    alphaHpar(2);

alpha_h = ...
    Dh * exp( ...
        -(V + REST_OFFSET) / Eh);

beta_h = ...
    hillIncSafe(hpar, V);

%% =====================================================================
% n gate
%
% Hill n_inf + retained classical beta_n
% ======================================================================

n_inf = ...
    hillIncSafe(npar, V);



beta_n = ...
    Dn * exp( ...
        -(V + REST_OFFSET) / En);

alpha_n = ...
    beta_n * n_inf / ...
    (1 - n_inf);

%% =====================================================================
% Ionic currents
% ======================================================================

iNa = ...
    gNa * ...
    (m^3) * ...
    h * ...
    (V - ENa);

iK = ...
    gK * ...
    (n^4) * ...
    (V - EK);

iL = ...
    gL * ...
    (V - EL);

%% =====================================================================
% Applied current
% ======================================================================

if stim_start <= t && t <= stim_end

    iap = Iapp;

else

    iap = 0;

end

%% =====================================================================
% Differential equations
% ======================================================================

dVdt = ...
    (-iNa - iK - iL + iap) / C;

dmdt = ...
    alpha_m * (1-m) - ...
    beta_m * m;

dhdt = ...
    alpha_h * (1-h) - ...
    beta_h * h;

dndt = ...
    alpha_n * (1-n) - ...
    beta_n * n;

dsol = ...
    [dVdt; dmdt; dhdt; dndt];

end