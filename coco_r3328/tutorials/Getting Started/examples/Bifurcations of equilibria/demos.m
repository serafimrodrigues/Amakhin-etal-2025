%% Bifurcation Diagrams - Equilibria
%
% Demos corresponding to Sections 3.1-3.5 in the Getting Started tutorial
% for COCO. For more information about the 'ep' toolbox, see
% EP-Tutorial.pdf in the coco/help folder. All the demos below use the
% inline construction of a continuation problem in the call to the coco
% entry-point function.

% Copyright (C) 2016 Frank Schilder, Harry Dankowicz, Jan Sieber

%% Section 3.1: Detecting saddle-node points

f = @(x,p) p-x.^2; % vectorized form of the fold normal form

% continue along a single curve of equilibria
coco('run1', 'ode', 'isol', 'ep', ... % branch label, toolbox family, initial point, branch type
  f, 0.5, 'p', 1, ... % vector field, initial state value, parameter name, initial parameter value
  'p', [-1 1]); % active continuation parameter, computational domain

% visualize the result
figure(1)
clf
theme = struct('special', {{'SN', 'EP'}}); % plotting theme
coco_plot_bd(theme, 'run1', 'p', 'x') % 'x' denotes the state vector, which is scalar here
axis tight
grid on

%% Section 3.2: Detecting branch points

f = @(x,p) p.*x-x.^2; % vectorized form of the transcritical normal form

% continue along a first curve of equilibria
coco('run1', 'ode', 'isol', 'ep', f, 0, 'p', -1, 'p', [-1 1]); 

% continue along a second curve of equilibria through a branch point
BP = coco_bd_labs('run1', 'BP'); % labels for BP points in run1
prob = coco_set(coco_prob, 'cont', 'branch', 'switch');
coco(prob, 'run2', 'ode', 'ep', 'ep', ... % branch label, toolbox family, initial point, branch type
  'run1', BP, ... % previous branch label, previous solution label
  'p', [-1 1]);

% visualize the results
figure(2)
clf
theme1 = struct('special', {{'BP', 'EP'}});
theme2 = struct('special', {{'EP'}});
hold on
coco_plot_bd(theme1, 'run1', 'p', 'x')
coco_plot_bd(theme2, 'run2', 'p', 'x')
hold off
axis tight
grid on

%% Section 3.3: Continuing saddle-node points

f = @(x,p) p(2,:)+x.*(p(1,:)-x.^2); % vectorized form of the pitchfork normal form

% continue along a first curve of equilibria
coco('run1', 'ode', 'isol', 'ep', f, 0, ...
  {'la' 'ka'}, [-2; 0], 'la', [-2 2]);

% continue along a second curve of equilibria through a branch point
BP = coco_bd_labs('run1', 'BP');
prob = coco_set(coco_prob, 'cont', 'branch', 'switch');
coco(prob, 'run2', 'ode', 'ep', 'ep', 'run1', BP, 'la', [-2 2]);

% continue along a third curve of equilibria
coco('run3', 'ode', 'isol', 'ep', f, 0, ...
  {'la' 'ka'}, [0.5; 0], 'ka', [-2 2]);

% continue along a curve of saddle-node bifurcations of equilibria
SN = coco_bd_labs('run3', 'SN');
coco('run4', 'ode', 'SN', 'SN', 'run3', SN(1), ...
  {'la' 'ka'}, {[-2 2] [-2 2]});

% visualize the results
figure(3)
clf
theme1 = struct('special', {{'BP', 'EP'}});
theme2 = struct('special', {{'EP'}});
theme3 = struct('special', {{'SN' 'EP'}});
hold on
coco_plot_bd(theme1, 'run1', 'la', 'ka', 'x')
coco_plot_bd(theme2, 'run2', 'la', 'ka', 'x')
coco_plot_bd(theme3, 'run3', 'la', 'ka', 'x')
coco_plot_bd(theme2, 'run4', 'la', 'ka', 'x')
hold off
axis tight
grid on
view(-15,25)

%% Section 3.4: Continuing Hopf bifurcations

% continue along a curve of equilibria
coco('run1', 'ode', 'isol', 'ep', ...
  @brus, [1; 0], {'A' 'B'}, [1; 0], ... % vectorized encoding of vector field in brus.m
  'B', [0 3]); 

% continue along a curve of Hopf bifurcations of equilibria
HB = coco_bd_labs('run1', 'HB');
coco('run2', 'ode', 'HB', 'HB', ...
  'run1', HB(1), {'A' 'B'}, {[] [0 3]});

% visualize the results
figure(4)
clf
hold on
theme1 = struct('special', {{'HB', 'EP'}});
coco_plot_bd(theme1, 'run1', 'B', 'A', '||x||_2') % ||x||_2 denotes the Euclidean norm of the state vector
theme2 = struct('special', {{'EP'}});
coco_plot_bd(theme2, 'run2', 'B', 'A', '||x||_2')
hold off
axis tight
grid on
view(-65,40)

%% Section 3.5: Performing parameter sweeps

% continue along multiple families of equilibria and visualize the results
figure(5)
clf
hold on
axis([0.12 0.22 1 7])
grid on
Nrun = 0;
theme = struct('special', {{'SN' 'HB'}});
for beta = linspace(1.20, 1.42, 23)
  Nrun = Nrun+1;
  runid = sprintf('run_beta_%d', Nrun);
  coco(runid, 'ode', 'isol', 'ep', @abc, [0; 0; 0], ... % vectorized encoding of vector field in abc.m
    {'al' 'si' 'D' 'B' 'be'}, [1; 0.04; 0.0; 8; beta], ...
    {'D' 'be'}, [0.0 0.25]);
  coco_plot_bd(theme, runid, 'D', '||x||_2');
  drawnow
end

% continue along a curve of saddle-node bifurcations and visualize the result
runid = 'run_beta_1';
SN = coco_bd_labs(runid, 'SN');
coco('run_SN', 'ode', 'SN', 'SN',  runid, SN(1), {'D' 'be'}, [0.1 0.25]);
theme_SN = struct('special', {{'FP'}});
coco_plot_bd(theme_SN, 'run_SN', 'D', '||x||_2');

% continue along a curve of Hopf bifurcations and neutral saddles and visualize the result
HB = coco_bd_labs(runid, 'HB');
prob = coco_set(coco_prob, 'cont', 'ItMX', 150);
coco(prob, 'run_HB', 'ode', 'HB', 'HB', runid, HB(1), ...
  {'D' 'be'}, [0.1 0.8]);
theme_HB = struct('special', {{'FP' 'BTP'}});
coco_plot_bd(theme_HB, 'run_HB', 'D', '||x||_2');
