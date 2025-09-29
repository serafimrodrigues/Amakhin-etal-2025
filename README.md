# This repository contain codes related to the paper

Dmitry Amakhin, Anton Chizhov, Guillaume Girier, Mathieu Desroches, Jan Sieber and Serafim Rodrigues<br>
_Observing hidden neuronal states in experiments_<br>
Submitted, 2025.

# Instructions for recovering figures
## Initial preprocessing
* enter folder `FigureSI1/`
* execute script `process_cell1_5.m`. This loads files `vcruns.mat` and `ccruns.mat` from folder `matfiles` and performs smoothing and identification of spikes, slow parts of CC runs, creating file `mat_files/processed_runs.mat`.
* enter folder `Figure2
* execute script `process_for Fig2.m`. This loads files `fig2a_231215_IN_raw.mat`, `fig2a_231215_IN_raw.mat`  from folder `matfiles`  and performs smoothing and identification of spikes, slow parts of CC runs, creating file `mat_files/processed_fig2runs.mat`.

## Figures
* Enter `Figure1/panel_b`, execute `Fig1b.m` for figure 1(b). Execute `FigSI9.m` for figure SI9.
* Enter `Figure1/panel_c`, execute `Fig1b.m` for figure 1(c).
* Enter `Figure2`, execute `Fig2.m` for figures 2(a,b).
* Enter `Figure3/panel_a`, execute `Fig3a.m` for figure 3(a).
* Enter `Figure3/panel_b`, execute `Fig3b.m` for figure 3(b).
* Enter `Figure4`, execute `Fig4.m` for figure 4.
* Enter `Figure5`, execute `Fig5.m` for figure 5.
