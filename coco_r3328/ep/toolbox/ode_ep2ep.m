function prob = ode_ep2ep(prob, oid, varargin)
%ODE_EP2EP   Reconstruct equilibrium point continuation problem from saved solution.
%
% PROB = ODE_EP2EP(PROB, OID, VARARGIN)
% VARARGIN = { RUN [SOID] LAB [OPTS] }
% OPTS = { '-ep-end' | '-end-ep' | '-var' VECS | '-no-var' | '-no-pars'}
%
% Reconstruct continuation problem for dynamic or static equilibria from an
% equilibrium point associated with the same vector field that was computed
% and saved to disk in a previous continuation run. At least the name RUN
% of the previous continuation run and the solution label LAB denoting the
% previously computed equilibrium point must be given.
%
% PROB : Continuation problem structure.
% OID  : Target object instance identifier (string). Pass the empty string
%        '' for a simple continuation of equilibria.
%
% See ODE_ISOL2EP for more details on PROB and OID.
%
% RUN  : Run identifier (string or cell-array of strings). Name of the run
%        from which to reconstruct the continuation problem.
% SOID : Source object instance identifier (string, optional). If the
%        argument SOID is omitted, OID is used. Pass the empty string ''
%        for OID and omit SOID for a simple continuation of equilibria.
%        Pass non-trivial object identifiers if an instance of the EP
%        toolbox is part of a composite continuation problem.
% LAB  : Solution label (integer). The integer label assigned by COCO to an
%        equilibrium point during the continuation run RUN.
%
% OPTS : '-ep-end', '-end-ep', '-var' VECS, '-no-var', and '-no-pars'
%        (optional, multiple options may be given). Either '-ep-end' or
%        '-end-ep' mark the end of input to ODE_EP2EP. The option '-var'
%        indicates the inclusion of the variational problem J*v=w, where
%        the initial solution guess for v is given by the content of VECS.
%        Alternatively, in the absence of the option '-var', the option
%        '-no-var' indicates the exclusion of the variational problem even
%        if this were included in the continuation run RUN.
%
% See also: ODE_ISOL2EP, EP_READ_SOLUTION, EP_ADD, EP_ADD_VAR

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: ode_ep2ep.m 3317 2025-01-07 21:10:49Z hdankowicz $

grammar   = 'RUN [SOID] LAB [OPTS]';
args_spec = {
   'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
  'SOID',     '',   'str', 'soid', oid, 'read', {}
   'LAB',     '',   'num',  'lab',  [], 'read', {}
  };
opts_spec = {
     '-ep-end',         '',    '',    'end', {}
     '-end-ep',         '',    '',    'end', {}
        '-var',     'vecs',    [],   'read', {}
     '-no-var',    'novar', false, 'toggle', {}
    '-no-pars',   'nopars', false, 'toggle', {}
  };
[args, opts] = coco_parse(grammar, args_spec, opts_spec, varargin{:});

[sol, data] = ep_read_solution(args.soid, args.run, args.lab);

if opts.nopars
  data.pnames = {};
end

data = ode_init_data(prob, data, oid, 'ep');

if ~isempty(opts.vecs)
  assert(isnumeric(opts.vecs) && data.xdim == size(opts.vecs,1), ...
    '%s: incompatible specification of vectors of perturbations', ...
    mfilename);
  [prob, data] = ep_add(prob, data, sol, '-cache-jac');
  sol.var = struct('v', opts.vecs);
  prob = ep_add_var(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('VAR'));
elseif isfield(sol, 'var') && ~opts.novar
  [prob, data] = ep_add(prob, data, sol, '-cache-jac');
  prob = ep_add_var(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('VAR'));
else
  prob = ep_add(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info());
end

end
