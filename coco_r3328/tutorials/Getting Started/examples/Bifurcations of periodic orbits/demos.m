%% Bifurcation Diagrams - Periodic Orbits
%
% Demos corresponding to Sections 4.1-4.5 in the Getting Started tutorial
% for COCO. For more information about the 'ep' and 'po' toolboxes, see
% EP-Tutorial.pdf and PO-Tutorial.pdf in the coco/help folder. 

% Copyright (C) Frank Schilder, Harry Dankowicz, Jan Sieber

%% Section 4.1: Continuing from Hopf bifurcations

figure(1); clf; hold on; grid on; box on
axis([-1.5 1 -2 4 0 1.6]); view(3)

% continue along a family of equilibria and visualize the result
prob = coco_prob; % initialize the continuation problem structure
prob = ode_isol2ep(prob, '', @hopf, [0; 0], {'p1', 'p2'}, [-1; 1]);
coco(prob, 'ep_run', [], 'p1', [-1 1]); % [] indicates problem defined in prob

thm = struct('special', {{'EP', 'HB'}});
coco_plot_bd(thm, 'ep_run', 'p1', 'p2', '||x||_2')
drawnow

% continue along a family of periodic orbits from a Hopf bifurcation and visualize the result
HB = coco_bd_labs('ep_run', 'HB');
prob = coco_prob; % initialize the continuation problem structure
prob = ode_HB2po(prob, '', 'ep_run', HB);
coco(prob, 'po_run', [], 'p1', [-1 1]); % [] indicates problem defined in prob

thm = struct('special', {{'EP', 'SN'}}, 'zlab', '||x||_2');
coco_plot_bd(thm, 'po_run', 'p1', 'p2', '||x||_{2,MPD}')
drawnow

% continue along a family of saddle-node bifurcations of periodic orbits and visualize the result
SN = coco_bd_labs('po_run', 'SN');
prob = coco_prob;
prob = ode_po2SN(prob, '', 'po_run', SN(1));
coco(prob, 'po_SN_run', [], {'p1', 'p2'}, {[-1 1] [0.001 3]});

thm = struct('special', {{'EP'}}, ...
  'xlab', 'p_1', 'ylab', 'p_2', 'zlab', '||x||_2');
coco_plot_bd(thm, 'po_SN_run', 'p1', 'p2', '||x||_{2,MPD}')
drawnow

% continue along a family of Hopf bifurcations of equilibria and visualize the result
prob = coco_prob;
prob = ode_ep2HB(prob, '', 'ep_run', HB);
prob = coco_add_event(prob, 'UZ', 'p2', setdiff(-2:0.5:3,1));
coco(prob, 'ep_HB_run', [], {'p1' 'p2'}, {[-1 1] [-2.01 3.01]});

thm = struct('special', {{'EP'}});
coco_plot_bd(thm, 'ep_HB_run', 'p1', 'p2', '||x||_2')
drawnow

% continue along families of periodic orbits from Hopf bifurcations and visualize the reults
labs = coco_bd_labs('ep_HB_run', 'UZ');
thm = struct('special', {{'EP', 'SN'}}, 'zlab', '||x||_2');
for lab=labs
  runid = sprintf('po%d_run', lab);
  prob = coco_prob;
  prob = ode_HB2po(prob, '', 'ep_HB_run', lab);
  prob = coco_set(prob, 'cont', 'LogLevel', 0);
  coco(prob, runid, [], {'p1' 'p2'}, [-1.01 1]);
  coco_plot_bd(thm, runid, 'p1', 'p2', '||x||_{2,MPD}')
  drawnow
end
hold off

%% Section 4.2: Finding isolated curves and branch points

figure(6)
clf
theme_ep = struct();
theme_ep.special = {'HB'};
theme_po = struct();
theme_po.lspec = {{'k-', 'LineWidth', 1}, {'k--', 'LineWidth', 1}};
theme_po.special = {'SN'};

PtMX = [255 90; 260 100; 240 100; 70 100];
beta = 1.55:0.01:1.58;
for i=1:4
  subplot(2,2,i)
  axis([0.15 0.4 1 10])
  grid on
  hold on
  eprunid = sprintf('run_ep%d', i);
  % continue family of equilibria and visualize the result
  coco(eprunid, 'ode', 'isol', 'ep', @abc, @abc_dx, @abc_dp, [0; 0; 0], ...
    {'al' 'si' 'D' 'B' 'be'}, [1; 0.04; 0; 8; beta(i)], ...
    'D', [0.0 0.4]);
  coco_plot_bd(theme_ep, eprunid, 'D', 'MAX(x)', 3);
  drawnow
  %  continue along family of periodic orbits from a Hopf bifurcation and visualize the result
  HB = coco_bd_labs(eprunid, 'HB');
  prob = coco_prob;
  porunid = sprintf('run_po1%d', i);
  prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 PtMX(i,1)]);
  coco(prob, porunid, 'ode', 'HB', 'po', eprunid, HB(1), ...
    'D', [0.0 0.4]);
  coco_plot_bd(theme_po, porunid, 'D', 'MAX(x)', 3)
  drawnow
  % continue along family of periodic orbits from a Hopf bifurcation and visualize the result
  prob = coco_prob;
  prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 PtMX(i,2)]);
  porunid = sprintf('run_po2%d', i);
  coco(prob, porunid, 'ode', 'HB', 'po', eprunid, HB(3), ...
    'D', [0.0 0.4]);
  coco_plot_bd(theme_po, porunid, 'D', 'MAX(x)', 3);
  drawnow
  hold off
