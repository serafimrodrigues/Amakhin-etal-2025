% 2D Brusselator system

% plotting during continuation run
% add columns to bifurcation data table

% see also: add_cont_plot, ep_add_bddat, po_add_bddat

%% computation of primary branch
figure(10);
clf;
ah = axes();

prob = coco_prob();
prob = add_cont_plot(prob, ah);

bd1 = coco(prob, '1', 'ode', 'isol', 'ep', ... % branch, TBF, IPT, BT
  @brus, [1;0], {'A' 'B'}, [1; 0], ... % F, x0, PNames, p0
  'B', [0 3]); % 'continuation parameter, computational domain

figure(1)
ode_plot_bd('1')
grid on
drawnow

%% computation of locus of HB points
figure(10);
clf;
ah = axes();

prob = coco_prob();
prob = add_cont_plot(prob, ah);

HB = coco_bd_labs(bd1, 'HB');
bd2 = coco(prob, '2', 'ode', 'HB', 'HB', ... % branch, TBF, IPT, BT
  '1', HB(1), ... % primary branch name, solution label
  {'A' 'B'}, {[] [0 3]}); % 'continuation parameter, computational domain

figure(2)
ode_plot_bd('2')
grid on
drawnow

%% computation emerging periodic orbits
figure(10);
clf;
ah = axes();

HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 100]);
prob = add_cont_plot(prob, ah);

bd3 = coco(prob, '3', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '1', HB(1), ... % primary branch name, solution label
  {'B'}, {[0 3]}); % 'continuation parameter, computational domain

figure(1)
ode_plot_bd('1')
hold on
ode_plot_bd('3');
hold off
grid on
drawnow

%% plot families of EPs and POs

figure(2)
ode_plot_bd('1', 'B', 'x', 'x');
hold on
ode_plot_sol('3', 'B', 'x', 'x');
hold off
grid on
drawnow
