Readme: Figure 1 – Hodgkin–Huxley Rate Constants and Steady-State Fits

Description:
This folder contains the code and data required to reproduce Figure 1.
The figure includes:
- Panels A–C: Rate constants (alpha and beta) for n, m, and h
- Panels D–F: Steady-state variables (n∞, m∞, h∞) with fitted curves

Main Script:
- figure1.m
  → Generates the full figure (Panels A–F)

Data Files:
- n_positive.xlsx
- m_positive.xlsx
- h_positive.xlsx
- beta_h.xlsx

These files contain the experimental Hodgkin–Huxley data used for fitting.

Computation Notes:
- The script performs curve fitting using lsqcurvefit.
- Optimization is done directly within the script.
- Runtime is short (a few seconds).
- No long simulations are required.

Output:
- The script generates Figure 1 directly.

Requirements:
- Optimization Toolbox (required for lsqcurvefit)

Notes:
- This script both performs the fitting and generates the figure.
- No precomputed data is required.

Alt Text
Six panels of gating data and fits plotted against membrane potential. Panels a, b and c show the canonical Hodgkin-Huxley gating kinetics for the n, m and h gating variables, using the original experimental measurements reported by Hodgkin and Huxley. In each of these panels, circular markers are the experimentally derived alpha (forward) rate constants, square markers are the experimentally derived beta (backward) rate constants, the navy curve is the classical alpha function, and the blue curve is the classical beta function. For n and m, alpha rises and beta falls with depolarization; for h, alpha falls toward zero and beta rises in an S-shaped curve to about 1 per ms. Panels d, e and f show Hill-type fits (navy curves) to quantities derived from the same original dataset and used in the modified model, namely n∞, m∞ and beta_h, with the original data as orange markers. In all three cases, the Hill functions closely reproduce the empirical voltage dependence, capturing both the curvature and asymptotic saturation of the original measurements. The n∞ fit rises more gradually, reflecting potassium activation, while the m∞ and beta_h fits show the sharper transitions associated with sodium activation and inactivation.