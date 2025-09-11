function prob = ode_isol2coll(prob, oid, varargin)
%ODE_ISOL2COLL   Construct trajectory segment continuation problem from initial guess.
%
% PROB = ODE_ISOL2COLL(PROB, OID, VARARGIN)
%
% VARARGIN = { F [DFDX [DFDP [[DFDXDX [DFDXDP [DFDPDP]]]]]] T0 X0 [PNAMES] P0 [OPTS] }
%
% in the case of an autonomous representation, or
%
% VARARGIN = { F [DFDX [DFDP [DFDT [DFDXDX [DFDXDP [DFDPDP [DFDTDX [DFDTDP [DFDTDT]]]]]]]]] T0 X0 [PNAMES] P0 [OPTS] }
%
% in the case of a non-autonomous representation.
%
% OPTS = { '-coll-end' | '-end-coll' | '-var' VECS }
%
% Construct continuation problem for trajectory segments of evolution
% equations of the form x'=f(t,x,p) (non-autonomous) or x'=f(x,p)
% (autonomous), where f is some non-linear function. At least a function
% handle F to a function evaluating f (or to a struct that contains the
% field 'f' with a function handle to a function evaluating f), an initial
% guess T0 and X0 for the time discretization and corresponding sampled
% time history of the state vector x, and initial values P0 for the problem
% parameters p must be provided.
%
% As an example, for a harmonically excited linear oscillator, the function
% f can be encoded in-line as in
%
%   func = @(x,p) [x(2,:); -x(2,:)-p(1,:).*x(1,:)+cos(x(3,:)); ones(1,size(x,2))];
%
% in the case of an autonomous representation, or
%
%   func = @(t,x,p) [x(2,:); -x(2,:)-p(1,:).*x(1,:)+cos(t)];
%
% in the case of a non-autonomous representation. Alternatively, the
% function f can be encoded in a separate m-file as in
%
%   function y = func(x,p)
%     y = [x(2,:); -x(2,:)-p(1,:).*x(1,:)+cos(x(3,:)); ones(1,size(x,2))];
%   end
%
% in the case of an autonomous representation, or
%
%   function y = func(t,x,p)
%     y = [x(2,:); -x(2,:)-p(1,:).*x(1,:)+cos(t)];
%   end
%
% in the case of a non-autonomous representation.
%
% Note that function evaluation is vectorized by default. For
% non-vectorized encodings use coco_set(prob, 'ode', 'vectorized', false).
% For large problems it is recommended to encode explicit derivatives.
%
% Note that the vector field f is autonomous by default. For non-autonomous
% vector fields, use coco_set(prob, 'ode', 'autonomous', false).
%
% As a simple example, the sequence of commands
%
% coll_fun = @(x,p) [x(2,:); -x(2,:)-p(1,:).*x(1,:)+cos(x(3,:)); ones(1,size(x,2)];
% [t0 x0] = ode45(@(t,x) func(x,1), [0 2*pi], [0; 1; 0]);
% prob = coco_prob();
% prob = ode_isol2coll(prob, '', coll_fun, t0, x0, 'p', 1);
%
% constructs a continuation problem with dimensional deficit equal to four,
% whose solutions are trajectory segments parameterized, for example, by
% the initial condition and the interval length. Please see the demos
% shipped with COLL for more examples of use.
%
% On input:
%
% PROB   : Continuation problem structure. This structure is either
%          automatically created and passed on by COCO when using the COLL
%          toolbox implicitly, or created with COCO_PROB prior to calling
%          COLL_ISOL2COLL explicitly. See below for implicit and explicit
%          use of the COLL toolbox.
%
%          The problem structure may contain settings defined with a prior
%          call to COCO_SET, which will influence the behavior of the COLL
%          toolbox. Execute COLL_SETTINGS on the Matlab command line to see
%          an overview of COLL toolbox settings.
%
% OID    : Object instance identifier (string). The corresponding toolbox
%          instance identifier is coco_get_id(OID, 'coll'). Pass the empty
%          string '' for a simple continuation of trajectory segments. Pass
%          a non-trivial object identifier if an instance of the COLL
%          toolbox is part of a composite continuation problem.
%
% F      : Function handle to vector field or struct with field 'f'
%          containing a function handle to the vector field. In the latter
%          case, the remaining optional function handles may be omitted and
%          instead, optionally, associated with additional fields of the
%          struct.
% DFDX   : Function handle to Jacobian of vector field w.r.t. state
%          variables (optional, may be empty).
% DFDP   : Function handle to Jacobian of vector field w.r.t. problem
%          parameters (optional, may be empty).
% DFDT   : Function handle to Jacobian of vector field w.r.t. time
%          (optional, may be empty).
% DFDXDX : Function handle to d2f/dx^2 (optional, may be empty).
% DFDXDP : Function handle to d2f/dxdp (optional, may be empty).
% DFDPDP : Function handle to d2f/dp^2 (optional, may be empty).
% DFDTDX : Function handle to d2f/dtdx (optional, may be empty).
% DFDTDP : Function handle to d2f/dtdp (optional, may be empty).
% DFDTDT : Function handle to d2f/dt^2 (optional, may be empty).
%
% T0     : Initial time discretization.
% X0     : Initial sampled time history for state variables.
% PNAMES : Cell array of string labels for continuation parameters
%          (optional). These string labels will be mapped onto the problem
%          parameters as lab{1}->p(1), lab{2}->p(2), ... If string labels
%          are given, their number must match the number of problem
%          parameters. If only one problem parameter is present, a string
%          may be given instead of a cell array of strings. Omitting this
%          argument is only relevant for embedded problems. In general,
%          this argument must be given.
% P0     : Initial solution guess for problem parameters. Pass an empty
%          array to indicate absence of problem parameters.
%
% OPTS   : '-coll-end', '-end-coll', and '-var' VECS (optional, multiple
%          options may be given). Either '-coll-end' or '-end-coll' marks
%          the end of input to ODE_ISOL2COLL. The option '-var' indicates
%          the inclusion of the variational problem, where the initial
%          solution guess for the perturbations to the trajectory initial
%          conditions is given by the content of VECS.
%
% Implicit use of COLL toolbox
% --------------------------
% A call to COCO of the form
%
%   coco(prob, RUN, 'ode', 'isol', 'coll', COLL_ARGS, CONT_ARGS);
%
% will call the function ODE_ISOL2COLL implicitly, where the arguments
% COLL_ARGS following the string 'coll' will be passed to ODE_ISOL2COLL.
% Any remaining arguments CONT_ARGS will be passed to the appropriate atlas
% algorithm.
%
% A call to COCO of the form
%
%   coco(prob, RUN, 'ode', 'isol', 'coll', COLL_ARGS, CONT_ARGS);
%
% differs from the above in that the existing continuation problem
% structure prob is used in the call to ODE_ISOL2COLL. Non-default values
% for COLL toolbox settings must be assigned to prob before this call.
%
% Explicit use of COLL toolbox
% --------------------------
% A calling sequence like
%
%   prob = coco_prob();
%   ...
%   prob = coco_set(prob, 'coll', COLL_PROP, COLL_PROP_VAL)
%   ...
%   prob = ode_isol2coll(prob, '', COLL_ARGS);
%   ...
%   coco(prob, RUN, [], CONT_ARGS);
%
% uses the function ODE_ISOL2COLL explicitly to add a 'coll' instance to
% the problem structure. This calling sequence is equivalent to the
% implicit use of the COLL toolbox. However, it allows for inclusion of
% user-defined monitor functions between the calls to ODE_ISOL2COLL and
% COCO, as demonstrated in the demos.
%
% See also: COCO_SET, COLL_SETTINGS, COLL_READ_SOLUTION, COLL_ADD,
% COLL_ADD_VAR

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: ode_isol2coll.m 3317 2025-01-07 21:10:49Z hdankowicz $

grammar   = 'F [DFDX [DFDP [DFDT [DFDXDX [DFDXDP [DFDPDP [DFDTDX [DFDTDP [DFDTDT]]]]]]]]] T0 X0 [PNAMES] P0 [OPTS]';
args_spec = {
       'F',     '', '@|stct',      'fhan', [], 'read', {}
    'DFDX',     '',   '@|[]',   'dfdxhan', [], 'read', {}
    'DFDP',     '',   '@|[]',   'dfdphan', [], 'read', {}
    'DFDT',     '',   '@|[]',   'dfdthan', [], 'read', {}
  'DFDXDX',     '',   '@|[]', 'dfdxdxhan', [], 'read', {}
  'DFDXDP',     '',   '@|[]', 'dfdxdphan', [], 'read', {}
  'DFDPDP',     '',   '@|[]', 'dfdpdphan', [], 'read', {}
  'DFDTDX',     '',   '@|[]', 'dfdtdxhan', [], 'read', {}
  'DFDTDP',     '',   '@|[]', 'dfdtdphan', [], 'read', {}
  'DFDTDT',     '',   '@|[]', 'dfdtdthan', [], 'read', {}
      'T0',     '',  '[num]',        't0', [], 'read', {}
      'X0',     '',  '[num]',        'x0', [], 'read', {}
  'PNAMES', 'cell',  '{str}',    'pnames', {}, 'read', {}
      'P0',     '',  '[num]',        'p0', [], 'read', {}
  };
opts_spec = {
  '-coll-end',     '', '',  'end', {}
  '-end-coll',     '', '',  'end', {}
       '-var', 'vecs', [], 'read', {}
  };
[args, opts] = coco_parse(grammar, args_spec, opts_spec, varargin{:});

[sol, data] = coll_read_solution('', '', args);
data = ode_init_data(prob, data, oid, 'coll');
 % For an autonomous vector field, all derivatives with respect to time are
 % assumed to equal 0. In this case, the corresponding arguments are
 % omitted from the calling syntax.
if data.ode.autonomous && ~isstruct(args.fhan)
  [data.dfdxdxhan, data.dfdxdphan, data.dfdpdphan] = ...
    deal(data.dfdthan, data.dfdxdxhan, data.dfdxdphan);
  data.dfdthan = [];
end

if ~isempty(opts.vecs)
  assert(isnumeric(opts.vecs) && data.xdim == size(opts.vecs,1), ...
    '%s: incompatible specification of vectors of perturbations', ...
    mfilename);
  [prob, data] = coll_add(prob, data, sol, '-no-var', '-cache-jac');
  sol.var = struct('v', opts.vecs);
  prob = coll_add_var(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'coll', 'seg', 'coll', ...
    coll_sol_info('VAR'));
else
  prob = coll_add(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'coll', 'seg', 'coll', coll_sol_info());
end
end
