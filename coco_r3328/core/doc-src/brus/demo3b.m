% 2D Brusselator system

% user-defined monitor function and constraind EP continuation
% Version a: add test_y as inactive parameter =   active constraint
% Version b: add test_y as   active parameter = inactive constraint

% Version b: 'A' and 'Y' must be exchanged

% see also: demo3a, test_y

%% computation of primary branch
prob = coco_prob();
prob = ode_isol2ep(prob, '', @brus, [1;0], {'A' 'B'}, [1; 0]); % F, x0, PNames, p0
[data uidx] = coco_get_func_data(prob, 'ep', 'data', 'uidx');
prob = coco_add_func(prob, 'test.y', @test_y, [], 'active', 'Y', ...
  'uidx', uidx(data.ep_eqn.x_idx(2)));
prob = coco_add_event(prob, 'UZ', 'Y', [0.5 1.5 2.5]);

bd1 = coco(prob, '1', [], {'B'}, [0 3]);

% compare with (no error):
% coco(prob, 'test', [], {'B' 'Y'}, [0 3]);
% or even
% coco(prob, 'test', [], {'B' 'A' 'Y'}, [0 3]);

figure(1)
ode_plot_bd('1');
grid on
drawnow

%% computation of EP with restriction y=1.5
UZ = coco_bd_labs(bd1, 'UZ');
Y  = coco_bd_vals(bd1, UZ, 'Y');
[~,I] = min(abs(Y-1.5));

prob = coco_prob();
prob = ode_ep2ep(prob, '', '1', UZ(I));
[data uidx] = coco_get_func_data(prob, 'ep', 'data', 'uidx');
prob = coco_add_func(prob, 'test.y', @test_y, [], 'active', 'Y', ...
  'uidx', uidx(data.ep_eqn.x_idx(2)));

% exchange inactive parameter 'A' with active parameter 'Y'
% ==> 'A' will vary while 'Y' will now remain constant
prob = coco_xchg_pars(prob, 'A', 'Y');

bd2 = coco(prob, '2', [], {'B' 'A' 'Y'}, {[0 3]});

% compare with:
% coco(prob, 'test', [], {'B' 'Y' 'A'}, {[0 3]});
% or even
% coco(prob, 'test', [], {'B' 'A'}, {[0 3]});

figure(2)
ode_plot_bd('2', 'A', 'B');
drawnow
