function prob = ode_coll2coll(prob, oid, varargin)
%ODE_COLL2COLL   Reconstruct trajectory segment continuation problem from saved solution.
%
% PROB = ODE_COLL2COLL(PROB, OID, VARARGIN)
% VARARGIN = { RUN [SOID] LAB [OPTS] }
% OPTS = { '-coll-end' | '-end-coll' | '-var' VECS | '-no-var' | '-no-pars'}
%
% Reconstruct continuation problem for trajectory segments from a
% trajectory segment that was obtained and saved to disk in a previous
% continuation. To restart from a saved trajectory segment, at least the
% name RUN of the continuation run and the solution label LAB must be
% given.
%
% PROB : Continuation problem structure.
% OID  : Target object instance identifier (string). Pass the empty string
%        '' for a simple continuation of trajectory segments.
%
% See ODE_ISOL2COLL for more details on PROB and OID.
%
% RUN  : Run identifier (string or cell-array of strings). Name of the run
%        from which to restart a new continuation run.
% SOID : Source object instance identifier (string, optional). If the
%        argument SOID is omitted, OID is used. Pass the empty string ''
%        for OID and omit SOID for a simple continuation of trajectory
%        segments. Pass non-trivial object identifiers if an instance of
%        the COLL toolbox is part of a composite continuation problem.
% LAB  : Solution label (integer). The integer label assigned by COCO to an
%        trajectory segment during the continuation run RUN.
%
% OPTS : '-coll-end', '-end-coll', '-var' VECS, '-no-var', and '-no-pars'
%        (optional, multiple options may be given). Either '-coll-end' or
%        '-end-coll' marks the end of input to ODE_COLL2COLL. The option
%        '-var' indicates the inclusion of the variational problem, where
%        the initial solution guess for the perturbations to the trajectory
%        initial conditions is given by the content of VECS. Alternatively,
%        the option '-no-var' indicates the exclusion of the variational
%        problem even if this were included in the continuation run RUN.
%
% See also: ODE_ISOL2COLL, COLL_READ_SOLUTION, COLL_ADD, COLL_ADD_VAR

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: ode_coll2coll.m 3317 2025-01-07 21:10:49Z hdankowicz $

grammar   = 'RUN [SOID] LAB [OPTS]';
args_spec = {
   'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
  'SOID',     '',   'str', 'soid', oid, 'read', {}
   'LAB',     '',   'num',  'lab',  [], 'read', {}
  };
opts_spec = {
   '-coll-end',         '',    '',    'end', {}
   '-end-coll',         '',    '',    'end', {}
        '-var',     'vecs',    [],   'read', {}
     '-no-var',    'novar', false, 'toggle', {}
    '-no-pars',   'nopars', false, 'toggle', {}
  };
[args, opts] = coco_parse(grammar, args_spec, opts_spec, varargin{:});

[sol, data] = coll_read_solution(args.soid, args.run, args.lab);

if opts.nopars
  data.pnames = {};
end

data = ode_init_data(prob, data, oid, 'coll');

if ~isempty(opts.vecs)
  assert(isnumeric(opts.vecs) && data.xdim == size(opts.vecs,1), ...
    '%s: incompatible specification of vectors of perturbations', ...
    mfilename);
  [prob, data] = coll_add(prob, data, sol, '-no-var', '-cache-jac');
  sol.var = struct('v', opts.vecs);
  prob = coll_add_var(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'coll', 'seg', 'coll', ...
    coll_sol_info('VAR'));
elseif isfield(sol, 'var') && ~opts.novar
  [prob, data] = coll_add(prob, data, sol, '-no-var', '-cache-jac');
  prob = coll_add_var(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'coll', 'seg', 'coll', ...
    coll_sol_info('VAR'));
else
  prob = coll_add(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'coll', 'seg', 'coll', coll_sol_info());
end
end
