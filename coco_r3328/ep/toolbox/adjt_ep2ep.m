function prob = adjt_ep2ep(prob, oid, varargin)
%ADJT_EP2EP   Append adjoint of 'ep' instance from saved solution.
%
% PROB = ODE_EP2EP(PROB, OID, VARARGIN)
% VARARGIN = { RUN [SOID] LAB [OPTS] }
% OPTS = { '-ep-end' | '-end-ep' }
%
% Append adjoint of an 'ep' instance with object instance identifier OID
% that has been previously added to the continuation problem contained in
% PROB from the same saved solution using ODE_EP2EP. 
%
% PROB : Continuation problem structure.
% OID  : Target object instance identifier (string). Pass the empty string
%        '' for a simple continuation of equilibrium points.
%
% See ODE_ISOL2EP for more details on PROB and OID.
%
% RUN  : Run identifier (string or cell-array of strings). Name of the run
%        from which to restart a new continuation run.
% SOID : Source object instance identifier (string, optional). If the
%        argument SOID is omitted, OID is used. Pass the empty string ''
%        for OID and omit SOID for a simple continuation of equilibrium
%        points. Pass non-trivial object identifiers if an instance of the
%        EP toolbox is part of a composite continuation problem.
% LAB  : Solution label (integer). The integer label assigned by COCO to an
%        equilibrium point during the continuation run RUN.
%
% OPTS : '-ep-end' and '-end-ep' (optional, multiple options
%        may be given). Either '-ep-end' or '-end-ep' mark the end of input
%        to ADJT_EP2EP.
%
% See also: ADJT_ISOL2EP, EP_READ_ADJOINT, EP_ADJT_INIT_DATA,
% EP_CONSTRUCT_ADJT

% Copyright (C) Frank Schilder, Harry Dankowicz, Mingwu Li
% $Id: adjt_ep2ep.m 2901 2015-10-09 02:47:22Z hdankowicz $

grammar   = 'RUN [SOID] LAB [OPTS]';
args_spec = {
     'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
    'SOID',     '',   'str', 'soid', oid, 'read', {}
     'LAB',     '',   'num',  'lab',  [], 'read', {}
  };
opts_spec = {
  '-ep-end',       '',    '',    'end', {}
  '-end-ep',       '',    '',    'end', {}
  };
args = coco_parse(grammar, args_spec, opts_spec, varargin{:});

[sol, data] = ep_read_adjoint(args.soid, args.run, args.lab);
data = ep_adjt_init_data(prob, data, oid);
prob = ep_construct_adjt(prob, data, sol);

end
