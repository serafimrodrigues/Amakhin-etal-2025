% ABC system from lecture notes of E. Doedel
% similar to figure on slide 102

% computation of families of EPs and POs
% branch switching at Hopf points
% adding max-values to bifurcation data

% see also: ep_plot2

%% BDiag for beta=1.55

figure(3)
clf
drawnow

% prob = coco_prob();
% prob = ep_add_bddat(prob);
% 
% bd1 = coco(prob, '21', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
%   {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.55], ...
%   {'D' 'be'}, [0.0 0.4]);

subplot(2,2,1)
ode_plot_bd('21', 'D', '||x||')
axis([0.15 0.4 1 6])
grid on
drawnow

HB = coco_bd_labs(bd1, 'HB');

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 255]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '22', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '21', HB(1), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,1)
hold on
ode_plot_bd(struct('axlabs', false), '22', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 90]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '23', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '21', HB(2), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,1)
hold on
ode_plot_bd(struct('axlabs', false), '23', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

%% BDiag for beta=1.56

% prob = coco_prob();
% prob = ep_add_bddat(prob);
% 
% bd1 = coco(prob, '31', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
%   {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.56], ...
%   {'D' 'be'}, [0.0 0.4]);

subplot(2,2,2)
ode_plot_bd('31', 'D', '||x||')
axis([0.15 0.4 1 6])
grid on
drawnow

% HB = coco_bd_labs(bd1, 'HB');
% 
% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 260]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '32', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '31', HB(1), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,2)
hold on
ode_plot_bd(struct('axlabs', false), '32', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '33', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '31', HB(2), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,2)
hold on
ode_plot_bd(struct('axlabs', false), '33', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

%% BDiag for beta=1.57

% prob = coco_prob();
% prob = ep_add_bddat(prob);
% 
% bd1 = coco(prob, '41', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
%   {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.57], ...
%   {'D' 'be'}, [0.0 0.4]);

subplot(2,2,3)
ode_plot_bd('41', 'D', '||x||')
axis([0.15 0.4 1 6])
grid on
drawnow

% HB = coco_bd_labs(bd1, 'HB');
% 
% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 240]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '42', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '41', HB(1), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,3)
hold on
ode_plot_bd(struct('axlabs', false), '42', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '43', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '41', HB(3), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,3)
hold on
ode_plot_bd(struct('axlabs', false), '43', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

%% BDiag for beta=1.58

% prob = coco_prob();
% prob = ep_add_bddat(prob);
% 
% bd1 = coco(prob, '51', 'ode', 'isol', 'ep', @abc, [0 0 0], ...
%   {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 1.58], ...
%   {'D' 'be'}, [0.0 0.4]);

subplot(2,2,4)
ode_plot_bd('51', 'D', '||x||')
axis([0.15 0.4 1 6])
grid on
drawnow

% HB = coco_bd_labs(bd1, 'HB');
% 
% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 70]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '52', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '51', HB(1), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,4)
hold on
ode_plot_bd(struct('axlabs', false), '52', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'NAdapt', 1, 'ItMX', [0 105]);
% prob = po_add_bddat(prob);
% 
% coco(prob, '53', 'ode', 'HB', 'po', ... % prob.struct., branch, TBF, IPT, BT
%   '51', HB(3), ... % primary branch name, solution label
%   {'D' 'be'}, [0.0 0.4]); % 'continuation parameter, computational domain

subplot(2,2,4)
hold on
ode_plot_bd(struct('axlabs', false), '53', 'D', '||po.orb.x||')
hold off
axis([0.15 0.4 1 6])
grid on
drawnow
