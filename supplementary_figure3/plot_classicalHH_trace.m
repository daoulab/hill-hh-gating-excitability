
function plot_classicalHH_trace(ax, Iapp)
% PLOT_CLASSICALHH_TRACE
%
% Simulates and plots representative WT and A863P voltage traces for the
% classical HH Nav1.7 implementation into the supplied axes.
%
% Usage:
%   plot_classicalHH_trace(ax)
%   plot_classicalHH_trace(ax, Iapp)
%
% Default:
%   Iapp = 40 uA/cm^2
%
% This function:
%   - runs one WT simulation
%   - runs one A863P simulation
%   - plots directly into the supplied axes
%   - does NOT create a figure
%   - does NOT save/export anything

if nargin < 2
    Iapp = 40;
end

%% =====================================================================
% Coordinate convention
% ======================================================================

REST_OFFSET = 40;

%% =====================================================================
% Kinetic scaling
% ======================================================================

PHI_M = 1;
PHI_H = 1;

%% =====================================================================
% Sodium parameters
%
% mpar = [Am Bm Cm Dm Em]
% hpar = [Dh Eh Bh Ch Ah]
% ======================================================================

mpar_WT = ...
    [499.901133, 146.493886, 11.155153, 4.000000, 18.000000];

mpar_A863P = ...
    [498.638342, 170.217998, 14.281340, 4.000000, 18.000000];

hpar_WT = ...
    [0.07, 20.000000, -37.614172, 11.980625, 0.850421];

hpar_A863P = ...
    [0.07, 20.000000, -19.023709, 14.471338, 0.727992];

%% =====================================================================
% Potassium parameters
% ======================================================================

An = 0.01671276;
Bn = 37.45325641;
Cn = 10.47919501;
Dn = 0.125;
En = 80;

npar = [An, Bn, Cn, Dn, En];

%% =====================================================================
% Membrane parameters
% ======================================================================

C   = 1;

gNa = 120;
gK  = 36;
gL  = 0.6;

ENa = 50;
EK  = -77;
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
m0 = 0.05;
h0 = 0.60;
n0 = 0.32;

init_cond = [V0, m0, h0, n0];

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
    @(t,y) DiffEquations_HH( ...
        t, y, Iapp, ...
        mpar_WT, ...
        hpar_WT, ...
        npar, ...
        REST_OFFSET, ...
        PHI_M, ...
        PHI_H, ...
        C, ...
        gNa, ENa, ...
        gK, EK, ...
        gL, EL, ...
        stim_start, ...
        stim_end), ...
    tspan, ...
    init_cond, ...
    opts_ode);

V_WT = sol_WT(:,1);

%% =====================================================================
% Simulate A863P
% ======================================================================

[t_A863P, sol_A863P] = ode113( ...
    @(t,y) DiffEquations_HH( ...
        t, y, Iapp, ...
        mpar_A863P, ...
        hpar_A863P, ...
        npar, ...
        REST_OFFSET, ...
        PHI_M, ...
        PHI_H, ...
        C, ...
        gNa, ENa, ...
        gK, EK, ...
        gL, EL, ...
        stim_start, ...
        stim_end), ...
    tspan, ...
    init_cond, ...
    opts_ode);

V_A863P = sol_A863P(:,1);

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
% alpha_m
% ======================================================================

function a = alphaM(p, V, off)

Am = p(1);
Bm = p(2);
Cm = p(3);

v = V + off;

x = (Bm - v) / Cm;



    a = ...
        Am * (Bm - v) / ...
        (exp(x) - 1);



end


%% =====================================================================
% beta_m
% ======================================================================

function b = betaM(p, V, off)

Dm = p(4);
Em = p(5);

v = V + off;

b = ...
    Dm * exp(-v / Em);

end


%% =====================================================================
% alpha_h
% ======================================================================

function a = alphaH(p, V, off)

Dh = p(1);
Eh = p(2);

v = V + off;

a = ...
    Dh * exp(-v / Eh);

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
    Ah / ...
    (1 + exp((Bh - v) / Ch));

end


%% =====================================================================
% alpha_n
% ======================================================================

function a = alphaN(p, V, off)

An = p(1);
Bn = p(2);
Cn = p(3);

v = V + off;

x = (Bn - v) / Cn;



    a = ...
        An * (Bn - v) / ...
        (exp(x) - 1);



end


%% =====================================================================
% beta_n
% ======================================================================

function b = betaN(p, V, off)

Dn = p(4);
En = p(5);

v = V + off;

b = ...
    Dn * exp(-v / En);

end


%% =====================================================================
% Classical HH differential equations
% ======================================================================

function dsol = DiffEquations_HH( ...
    t, ...
    sol, ...
    Iapp, ...
    mpar, ...
    hpar, ...
    npar, ...
    off, ...
    PHI_M, ...
    PHI_H, ...
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

%% Rate functions

alpha_m = ...
    alphaM(mpar, V, off);

beta_m = ...
    betaM(mpar, V, off);

alpha_h = ...
    alphaH(hpar, V, off);

beta_h = ...
    betaH(hpar, V, off);

alpha_n = ...
    alphaN(npar, V, off);

beta_n = ...
    betaN(npar, V, off);

%% Ionic currents

iNa = ...
    gNa * (m^3) * h * (V - ENa);

iK = ...
    gK * (n^4) * (V - EK);

iL = ...
    gL * (V - EL);

%% Applied current

if stim_start <= t && t <= stim_end

    iap = Iapp;

else

    iap = 0;

end

%% Differential equations

dVdt = ...
    (-iNa - iK - iL + iap) / C;

dmdt = ...
    PHI_M * ...
    (alpha_m * (1-m) - beta_m * m);

dhdt = ...
    PHI_H * ...
    (alpha_h * (1-h) - beta_h * h);

dndt = ...
    alpha_n * (1-n) - beta_n * n;

dsol = ...
    [dVdt; dmdt; dhdt; dndt];

end