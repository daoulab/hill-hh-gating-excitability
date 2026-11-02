# Reproduction notes

## Scope

This deposit contains all seven main-figure folders and six supplementary-figure folders supplied by the authors. Plotting saved simulation results is distinct from recomputing the original analyses. Original per-folder text READMEs are retained for provenance; this document clarifies the following inconsistencies found during packaging.

## Figure 5b: missing optional CSVs and summary fallbacks

`Figure_PanelB.m` calls `ratiosFrom` for:

- `Nav17_Hill_results.csv`
- `Nav17_HillAH_results.csv`
- `Nav17_HH_shift_summary.csv`
- `Nav17_HH_starts_fixedComp_boltzmann.csv`
- `Nav17_HH_Boltzmann_summary.csv`
- `Nav17_HH_starts_ensemble_boltz.csv`
- `Nav17_HH_tau_rescaling_grid.csv`

These files are absent from the supplied package. The author confirmed proceeding without them. The script reports `FALLBACK` and uses embedded values instead. Some fallbacks have three elements representing reported extrema and a central value; treating those as a sample does not reconstruct full ensemble box statistics. `PanelB_data.mat` is also supplied, but the current panel function builds and saves its own `B` structure rather than loading that file.

The two saved ensembles in the S6 folder and the grid MAT file in Figure 5 are retained. No CSVs were synthesized from them, and no scientific plotting logic was altered. A future update could use verified raw ensemble exports to restore full-distribution plotting.

## Other precomputed results

- Figures 3 and 4 load cached sweep/classification results; their upstream sweep generators are not included.
- S2 loads cached scatter data; its upstream extraction/sweep generator is not included.
- S3 loads saved rheobase and frequency-current results, while also computing gating and simulating traces.
- S4 loads `tau.mat`; its error message mentions `panelA_prepare.m`, which is not in this package. The supplied MAT file is the available input.
- S5 loads frequency-current CSVs and simulates voltage traces. `Supp5_traces.mat` is a supplied output that the script can overwrite.
- S6 loads accepted ensembles rather than rerunning their fits.
- Figure 5c accepts a CSV or the supplied `Nav17_HH_tau_rescaling_results.mat`; the missing CSV does not by itself prevent the MAT-input route.
- Figure 7 uses previously fitted coefficients, not a fresh model-selection fit.

## README and dependency corrections

- The original Figure 6 README calls the figure/script Figure 1; the actual entry point is `figure6.m`. Its bottom panels fit n-infinity, m-infinity and beta-h, not h-infinity.
- The S1 entry point on disk is `supplementry_figure1.m`, although its text README spells it differently.
- The S2 activation-amplitude cache for the modified model is named `amplitude_scatter_modified.mat`; use the filenames read by the script rather than the alternative spelling in its README.
- Figure 2 uses `findpeaks`, so Signal Processing Toolbox is required despite the original README saying no additional toolbox.
- Journal PDFs mentioned in READMEs were omitted from this repository; obtain them through the recorded DOI links. They are not computational inputs.

## Validation performed for this deposit

The copied files were checked against their original SHA-256 hashes; MAT headers/compressed payloads and Excel ZIP containers were checked for structural integrity. Scientific scripts and numerical input bytes were not edited. MATLAB simulations, optimization convergence, figure equivalence, and correspondence between deposited code and manuscript numerical claims have not been executed/verified in this packaging step.
