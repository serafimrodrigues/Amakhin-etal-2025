%% Post-processing and analysis
%
% Demos corresponding to Sections 5.1 and 5.2 in the Getting Started
% tutorial for COCO. For more information about the 'ep' and 'po'
% toolboxes, see EP-Tutorial.pdf and PO-Tutorial.pdf in the coco/help
% folder. For more information about the coco_bd_*, coco_print_bd, and
% coco_plot_bd, and coco_plot_sol utilities, type help followed by the
% command name on the Matlab command line.

% Copyright (C) 2016 Frank Schilder, Harry Dankowicz, Jan Sieber

%% Section 5.1: Bifurcation data

% assign output cell array directly to variable
f = @(x,p) p-x.^2;
bd = coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]); %#ok<NASGU>

% load cell array from disk
bd = coco_bd_read('run1');

% explore content of output cell array

coco_bd_labs('run1', 'SN')
coco_bd_labs(bd, 'SN')
coco_bd_labs('run1', 'all')

coco_bd_lab2idx('run1', 5:7)
coco_bd_lab2idx(bd, 5:7)

coco_bd_idxs('run1', 'SN')
coco_bd_idxs(bd, 'SN')
coco_bd_idxs('run1', 'all')

p  = coco_bd_col('run1', 'p');
px = coco_bd_col('run1', {'p', 'x'});

coco_bd_vals('run1', 'SN', {'p', 'x'})
coco_bd_vals(bd, [], {'p' 'x'})

% print subset of output cell array to screen
coco_print_bd('run1', {'p', 'eigs'})

% manipulate output data for visualization
coco('run1', 'ode', 'isol', 'ep', ...
  @brus, [1; 0], {'A' 'B'}, [1; 0], 'B', [0 3]);

figure(1)
clf
hold on
theme = struct('special', {{'HB'}});
coco_plot_bd(theme,'run1', 'B', @(x) [x; x], 'eigs', @(x) real(x))
coco_plot_bd(theme,'run1', 'B', @(x) [x; x], 'eigs', @(x) imag(x))
grid on
hold off

figure(2)
clf
coco_plot_bd(theme,'run1', 'eigs', @(x) real(x), 'eigs', @(x) imag(x))
grid on

%% Section 5.2: Individual solutions

% read solution from disk
HB = coco_bd_labs('run1', 'HB');
sol = ep_read_solution('run1', HB) %#ok<NOPTS>

sol.x
sol.p

% Build a vector field using symcoco
syms x1 x2 x3 al si D B be
f = [D*(1-x1)*exp(x3)-x1;
  D*(1-x1-si*x2)*exp(x3)-x2;
  B*D*(1-x1+al*si*x2)*exp(x3)-(1+be)*x3];
F = sco_sym2funcs(f, {[x1; x2; x3], [al; si; D; B; be]}, ...
  {'x', 'p'}, 'filename', 'sys_abc');
funcs = {F(''), F('x'), F('p'), F({'x','x'}), F({'x','p'}), F({'p','p'})};

eprunid = 'run_ep1';
% continue family of equilibria
coco(eprunid, 'ode', 'isol', 'ep', funcs{:}, [0 0 0], ...
  {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.55], ...
  'D', [0.0 0.4]);

% continue along family of periodic orbits from a Hopf bifurcation
HB = coco_bd_labs(eprunid, 'HB');
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 255]);
coco(prob, 'run_po11', 'ode', 'HB', 'po', eprunid, HB(1), ...
  'D', [0.0 0.4]);

% continue along family of saddle-node bifurcations of periodic orbits
porunid = 'run_po11';
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 100], 'h_max', 5);
SN = coco_bd_labs(porunid, 'SN');
coco(prob, 'po_run_SN', 'ode', 'SN', 'SN', ...
  porunid, SN(1), {'be', 'D'}, {[1.55 1.58], [0 0.4]});

% read solution from disk 
FP = coco_bd_labs('po_run_SN', 'FP');
sol = po_read_solution('po_run_SN', FP) %#ok<NOPTS>

% visualize the results
clf
theme = struct('special', {{'FP'}});
coco_plot_sol(theme, 'po_run_SN', '', 'x', 'x', 'x')
grid on
