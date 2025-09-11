function prob = state_ev_locate_disc(prob)
% locate event using hybrid subdivision + Newton method

% evaluate event function at new subdivision point

evidx           = prob.cont.events.evidx;
cseg            = prob.cseg;
[prob, cseg]    = cseg.eval_p(prob, evidx);
chart           = cseg.curr_chart;
[prob, chart.e] = prob.efunc.events_F(prob, chart.p);

v   = chart.x;
h   = cseg.h;
e0  = cseg.ev0;
evs = chart.e;
e   = evs(evidx);

% compute new subdivision interval
e1 = cseg.ev1; % experimenting with discrete test functions
if (e1-e)*(e-e0)>0 || e==e1
  cseg.v1 = v;
  cseg.h1 = h;
  cseg.ev1 = e;
else
  cseg.v0 = v;
  cseg.h0 = h;
  cseg.ev0 = e;
end

% check convergence

if abs(cseg.h1-cseg.h0)/(1+cseg.ptlist{1}.R) <= prob.cont.TOL
  % take right end point to guarantee that event occurs between
  % cseg.u0 and chart.x (necessary for boundary events to avoid chopping off
  % events at boundary)
  chart.x         = cseg.v1;
  % bug: comment the next 4 lines
  [prob chart]         = prob.cseg.update_TS(prob, chart);
  [prob chart]         = prob.cseg.update_t(prob, chart);
  [prob chart chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
  [prob chart.e]       = prob.efunc.events_F (prob, chart.p);
  % [opts cseg chart] = cseg.chart_at(opts, cseg.h1, evidx, chart); % Harry added

  cseg.curr_chart = chart;
  prob.cseg       = cseg;
	% go to add_<PointType>
	prob.cont.state = prob.cont.locate_add_state;
	return
end

% initialise subdivision method
e0 = cseg.ev0;
e1 = cseg.ev1;

v0 = cseg.v0;
h0 = cseg.h0;
v1 = cseg.v1;
h1 = cseg.h1;

la1 = cseg.la1;
la2 = cseg.la2;

if e0~=e1 % experimenting with discrete test functions
  e0 = -1;
  e1 = 1;
end

% compute subdivision point
if abs(e0)<=abs(e1)
	v = la2*v0+la1*v1;
	h = la2*h0+la1*h1;
else
	v = la1*v0+la2*v1;
	h = la1*h0+la2*h1;
end
cseg.h = h;

% interpolate
[prob cseg chart hh] = cseg.chart_at(prob, h, evidx, chart);

% initialise xfunc
prob = coco_emit(prob, 'update_h', hh);

% initialise nwtn
[prob chart f1] = prob.efunc.F(prob, chart, chart.x);
[prob chart f2] = prob.efunc.F(prob, chart, v);

if norm(f1)<norm(f2)
  [prob chart accept x] = prob.corr.init(prob, chart, chart.x);
else
  [prob chart accept x] = prob.corr.init(prob, chart, v);
end

chart.x         = x;
cseg.curr_chart = chart;
prob.cseg       = cseg;

% go to next state
if accept
  % go to locate_reg
  prob.cont.state      = 'ev_locate_disc';
else
  % next state is correct, then go to locate_disc
  prob.cont.state      = 'co_correct';
  prob.cont.next_state = 'ev_locate_disc';
  prob.cont.err_state  = prob.cont.locate_warn_state;
end
