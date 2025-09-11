%% The Bratu boundary-value problem
%
% The Bratu boundary-value problem is given by the autonomous partial
% differential equation u_t = u_xx + la*u + mu*exp(u) and the boundary
% conditions u(0,t) = u(1,t) = 0. In looking for equilibrium solutions, we
% rely on a finite-difference discretization of the one-dimensional
% Laplacian and perform continuation of equilibria first with la=0 and
% later along a branch of saddle-node bifurcations under simultaneous
% variations in mu and la.

% Figure 1 shows a one-dimensional family of equilibria under variations
% in mu, for fixed la. Saddle-node bifurcations are identified by green
% circles. Figure 2 shows a one-dimensional family of saddle-node
% equilibria under simultaneous variation in mu and la. The figure shows
% the result of starting continuation from a saddle-node bifurcation
% detected during equilibrium continuation.

%% Initial encoding

% The continuation problem encoded below includes two monitor functions
% that evaluate to the problem parameters mu and lambda, respectively, and
% two corresponding inactive continuation parameters 'mu' and 'la'. Its
% dimensional deficit equals 0. The call to the coco entry-point function
% indicates a desired manifold dimension of 1. To this end, the
% continuation parameter 'mu' is released and allowed to vary during
% continuation.

% Finite-difference discretization of the Bratu equilibrium boundary-value
% problem defined using an inline, anonymous function. The order of
% discretization is parameterized by N.

N  = 20;
D  = diag(-2*ones(N-1,1)) + diag(ones(N-2,1),-1) + diag(ones(N-2,1),1);
D  = N^2*D;

bratu    = @(u,p) D*u + p(2)*u            + p(1)*exp(u);
bratu_dx = @(u,p) D   + p(2)*eye(N-1,N-1) + p(1)*diag(exp(u));
bratu_dp = @(u,p) [exp(u) u];

u0 = zeros(N-1,1);
p0 = [0; 0];

% Initialize continuation problem and settings associated with toolbox
% constructor and atlas algorithm.

prob = coco_prob();
prob = coco_set(prob, 'ode', 'vectorized', false);
prob = coco_set(prob, 'cont', 'PtMX', 50);

%% Compute 'classical' bifurcation diagram for la = 0 as in AUTO

% Include toolbox-specific 'ep.test.SN' continuation parameter in screen
% output for visual inspection of saddle-node bifurcations monitor
% function.

fprintf('\n Run=''%s'': Continue equilibria along primary branch.\n', ...
  'bratu1');

bd1 = coco(prob, 'bratu1', 'ode', 'isol', 'ep', ...
  bratu, bratu_dx, bratu_dp, u0, {'mu' 'la'}, p0, ... % ep toolbox arguments
  1, {'mu' 'ep.test.SN'}, [0 4]);                     % cont toolbox arguments

%% Test restart of continuation from end point

labs = coco_bd_labs(bd1, 'EP');

fprintf(...
  '\n Run=''%s'': Continue equilibria from point %d in run ''%s''.\n', ...
  'bratu2', labs(end), 'bratu1');

bd2 = coco(prob, 'bratu2', 'ode', 'ep', 'ep', ...
  'bratu1', labs(end), ...         % ep toolbox arguments
  1, {'mu' 'ep.test.SN'}, [0 4]);  % cont toolbox arguments

%% Start continuation along solutions to saddle-node equilibrium problem

% The continuation problem encoded below includes two monitor functions
% that evaluate to the problem parameters mu and lambda, respectively, and
% two corresponding inactive continuation parameters 'mu' and 'la'. Its
% dimensional deficit equals -1. The call to the coco entry-point function
% indicates a desired manifold dimension of 1. To this end, the
% continuation parameters 'mu' and 'la' are both released and allowed to
% vary during continuation.

labs = coco_bd_labs(bd1, 'SN');

prob = coco_set(prob, 'cont', 'PtMX', 100);

% The 'branch point' detected at mu=0 corresponds to a nontrivial
% eigenfunction of the linear PDE u_t = u_xx + la*u (the bifurcation
% diagram becomes degenerate); see also demo pdeeig

fprintf(...
  '\n Run=''%s'': Continue SN points from point %d in run ''%s''.\n', ...
 'bratu3', labs(1), 'bratu1');

bd3 = coco(prob, 'bratu3', 'ode', 'SN', 'SN', ...
  'bratu1', labs(1), ...              % ep toolbox arguments
  1, {'mu' 'la'}, {[-4 4] [-2 20]});  % cont toolbox arguments

%% Graphical representation of stored solutions

% "One-parameter continuation" of equilbiria
figure(1); clf
thm = struct('special', {{'SN'}});
coco_plot_bd(thm, 'bratu2')
grid on

% "Two-parameter continuation" of saddle-node bifurcations
figure(2); clf; hold on
coco_plot_bd('bratu1', 'la', 'mu', '||x||_2')
thm = struct('special', {{'BP'}});
coco_plot_bd(thm, 'bratu3', 'la', 'mu', '||x||_2')
hold off; grid on; view(3)

%% Multidimensional continuation with atlas_kd

% This section performs continuation along a surface of approximate
% equilibrium solutions for the Bratu boundary-value problem 
% u_t = u_xx+la*u+mu*exp(u) under variations in the problem parameters mu
% and la. Saddle-node bifurcations are detected and labeled by SN.

% Since the manifold is two-dimensional and includes folds, at least three
% continuation parameters must be active for atlas_kd to not encounter
% singularities. In addition to 'mu' and 'la', this encoding uses a scaled
% version of u(N/2) in order to ensure that all three variables vary over
% similar ranges.

prob = coco_prob;
prob = ode_isol2ep(prob, '', bratu, bratu_dx, bratu_dp, ...
  u0, {'mu' 'la'}, p0);
prob = coco_add_func(prob, 'scale', @(p,d,u) deal(d,5*u), [], ...
  'active', 'u(N/2)', 'uidx', floor(N/2));
prob = coco_set(prob, 'cont', 'MaxRes', 1, 'PtMX', 500, 'NPR', 100);
coco(prob, 'bratu4', [], 2, {'mu' 'la' 'u(N/2)'}, ...
  {[-4 4], [-2 20], [-2 10]});

atlas = coco_bd_read('bratu4', 'atlas');
figure(3); clf;
plot_atlas_kd(atlas.charts, 1,2,3)
axis equal; axis([-4 4 -2 20 -2 10])
view(3); grid on; hold on; box on
alpha 0.4; light('Position', [1.5 1.5 1.5], 'Style', 'local')
thm = struct('xlab', '\mu', 'ylab', '\lambda', ...
  'lspec', {{'k', 'LineWidth', 3}});
coco_plot_bd(thm, 'bratu3', 'mu', 'la', 'x', @(x) 5*x(floor(N/2),:))
