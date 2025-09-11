%% User-Initiated Enhancements
%
% Demos corresponding to Sections 7.1-7.4 in the Getting Started
% tutorial for COCO. For more information about the 'ep' and 'po'
% toolboxes, see EP-Tutorial.pdf and PO-Tutorial.pdf in the coco/help
% folder.

% Copyright (C) 2016-2023 Frank Schilder, Harry Dankowicz, Jan Sieber

%% Section 7.1: Monitoring properties of equilibria

% A model of oxidation of carbon monoxide on platinum analyzed in Tutorial
% IV: Two-parameter bifurcation analysis of equilibria and limit cycles
% with MATCONT, by Yu.A. Kuznetsov, September 20, 2011 (see
% http://www.staff.science.uu.nl/~kouzn101/NBA/LAB4.pdf).

% construct function generator
if exist('sys_bykov', 'file')~=2
  syms x y s Q1 Q2 Q3 Q4 Q5 Q6 K
  z  = 1-x-y-s;
  xp = 2*Q1*z^2-2*Q5*x^2-Q3*x*y;
  yp = Q2*z-Q6*y-Q3*x*y;
  sp = Q4*z-K*Q4*s;
  F = sco_sym2funcs([xp; yp; sp], {[x; y; s], ...
    [Q1; Q2; Q3; Q4; Q5; Q6; K]}, ...
    {'x', 'p'}, 'filename', 'sys_bykov', 'maxorder', 3);
else
  F = sco_gen(@sys_bykov);
end

x0     = [0.24; 0.04; 0.51];
pnames = {'p1' 'p2' 'p3' 'p4' 'p5' 'p6' 'p7'};
p0     = [2.5; 0.5; 10; 0.0675; 1; 0.1; 0.4];
funcs  = {F(''), F('x'), F('p'), F({'x','x'}), F({'x','p'}), F({'p','p'})};

% continue along a curve of equilibria
prob = coco_prob;
prob = ode_isol2ep(prob, '', funcs{:}, x0, pnames, p0);
eprunid = 'ep_run';
coco(prob, eprunid, [], 'p2', [0.4 3]);

% append computed data to the output cell array
prob = ep_add_bddat(prob, '', 'svds', ...
  @(d,x,p) min(svds(feval(F('x'),x,p))));
coco(prob, eprunid, [], 'p2', [0.4 3]);

% continue along a curve of saddle-node bifurcations
labs = coco_bd_labs(eprunid, 'SN');
snrunid = 'SN-curve';
coco(snrunid, 'ode', 'SN', 'SN', ...
  eprunid, labs(2), {'p2' 'p7'}, {[0.4 3], [0 8]});

% continue along a curve of Hopf bifurcations
labs = coco_bd_labs(eprunid, 'HB');
prob = coco_prob;
prob = ode_HB2HB(prob, '', eprunid, labs(1));
prob = coco_set(prob, 'cont', 'PtMX', [90 0]);
hbrunid = 'HB-curve';
coco(prob, hbrunid, [], {'p2' 'p7'}, {[0.4 3], [0 8]});

% append computed data to the output cell array
prob = ep_HB_add_bddat(prob, '', 'freq', ...
  @(d,x,p,v,k) sqrt(max(k,0)));
coco(prob, hbrunid, [], {'p2' 'p7'}, {[0.4 3], [0 8]});

% append additional computed data to the output cell array
data = struct('dfdxhan', F('x'), 'Dfdxdxhan', F({'x*v','x*v'}), ...
  'Dfdxdxdxhan', F({'x*v','x*v','x*v'}), 'nanflag', 1);
prob = ep_HB_add_bddat(prob, '', 'L1', @lyapunov, 'data', data);
prob = coco_set(prob, 'cont', 'PtMX', [90 0]);
coco(prob, hbrunid, [], {'p2' 'p7'}, {[0.4 3], [0 8]});

% visualize the results
figure(1)
clf
hold on
thm = struct();
thm.special = {'HB', 'SN'};
coco_plot_bd(thm, eprunid, 'p2', 'x')
coco_plot_bd(snrunid, 'p2', 'x')
thm = struct();
thm.special = {'BTP'};
thm.ustab = 'L1';
thm.ustabfun = @(x) 1+(~isnan(x) & x>0)+2*isnan(x);
thm.usept = {};
thm.lspec = {{'r-', 'LineWidth', 1.5}, {'r-.', 'LineWidth', 1.5}};
thm.xlab  = 'p_2';
coco_plot_bd(thm, hbrunid, 'p2', 'x')
hold off
grid on
axis([0.5 2 0 0.16])

%% Section 7.2: Continuing generalized Hopf bifurcations

% continue along the family of Hopf bifurcations
labs = coco_bd_labs(eprunid, 'HB');
prob = coco_prob;
prob = ode_HB2HB(prob, '', eprunid, labs(2));
% append regular embedded monitor function and detect a zero crossing
data = struct('dfdxhan', F('x'), 'Dfdxdxhan', F({'x*v','x*v'}), ...
  'Dfdxdxdxhan', F({'x*v','x*v','x*v'}), 'nanflag', 1);
prob = ep_HB_add_func(prob, '', 'lyap', @lyapunov, data, ...
  'regular', 'L1');
prob = coco_add_event(prob, 'GH', 'L1', 0);
prob = coco_set(prob, 'cont', 'PtMX', [85 0]);
coco(prob, 'HB-curve', [], {'p2' 'p7', 'L1'}, {[0.4 3], [0 8]});

figure(2)
clf
hold on
thm = struct();
thm.special = {'HB', 'SN'};
coco_plot_bd(thm, eprunid, 'p2', 'x')
coco_plot_bd('SN-curve', 'p2', 'x')
thm = struct();
thm.special = {'BTP', 'GH'};
thm.GH = {'kp', 'MarkerFaceColor', 'k', 'MarkerSize', 10};
thm.ustab = 'L1';
thm.ustabfun = @(x) 1+(~isnan(x) & x>0)+2*isnan(x);
thm.usept = {'BTP', 'GH'};
thm.lspec = {{'r-', 'LineWidth', 1.5}, {'r-.', 'LineWidth', 1.5}};
thm.xlab  = 'p_2';
coco_plot_bd(thm, 'HB-curve', 'p2', 'x')
hold off
grid on
axis([0.5 2 0 0.16])

% continue along a curve of generalized Hopf bifurcations using an inactive monitor function
labs = coco_bd_labs('HB-curve', 'GH');
prob = coco_prob;
prob = ode_HB2HB(prob, '', 'HB-curve', labs(1));
data = struct('dfdxhan', F('x'), 'Dfdxdxhan', F({'x*v','x*v'}), ...
  'Dfdxdxdxhan', F({'x*v','x*v','x*v'}), 'nanflag', 1);
prob = ep_HB_add_func(prob, '', 'lyap', @lyapunov, data, ...
  'inactive', 'L1');
prob = coco_set_parival(prob, 'L1', 0);
prob = coco_set(prob, 'cont', 'PtMX', 50);
coco(prob, 'GH-curve1', [], {'p2' 'p7' 'p1'}, {[0.4 3], [0 8]});

% continue along a curve of generalized Hopf bifurcations using a zero function
labs = coco_bd_labs('HB-curve', 'GH');
prob = coco_prob;
prob = ode_HB2HB(prob, '', 'HB-curve', labs(2));
data = struct('dfdxhan', F('x'), 'Dfdxdxhan', F({'x*v','x*v'}), ...
  'Dfdxdxdxhan', F({'x*v','x*v','x*v'}), 'nanflag', 1);
prob = ep_HB_add_func(prob, '', 'lyap', @lyapunov, data, 'zero');
prob = coco_set(prob, 'cont', 'PtMX', 50);
coco(prob, 'GH-curve3', [], {'p2' 'p7' 'p1'}, {[0.4 3], [0 8]});


%% Section 7.3: Monitoring properties of periodic orbits

% construct function generator
if exist('sys_hopf', 'file')~=2
  syms r2 x1 x2 p1 p2
  r2 = x1^2+x2^2;
  F = sco_sym2funcs(...
    [x1*(p1+p2*r2-r2^2)-x2; x2*(p1+p2*r2-r2^2)+x1], ...
    {[x1; x2], [p1; p2]}, {'x', 'p'}, 'filename', 'sys_hopf');
else
  F = sco_gen(@sys_hopf);
end

% continue along family of equilibria
f = struct('f', F(''), 'dfdx', F('x'), 'dfdp', F('p'), ...
  'dfdx_dx', F('x*v'), 'dfdxdx_dx', F({'x','x*v'}), ...
  'dfdpdx_dx', F({'p','x*v'}));
prob = coco_prob;
prob = ode_isol2ep(prob, '', f, [0; 0], {'p1', 'p2'}, [-1; 1]);
coco(prob, 'ep_run', [], 'p1', [-1 1]);

% continue along a family of periodic orbits from a Hopf bifurcation
HB = coco_bd_labs('ep_run', 'HB');
prob = coco_prob;
prob = ode_HB2po(prob, '', 'ep_run', HB);
prob = coco_set(prob, 'cont', 'PtMX', [50 0]);
prob = po_add_bddat(prob, '', 'cx1', @fourier, 'data', struct('n', 1));
coco(prob, 'po_run', [], {'p1' 'p2'}, [-1 1]);

% continue along a family of saddle-node bifurcations of periodic orbits
SN = coco_bd_labs('po_run', 'SN');
prob = coco_prob;
prob = ode_po2SN(prob, '', 'po_run', SN(1));
prob = po_add_bddat(prob, '', 'cx1', @fourier, 'data', struct('n', 1));
coco(prob, 'po_SN_run', [], {'p1', 'p2'}, {[-1 1] [0.001 3]});

figure(1)
clf
hold on
coco_plot_bd('po_run', 'p1', 'p2', 'cx1', @(x) 2*real(x(1,:)))
thm = struct();
thm.lspec = {{'ro', 'MarkerFaceColor', 'r'}, {'ro'}};
coco_plot_bd(thm, 'po_run', ...
  {'cx1', 'p2'}, @(x,y) (2*real(x(1,:))).^4-y.*(2*real(x(1,:))).^2, ...
  'p2', 'cx1', @(x) 2*real(x(1,:)));
coco_plot_bd('po_SN_run', 'p1', 'p2', 'cx1', @(x) 2*real(x(1,:)))
thm.lspec = {'ko', 'MarkerFaceColor', 'k'};
thm.xlab = 'p1';
thm.ylab = 'p2';
thm.zlab = 'r';
coco_plot_bd(thm, 'po_SN_run', ...
  'cx1', @(x) -(2*real(x(1,:))).^4, ...
  'cx1', @(x) 2*(2*real(x(1,:))).^2, ...
  'cx1', @(x) 2*real(x(1,:)));
hold off
grid on
view(3)

%% Section 7.4: Tracking and constraining orbit maxima

% construct function generator
if exist('sys_marsden', 'file')~=2
syms x1 x2 x3 p1 p2
F = sco_sym2funcs(...
  [p1*x1+x2+p2*x1^2; -x1+p1*x2+x2*x3; (p1^2-1)*x2-x1-x3+x1^2], ...
  {[x1; x2; x3], [p1; p2]}, {'x', 'p'}, 'filename', 'sys_marsden');
else
  F = sco_gen(@sys_marsden);
end

% continue along family of equilibria
f = struct('f', F(''), 'dfdx', F('x'), 'dfdp', F('p'));
prob = coco_prob;
prob = ode_isol2ep(prob, '', f, [0; 0; 0], {'p1', 'p2'}, [-1; 6]);
coco(prob, 'ep_run', [], 'p1', [-1 1]);

% continue along a family of periodic orbits from a Hopf bifurcation
HB = coco_bd_labs('ep_run', 'HB');
prob = coco_prob;
prob = ode_HB2po(prob, '', 'ep_run', HB);
prob = coco_set(prob, 'cont', 'PtMX', [50 0], 'NAdapt', 1);
coco(prob, 'po_run', [], {'p1' 'po.period'}, [-1 1]);

figure(1)
clf
coco_plot_sol('po_run', '', 't', 'x')
grid on
axis([0 inf -0.3 0.25])

% continue along family of periodic orbits while tracking x1 and x1' for fixed t
prob = coco_prob;
prob = ode_po2po(prob, '', 'po_run', 5);
prob = coco_set(prob, 'cont', 'PtMX', [0 50], 'NAdapt', 1);
prob = po_add_func(prob, '', 'max', @slope, struct('idx', 1), ...
  {'trs', 'xrs', 'xtrs'}, 'inactive', 'u0', 5.17);
coco(prob, 'new_po_run1', [], {'p1' 'po.period', 'xrs', 'xtrs'}, [-1 1]);
figure(2)
clf
hold on
coco_plot_sol('new_po_run1', '', 't', 'x')
tx = coco_bd_vals('new_po_run1', 'all', {'trs', 'xrs'});
plot(tx(1,:), tx(2,:), 'ro', 'MarkerFaceColor', 'r');
hold off
grid on
box on
axis([0 inf -0.3 0.25])

% continue along family of periodic orbits while tracking maximum in x1
prob = coco_set_parival(prob, 'xtrs', 0);
coco(prob, 'new_po_run2', [], {'p1' 'po.period', 'trs', 'xrs'}, [-1 1]);
figure(3)
clf
hold on
coco_plot_sol('new_po_run2', '', 't', 'x')
tx = coco_bd_vals('new_po_run2', 'all', {'trs', 'xrs'});
plot(tx(1,:), tx(2,:), 'ro', 'MarkerFaceColor', 'r');
hold off
grid on
box on
axis([0 inf -0.3 0.25])

% continue along family of periodic orbits with fixed maximum in x1
coco(prob, 'new_po_run3', [], {'p1' 'po.period', 'trs', 'p2'}, [-1 1]);
figure(4)
clf
hold on
coco_plot_sol('new_po_run3', '', 't', 'x')
tx = coco_bd_vals('new_po_run3', 'all', {'trs', 'xrs'});
plot(tx(1,:), tx(2,:), 'ro', 'MarkerFaceColor', 'r');
hold off
grid on
box on
axis([0 inf -0.3 0.25])
