% ABC system from lecture notes of E. Doedel
% similar to figure on slide 102

% computation of families of EPs and POs
% branch switching at Hopf points
% adding max-values to bifurcation data

% see also: ep_plot2

%% BDiag for beta=1.55

figure(1); clf; 
drawnow

subplot(2,2,1); hold on

prob = coco_prob();

bd1 = coco(prob, '21', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
  {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.55], ...
  {'D' 'be'}, [0.0 0.4]);

thm = struct();
thm.ylab = 'MAX(X_3)';
thm.special = {'HB'};
coco_plot_bd(thm, '21', 'D', 'MAX(x)', 3)
axis([0.15 0.4 1 10]); grid on
drawnow

HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 255]);

coco(prob, '22', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '21', HB(1), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain
thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '22', 'D', 'MAX(x)', 3)
drawnow

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 90]);

coco(prob, '23', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '21', HB(2), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '23', 'D', 'MAX(x)', 3)
drawnow
hold off

%% BDiag for beta=1.56

subplot(2,2,2); hold on

prob = coco_prob();

bd1 = coco(prob, '31', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
  {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.56], ...
  {'D' 'be'}, [0.0 0.4]);

thm = struct();
thm.ylab = 'MAX(X_3)';
thm.special = {'HB'};
coco_plot_bd(thm, '31', 'D', 'MAX(x)', 3)
axis([0.15 0.4 1 10]); grid on
drawnow

HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 260]);

coco(prob, '32', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '31', HB(1), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '32', 'D', 'MAX(x)', 3)
drawnow

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);

coco(prob, '33', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '31', HB(2), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '33', 'D', 'MAX(x)', 3)
drawnow
hold off

%% BDiag for beta=1.57

subplot(2,2,3); hold on

prob = coco_prob();

bd1 = coco(prob, '41', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
  {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.57], ...
  {'D' 'be'}, [0.0 0.4]);

thm = struct();
thm.ylab = 'MAX(X_3)';
thm.special = {'HB'};
coco_plot_bd(thm, '41', 'D', 'MAX(x)', 3)
axis([0.15 0.4 1 10]); grid on
drawnow

HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 240]);

coco(prob, '42', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '41', HB(1), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '42', 'D', 'MAX(x)', 3)
drawnow

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);

coco(prob, '43', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '41', HB(3), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '43', 'D', 'MAX(x)', 3)
drawnow
hold off

%% BDiag for beta=1.58

subplot(2,2,4); hold on

prob = coco_prob();

bd1 = coco(prob, '51', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
  {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.58], ...
  {'D' 'be'}, [0.0 0.4]);

thm = struct();
thm.ylab = 'MAX(X_3)';
thm.special = {'HB'};
coco_plot_bd(thm, '51', 'D', 'MAX(x)', 3)
axis([0.15 0.4 1 10]); grid on
drawnow

HB = coco_bd_labs(bd1, 'HB');

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 70]);

coco(prob, '52', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '51', HB(1), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '52', 'D', 'MAX(x)', 3)
drawnow

prob = coco_prob();
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);

coco(prob, '53', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
  '51', HB(3), ... % primary branch name, solution label
  {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

thm = struct();
thm.axlabs = false;
thm.special = {'SN'};
coco_plot_bd(thm, '53', 'D', 'MAX(x)', 3)
drawnow
hold off
