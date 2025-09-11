function prob = ep_add_func(prob, sid, fid, varargin)
%EP_ADD_FUNC    Add EP-compatible zero or monitor function
%
% PROB = EP_ADD_FUNC(PROB, SID, FID, VARARGIN)
% VARARGIN = F [DF [DDF]] [DATA] TYPE_SPEC ['u0' U0]
%
% This function appends a zero or monitor function with function identifier
% FID to an 'ep' instance with object instance identifier SID. The function
% encoded in F (and, optionally, its derivatives in DF and DDF) must accept
% the following argument sequence:
%
% 'u0' absent:
%
%        Y = F  ( DATA, X, P )
%        J = DF ( DATA, X, P )
%        J = FDF( DATA, X, P )
%
% 'u0' present':
%
%        Y = F  ( DATA, X, P, V )
%        J = DF ( DATA, X, P, V )
%        J = FDF( DATA, X, P, V )
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
data.v_idx   = data.p_idx(end)+(1:numel(u0));
data.data.ep_eqn = ep_eqn;
if strcmpi(type, 'zero')
  if ~isempty(data.dfhan)
    prob = coco_add_func(prob, fid, @ep_func1, @ep_func1_ddu, data, ...
      'zero', 'uidx', uidx, 'u0', u0, 'f+df');
  else
    prob = coco_add_func(prob, fid, @ep_func2, data, ...
      'zero', 'uidx', uidx, 'u0', u0);
  end
else
  if ~isempty(data.dfhan)
    prob = coco_add_func(prob, fid, @ep_func1, @ep_func1_ddu, data, ...
      type, pnames, 'uidx', uidx, 'u0', u0, 'f+df');
  else
    prob = coco_add_func(prob, fid, @ep_func2, data, ...
      type, pnames, 'uidx', uidx, 'u0', u0);
  end
end

end

function [data, y, J] = ep_func1(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p};
else
  args = {data.data, x, p, v};
end
y = data.fhan(args{:});
if nargout==3
  J = data.dfhan(args{:});
end
end

function [data, J] = ep_func1_ddu(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p};
else
  args = {data.data, x, p, v};
end
J = data.ddfhan(args{:});
end

function [data, y] = ep_func2(~, data, u)
x = u(data.x_idx);
p = u(data.p_idx);
v = u(data.v_idx);
if isempty(v)
  args = {data.data, x, p};
else
  args = {data.data, x, p, v};
end
y = data.fhan(args{:});
end
