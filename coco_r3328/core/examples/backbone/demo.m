%% Algebraic problem with linearly dependent constraints

eqs = @(a,b,P) [a*(cos(P)-1)+b*sin(P); P*(b*(cos(P)-1)-a*sin(P)); P*b];

prob = coco_prob;
prob = coco_add_func(prob, 'linosc', ...
  @(p,d,u) deal(d, eqs(u(1),u(2),u(3))), [], 'zero', 'u0', [1; 0.1; 2*pi]);
prob = coco_add_pars(prob, 'inactive_pars', 1, 'a', 'inactive');
prob = coco_add_pars(prob, 'active_pars', 2:3, {'b' 'P'}, 'active');

%% 0-dimensional manifold
coco(prob, 'run', [], 0, {'b' 'P'})

%% 1-dimensional manifold
coco(prob, 'run', [], 1, {'a', 'b', 'P'})

%% Incompatible assignment
coco(prob, 'run', [], 0, {'a' 'b' 'P'})

%% Incompatible assignment with fix
prob = coco_add_pars(prob, 'active_a', 1, 'mu_a', 'active');
coco(prob, 'run', [], 0, {'mu_a' 'b' 'P'}) 

%% Incompatible assignment with full Newton steps
prob = coco_set(prob, 'corr', 'MaxStep', inf);
coco(prob, 'run', [], 0, {'a' 'b' 'P'})

%% Periodic orbit problem with linearly dependent constraints

% We study the effects of nonlinear hardening on the free periodic response
% of a nonlinear oscillator. The continuation problem structure encoded
% below includes three monitor functions that evaluate to the problem
% parameter and the period with corresponding continuation parameters 'd'
% and 'po.period', with 'd' initially inactive and 'po.period' initially
% active, resulting in an overall dimensional deficit of 0.

period = 6;
t0 = (0:period/20:period)';
x0 = .37*[sin(2*pi/period*t0) cos(2*pi/period*t0)];
prob = coco_prob();
prob = coco_set(prob, 'po', 'bifus', 'off');
prob = ode_isol2po(prob, '', @bistable, t0, x0, 'd', 0);

% 1-dimensional manifold
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'norm', inf);
coco(prob, 'backbone', [], 1, 'po.period', [2*pi/1.6 2*pi/0.7]);
coco(prob, 'backbone', [], 1, {'po.period' 'd'}, [2*pi/1.6 2*pi/0.7]);

figure(1); clf; hold on; grid on; box on
thm = struct('ustab', '', 'lspec', {{'b--', 'LineWidth', 2}}, 'xlab', '2\pi/T');
coco_plot_bd(thm, 'backbone', 'po.period', @(T) 2*pi./T, ...
    '||po.orb.x||_{L_2[0,T]}')
axis([0.7 1.3 0 inf]); hold off

% 0-dimensional manifold
prob = coco_xchg_pars(prob, 'd', 'po.period');
prob = coco_set(prob, 'cont', 'NAdapt', 0);
coco(prob, 'run1', [], 0);
coco(prob, 'run1', [], 0, {'d' 'po.period'});


