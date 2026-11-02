# Hill-HH gating and excitability

MATLAB figure code and supporting data for:

**Hill-based reformulation of the Hodgkin-Huxley model for mapping gating changes to neuronal excitability**

Batoul Saab, Jihad Fahs, and Arij Daou. *Scientific Reports* (2026).

[DOI: 10.1038/s41598-026-78934-z](https://doi.org/10.1038/s41598-026-78934-z)

The study examines explicit mapping of selected gating descriptors into a Hill-based Hodgkin-Huxley formulation, preservation of HH-like excitability, and retrospective Nav1.7 mutation benchmarks. Both formulations require kinetic assumptions; the study does not establish general superiority in quantitative biological prediction.

## What is included

The authors' MATLAB scripts, per-figure text READMEs, MAT/CSV/Excel inputs, and supplied PDF/PNG figure exports are organized by manuscript figure. The scientific scripts and data are preserved unchanged. `docs/source_manifest.json` records their SHA-256 checksums. Cited journal PDFs are not redistributed; references and DOI links remain in the text files.

This is a **figure-generation package**, not a complete pipeline that recomputes all parameter sweeps and fitting ensembles from scratch. Several figures use precomputed results; Figure 5b also has explicit summary-value fallbacks. See [reproduction notes](docs/REPRODUCIBILITY.md) before interpreting regenerated plots.

## Requirements

- MATLAB. The manuscript reports MATLAB R2024b; that version is the reference environment, not a verified minimum supported version.
- **Signal Processing Toolbox** for Figure 2 (`findpeaks`).
- **Optimization Toolbox** for Figure 6 (`lsqcurvefit`).
- Figure 5b uses `boxchart` when available, with a `boxplot` fallback requiring Statistics and Machine Learning Toolbox. Other version-specific plotting calls may also restrict compatibility.

MATLAB execution and pixel-for-pixel agreement have not been tested as part of repository preparation. File presence and copied-file integrity were checked; runtime and scientific validation remain separate tasks.

## Generate a figure

Download/clone the repository and make its root the MATLAB current folder. For example:

```matlab
run_figure('figure1')
run_figure('figure6')
run_figure('supplementary_figure5')
```

The optional launcher changes to the selected figure folder, calls its entry point, and restores the previous folder. Alternatively, open the figure folder directly in MATLAB and run the entry point listed below. **Scripts can overwrite the supplied exports or saved panel data in that folder.** Work in a disposable copy if you want to preserve the original files.

| Figure | Folder | Entry point | Inputs / work performed |
| --- | --- | --- | --- |
| 1 | `figure1` | `figure1.m` | Analytic gating curves; self-contained |
| 2 | `figure2` | `figure2.m` | Embedded current-pair arrays and firing simulations |
| 3 | `figure3` | `figure3.m` | Saved regime maps in `cache_excitability` |
| 4 | `figure4` | `figure4.m` | Saved feature sweeps in `cache` |
| 5 | `figure5` | `figure5.m` | Panel functions, embedded summaries, rescaling MAT data; see limitations below |
| 6 | `figure6` | `figure6.m` | Four Excel tables; Hill fitting with `lsqcurvefit` |
| 7 | `figure7` | `figure7.m` | Three Excel tables and previously fitted parameters |
| S1 | `supplementary_figure1` | `supplementry_figure1.m` | Self-contained voltage simulations; filename spelling is intentional |
| S2 | `supplementary_figure2` | `supplementary_figure2.m` | Saved spike-feature data in `cache_scatter` |
| S3 | `supplementary_figure3` | `Supplementary_Figure_3.m` | Gating/trace functions and saved rheobase/frequency-current results |
| S4 | `supplementary_figure4` | `Supplementary_Figure_4.m` | Saved ensembles in `tau.mat` |
| S5 | `supplementary_figure5` | `Supplementary_Figure_5.m` | Two frequency-current CSVs; gating calculations and voltage simulations |
| S6 | `supplementary_figure6` | `Supplementary_Figure_6.m` | Saved classical and Hill fitting ensembles |

## Citation and reuse

Please cite the paper using the DOI above; machine-readable metadata is provided in `CITATION.cff`. No software/data reuse license has been selected for this deposit. Public availability, if enabled, should not be interpreted as an additional reuse license.
