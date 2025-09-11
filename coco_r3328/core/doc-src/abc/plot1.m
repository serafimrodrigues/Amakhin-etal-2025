% ABC system from lecture notes of E. Doedel
% similar to figure on slide 60

% computation of family of EPs
% computation of saddle-node-curve
% computation of Hopf-curve
% 3D plot of bifurcation diagram

% see also: ep_plot2

%% Sweep branches for different values of beta

figure(1); clf
drawnow

hold off
NRun = 0;
for beta = linspace(1.20, 1.42, 23)
  NRun = NRun+1;
  run = sprintf('beta_%d', NRun);
  % coco(run, 'ode', 'isol', 'ep', @abc, [0 0 0], ...
  %   {'al' 'si' 'D' 'B' 'be'}, [1 0.04 0.0 8 beta], ...
  %   {'D' 'be'}, [0.0 0.25]);
  ode_plot_bd(run)
  axis([0.12 0.22 1 7])
  grid on
  drawnow
  if ~ishold; hold on; end
end
hold off

%% compute saddle-node curve

bd1 = coco_bd_read('beta_1');
SN = coco_bd_labs(bd1, 'SN');

% coco('2', 'ode', 'SN', 'SN',  'beta_1', SN(1), {'D' 'be'}, [0.1 0.25]);

hold on
ode_plot_bd('2')
hold off
drawnow

%% compute Hopf curve

bd1 = coco_bd_read('beta_1');
HB = coco_bd_labs(bd1, 'HB');

% prob = coco_prob();
% prob = coco_set(prob, 'cont', 'ItMX', 150);
% coco(prob, '3', 'ode', 'HB', 'HB',  'beta_1', HB(1), ...
%   {'D' 'be'}, [0.1 0.8]);

hold on
ode_plot_bd('3')
hold off
drawnow
