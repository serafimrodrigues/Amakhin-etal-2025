%% Section 6.1: Vector fields
 
% anonymous function
f = @(x,p) p-x.^2;
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

% function file
f = @fold;
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

% symbolic vector field
syms x p
F = sco_sym2funcs(p-x^2, {x, p}, {'x', 'p'}, 'maxorder', 0);
f = F('');
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

% vector field struct
f = struct('f', F(''));
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

%% Section 6.2: Partial derivatives

% anonymous function
f = @(x,p) p-x.^2; dfdx = @(x,p) -2*x; dfdp = @(x,p) ones(1,numel(p));
coco('run1', 'ode', 'isol', 'ep', f, dfdx, dfdp, 0.5, 'p', 1, 'p', [-1 1]);

% function files and struct
f = struct('f', @fold, 'dfdx', @fold_dx, 'dfdp', @fold_dp);
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

% symbolic vector field
syms x p
F = sco_sym2funcs(p-x^2, {x, p}, {'x', 'p'});
f = struct('f', F(''), 'dfdx', F('x'), 'dfdp', F('p'));
coco('run1', 'ode', 'isol', 'ep', f, 0.5, 'p', 1, 'p', [-1 1]);

% multiple dimensions

syms x1 x2 x3 p1 p2 p3 p4 p5 p6 p7 z
z = 1-x1-x2-x3;
F = sco_sym2funcs(...
  [2*p1*z^2-2*p5*x1^2-p3*x1*x2; p2*z-p6*x2-p3*x1*x2; p4*z-p7*p4*x3], ...
  {[x1; x2; x3], [p1; p2; p3; p4; p5; p6; p7]}, {'x', 'p'});
f = F('');
dfdxdx = F({'x','x'});

x = rand(3,4); p = rand(7,4);
size(f(x,p))
size(dfdxdx(x,p))
max(abs(f(x,p)-bykov(x,p)), [], 'all')
max(abs(dfdxdx(x,p)-bykov_dxdx(x,p)), [], 'all')

%% Section 6.3: Directional derivatives

% first and second directional derivatives
Dfdx = F('x*v');
Dfdxdx = F({'x*v','x*v'});

% construct vector field with directional derivatives up to third order
syms x1 x2 A B BB
BB = x1*(B-x1*x2);
F = sco_sym2funcs([A-BB-x1; BB], {[x1, x2], [A,B]}, {'x', 'p'}, ...
  'maxorder', 3);
f = struct('f', F(''), 'dfdx', F('x'), 'dfdp', F('p'));

% continue along branch of equilibria and load solution data for Hopf bifurcation
coco('ep_run', 'ode', 'isol', 'ep', ...
  f, [1; 0], {'A' 'B'}, [1; 0], 'B', [0 3]);
HB  = coco_bd_labs('ep_run', 'HB');
sol = ep_read_solution('ep_run', HB);

% compute first Lyapunov coefficient
data = struct('dfdxhan', F('x'), 'Dfdxdxhan', F({'x*v','x*v'}), ...
  'Dfdxdxdxhan', F({'x*v','x*v','x*v'}));
lyapunov(data, sol.x, sol.p, sol.var.v(:,1), sol.hb.k)

% continue along branch of periodic orbits emanating from Hopf bifurcation
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1);
coco(prob, 'po_run', 'ode', 'HB', 'po', 'ep_run', HB, 'B', [0 3])

% visualize the results
figure(1)
clf
hold on
thm = struct();
thm.special = {'EP'};
coco_plot_bd(thm, 'po_run', 'B', 'MAX(x)', 1)
thm.special = {'EP', 'HB'};
thm.ylab = 'max(x_1)';
coco_plot_bd(thm, 'ep_run', 'B', 'x')
grid on
hold off
axis([0 3 0 inf])
