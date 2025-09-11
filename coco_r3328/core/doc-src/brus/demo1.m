% 2D Brusselator system

% computation of family of EPs
% computation of Hopf-curve
% branch-switching to POs at HB
% plotting of EPs and POs in one diagram

% see also: ep_plot, po_plot

%% computation of primary branch
bd1 = coco('1', 'ode', 'isol', 'ep', ... % branch, TBF, IPT, BT
  @brus, [1;0], {'A' 'B'}, [1; 0], ... % F, x0, PNames, p0
  'B', [0 3]); % 'continuation parameter, computational domain

figure(1)
clf
ode_plot_bd('1')
grid on
drawnow

%% computation of locus of HB points
HB = coco_bd_labs(bd1, 'HB');
bd2 = coco('2', 'ode', 'HB', 'HB', ... % branch, TBF, IPT, BT
  '1', HB(1), ... % primary branch name, solution label
  {'A' 'B'}, {[] [0 3]}); % 'continuation parameter, computational domain

figure(2)
clf
ode_plot_bd('2')
grid on
drawnow

%% computation emerging periodic orbits
HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 100], 'NPR', 5);

bd3 = coco(prob, '3', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '1', HB(1), ... % primary branch name, solution label
  {'B'}, {[0 3]}); % 'continuation parameter, computational domain

figure(1)
clf
ode_plot_bd('1')
hold on
ode_plot_bd('3');
hold off
grid on
drawnow

%% plot families of EPs and POs

figure(2)
clf
ode_plot_bd('1', 'B', 'x', 'x');
hold on
ode_plot_sol('3', 'B', 'x', 'x');
hold off
grid on
drawnow