end

% continue along two families of periodic orbits and visualize the results
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 200]);
porunid = 'run_po3';
coco(prob, porunid, 'ode', 'po', 'po', 'run_po13', 15, ...
  'be', [beta(3) beta(4)]);

prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 160]);
porunid = 'run_po34';
coco(prob, porunid, 'ode', 'po', 'po', 'run_po3', 3, ...
  'D', [0.0 0.4]);

hold on
coco_plot_bd(theme_po, porunid, 'D', 'MAX(x)', 3);
drawnow
hold off

% continue along family of saddle-node bifurcations of periodic orbits
porunid = 'run_po11';
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'PtMX', [0 100], 'h_max', 5);
SN = coco_bd_labs(porunid, 'SN');
coco(prob, 'po_run_SN', 'ode', 'SN', 'SN', ...
  porunid, SN(1), {'be', 'D'}, {[1.55 1.58], [0 0.4]});

%% Section 4.3: A web of bifurcations

% continue along curve of equilibria at origin
x0     = [0; 0; 0];
pnames = {  'nu', 'be',  'ga',  'r', 'a3', 'b3'};
p0     = [-0.65 ; 0.5 ; -0.6 ; 0.6 ; 0.3 ;  0.9];
funcs  = {@tor, @tor_dx, @tor_dp};
prob = coco_prob;
prob = ode_isol2ep(prob, '', funcs{:}, x0, pnames, p0);
eprunid = 'ep_run';
coco(prob, eprunid, [], 'nu', [-0.65, -0.55]);

% continue curve of Hopf bifurcations of equilibrium at origin
HB = coco_bd_labs(eprunid, 'HB');
prob = coco_prob;
prob = ode_HB2HB(prob, '', eprunid, HB);
hbrunid = 'ep_hb_run';
coco(prob, hbrunid, [], {'nu', 'be'}, [-0.65, -0.55]);

% continue along first curve of periodic orbits from Hopf bifurcation
prob = coco_prob;
prob = ode_HB2po(prob, '', eprunid, HB);
prob = coco_set(prob, 'cont', 'NAdapt', 5, 'PtMX', [100 0]);
porunid1 = 'po_run1';
coco(prob, porunid1, [], 'nu', [-0.65, -0.55]);

% continue along second curve of periodic orbits from branch point
BP = coco_bd_labs(porunid1, 'BP');
prob = coco_prob;
prob = ode_po2po(prob, '', porunid1, BP(1));
prob = coco_set(prob, 'cont', 'NAdapt', 5, 'PtMX', [100 0], ...
  'branch', 'switch');
porunid2 = 'po_run2';
coco(prob, porunid2, [], 'nu', [-0.65, -0.55]);

% continue along curve of saddle-node bifurcations of periodic orbits
SN = coco_bd_labs(porunid1, 'SN');
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 5, 'PtMX', [100 13]);
porunid3 = 'po_run_SN';
coco(prob, porunid3, 'ode', 'SN', 'SN', ...
	porunid1, SN(2), {'nu' 'be'}, [-0.65, -0.55]);

% continue along curve of period-doubling bifurcations of periodic orbits
PD = coco_bd_labs(porunid2, 'PD');
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 5);
porunid4 = 'po_run_PD';
coco(prob, porunid4, 'ode', 'PD', 'PD', ...
  porunid2, PD(1), {'nu' 'be'}, [-0.65, -0.55]);

% continue along curve of torus bifurcations of periodic orbits
TR = coco_bd_labs(porunid2, 'TR');
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 5, 'PtMX', [32, 29]);
porunid5 = 'po_run_TR';
coco(prob, porunid5, 'ode', 'TR', 'TR', ...
  porunid2, TR(1), {'nu' 'be'}, [-0.65, -0.55]);

% continue along curve of period-doubled periodic orbits
prob = coco_prob;
prob = coco_set(prob, 'cont', 'NAdapt', 5, 'PtMX', [0 100]);
porunid6 = 'po_run_db';
coco(prob, porunid6, 'ode', 'PD', 'po', porunid4, 4, ...
  'nu', [-0.65, -0.55]);

% visualize the results
figure(1); clf; hold on; grid on
thm = struct('zlab', '||x||_2');
thm.special = {'EP', 'HB'};
coco_plot_bd(thm, eprunid, 'nu', 'be', '||x||_2')
thm.special = {'EP', 'BP'};
coco_plot_bd(thm, hbrunid, 'nu', 'be', '||x||_2')
thm.special = {'EP', 'SN', 'BP'};
coco_plot_bd(thm, porunid1, 'nu', 'be', '||x||_{2,MPD}')
thm.special = {'EP', 'PD', 'TR'};
coco_plot_bd(thm, porunid2, 'nu', 'be', '||x||_{2,MPD}')
thm.special = {'EP'};
coco_plot_bd(thm, porunid3, 'nu', 'be', '||x||_{2,MPD}')
coco_plot_bd(thm, porunid4, 'nu', 'be', '||x||_{2,MPD}')
coco_plot_bd(thm, porunid5, 'nu', 'be', '||x||_{2,MPD}')
thm.special = {'EP', 'PD'};
coco_plot_bd(thm, porunid6, 'nu', 'be', '||x||_{2,MPD}')
hold off; view(-192,44)
