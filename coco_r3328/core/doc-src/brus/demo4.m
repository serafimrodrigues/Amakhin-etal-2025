% 2D Brusselator system

% user-defined monitor function and constraind PO continuation

% This is an improved version over the class demo. We use function data and
% also provide explicit derivatives (see function file add_po_monitor).
% We obtain an enormous speed-up compared with the computations shown in
% class.

% see also: add_po_monitor

%% computation of primary branch
bd1 = coco('1', 'ode', 'isol', 'ep', ... % branch, TBF, IPT, BT
  @brus, [1;0], {'A' 'B'}, [1; 0], ... % F, x0, PNames, p0
  'B', [0 3]); % 'continuation parameter, computational domain

figure(1)
ode_plot_bd('1');
drawnow

%% computation of periodic orbits
HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 100], 'NPR', 5);
prob = ode_HB2po(prob, '', '1', HB(1));
prob = add_po_monitor(prob);
prob = coco_add_event(prob, 'UZ', 'uzr.dev', [0.5 1 1.5]);

bd3 = coco(prob, '3', [], {'B' 'uzr.dev'}, {[0 3]});

figure(1)
hold on
ode_plot_bd('3');
hold off
drawnow

%% computation of constrained periodic orbits

UZ = coco_bd_labs(bd3, 'UZ');
Y  = coco_bd_vals(bd3, UZ, 'uzr.dev');
[~,I] = min(abs(Y-1.5));

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'NPR', 5);
prob = ode_po2po(prob, '', '3', UZ(I));
prob = add_po_monitor(prob);
prob = coco_xchg_pars(prob, 'A', 'uzr.dev');

bd4 = coco(prob, '4', [], {'B' 'A' 'uzr.dev'}, {[0 3]});

figure(2)
ode_plot_bd('4', 'A', 'B');
grid on
drawnow

%% plot families of EPs and POs

figure(3)
clf
ode_plot_sol('4', 'B', 'x', 'x');
view([10 20])
drawnow
