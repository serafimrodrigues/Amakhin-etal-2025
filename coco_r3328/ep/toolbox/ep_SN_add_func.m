function prob = ep_SN_add_func(prob, sid, fid, varargin)
%EP_SN_ADD_FUNC    Add EP-compatible zero or monitor function
%
% PROB = EP_SN_ADD_FUNC(PROB, SID, FID, VARARGIN)
% VARARGIN = F [DF [DDF]] [DATA] TYPE_SPEC ['u0' U0]
%
% This function appends a zero or monitor function with function identifier
% FID to an 'ep' instance with object instance identifier SID associated
% with continuation along a family of saddle-node bifurcations. The
% function encoded in F (and, optionally, its derivatives in DF and DDF)
% must accept the following argument sequence:
%
% 'u0' absent:
%
%        Y = F  ( DATA, X, P, SN_V )
%        J = DF ( DATA, X, P, SN_V )
%        J = FDF( DATA, X, P, SN_V )
%
% 'u0' present':
%
%        Y = F  ( DATA, X, P, SN_V, V )
%        J = DF ( DATA, X, P, SN_V, V )
%        J = FDF( DATA, X, P, SN_V, V )
%
% On input:
%
% PROB      : Continuation problem structure.
% SID       : Object identifier of EP instance.
% FID       : Function identifier for function appended to continuation
%             problem.
% F         : Function handle to encoding evaluating zero or monitor
%             function appended to continuation problem.
% DF        : Optional function handle to encoding evaluating tensore of
%             all first partial derivatives of F with respect to its
%             arguments.
% DDF       : Optional function handle to encoding evaluating tensor of all
%             second partial derivatives of F with respect to its
%             arguments.
% DATA      : Optional data structure for encoding of zero or monitor
%             function appended to continuation problem.
% TYPE_SPEC : 'zero'|'inactive'|'active'|'regular'|'singular'
% U0        : Initial solution guess for internal variables of F
%
%
% On output:
%
% PROB : Continuation problem structure with an 'ep' instance added.
%
%
% See also: EP_ADD, EP_ADD_BDDAT

argidx = 1;
fhan = varargin{argidx};
argidx = argidx + 1;

if isa(varargin{argidx}, 'function_handle')
  dfhan = varargin{argidx};
  argidx = argidx + 1;
else
  dfhan = [];
end

if isa(varargin{argidx}, 'function_handle')
  ddfhan = varargin{argidx};
  argidx = argidx + 1;
else
  ddfhan = [];
end

data = struct();
if isstruct(varargin{argidx})
  data.data = varargin{argidx};
  argidx = argidx + 1;
else
  data.data = [];
end
type = lower(varargin{argidx});
argidx = argidx + 1;
pnames = {};
switch type
  case 'zero'
  otherwise
    pnames = varargin{argidx};
    argidx = argidx + 1;
end
u0 = [];
data.sn = false;
data.hb = false;
while argidx<=nargin-3
  oarg   = varargin{argidx};
  argidx = argidx + 1;
  oname  = lower(oarg);
  switch oname
    
    case 'u0'
      u0 = varargin{argidx};
      argidx = argidx + 1;
      
    otherwise
      if ischar(oarg)
        error('%s: option ''%s'' not recognised', mfilename, oarg);
      else
        error('%s: in argument %d: expected string, got a ''%s''', ...
          mfilename, 1+argidx, class(oarg));
      end
      
  end
end

data.fhan   = fhan;
data.dfhan  = dfhan;
data.ddfhan = ddfhan;

tbid = coco_get_id(sid, 'ep');
[fdata, uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
ep_eqn      = fdata.ep_eqn;
data.x_idx  = ep_eqn.x_idx;
data.p_idx  = ep_eqn.p_idx;
data.data.ep_eqn = ep_eqn;

snfid = coco_get_id(tbid, 'sn');
snuidx = coco_get_func_data(prob, snfid, 'uidx');
ep_sn = fdata.ep_sn;
data.sn_v_idx = data.p_idx(end)+ep_sn.v_idx;
data.v_idx  = data.sn_v_idx(end)+(1:numel(u0));
data.data.ep_sn = ep_sn;
if strcmpi(type, 'zero')
  if ~isempty(data.dfhan)
    prob = coco_add_func(prob, fid, @ep_sn_func1, @ep_sn_func1_ddu, ...
      data, 'zero', 'uidx', [uidx; snuidx], 'u0', u0, 'f+df');
  else
    prob = coco_add_func(prob, fid, @ep_sn_func2, data, ...
      'zero', 'uidx', [uidx; snuidx], 'u0', u0);
  end
else
  if ~isempty(data.dfhan)
    prob = coco_add_func(prob, fid, @ep_sn_func1, @ep_sn_func1_ddu, ...
      data, type, pnames, 'uidx', [uidx; snuidx], 'u0', u0, 'f+df');
  else
    prob = coco_add_func(prob, fid, @ep_sn_func2, data, ...
      type, pnames, 'uidx', [uidx; snuidx], 'u0', u0);
  end
end

end

function [data, y, J] = ep_sn_func1(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
sn_v = u(data.sn_v_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p, sn_v};
else
  args = {data.data, x, p, sn_v, v};
end
y = data.fhan(args{:});
if nargout==3
  J = data.dfhan(args{:});
end
end

function [data, J] = ep_sn_func1_ddu(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
sn_v = u(data.sn_v_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p, sn_v};
else
  args = {data.data, x, p, sn_v, v};
end
J = data.ddfhan(args{:});
end

function [data, y] = ep_sn_func2(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
sn_v = u(data.sn_v_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p, sn_v};
else
  args = {data.data, x, p, sn_v, v};
end
y = data.fhan(args{:});
end
