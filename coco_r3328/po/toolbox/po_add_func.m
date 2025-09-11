function prob = po_add_func(prob, sid, fid, varargin)
%
% VARARGIN = F [DF [DDF]] [DATA] PNAMES [TYPE] ['u0' u0]

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
pnames = varargin{argidx};
if nargin>argidx+3
  type   = lower(varargin{argidx+1});
  argidx = argidx + 2;
else
  type = 'inactive';
end
u0 = [];
if nargin>argidx+3
  if strcmp(varargin{argidx}, 'u0')
    u0 = varargin{argidx+1};
  end
end

data.fhan   = fhan;
data.dfhan  = dfhan;
data.ddfhan = ddfhan;

data.cid = coco_get_id(sid, 'po.orb.coll');
[fdata, uidx] = coco_get_func_data(prob, data.cid, 'data', 'uidx');
maps         = fdata.coll_seg.maps;
data.xbp_idx = maps.xbp_idx;
data.T0_idx  = maps.T0_idx;
data.T_idx   = maps.T_idx;
data.p_idx   = maps.p_idx;
data.v_idx   = data.p_idx(end)+(1:numel(u0));
data.data.coll_seg = fdata.coll_seg;
if ~isempty(data.dfhan)
  prob = coco_add_func(prob, fid, @po_func1, @po_func1_ddu, data, ...
    type, pnames, 'uidx', uidx, 'u0', u0, 'f+df', 'remesh', @po_remesh);
else
  prob = coco_add_func(prob, fid, @po_func2, data, ...
    type, pnames, 'uidx', uidx, 'u0', u0, 'remesh', @po_remesh);
end
end

function [data, y, J] = po_func1(~, data, u)
xbp = u(data.xbp_idx);
T0  = u(data.T0_idx);
T   = u(data.T_idx);
p   = u(data.p_idx);
v   = u(data.v_idx);
if isempty(v)
  args = {data.data, xbp, T0, T, p};
else
  args = {data.data, xbp, T0, T, p, v};
end
y = data.fhan(args{:});
if nargout==3
  J = data.dfhan(args{:});
end
end

function [data, J] = po_func1_ddu(~, data, u)
xbp = u(data.xbp_idx);
T0  = u(data.T0_idx);
T   = u(data.T_idx);
p   = u(data.p_idx);
v   = u(data.v_idx);
if isempty(v)
  args = {data.data, xbp, T0, T, p};
else
  args = {data.data, xbp, T0, T, p, v};
end
J = data.ddfhan(args{:});
end

function [data, y] = po_func2(~, data, u)
xbp = u(data.xbp_idx);
T0  = u(data.T0_idx);
T   = u(data.T_idx);
p   = u(data.p_idx);
v   = u(data.v_idx);
if isempty(v)
  args = {data.data, xbp, T0, T, p};
else
  args = {data.data, xbp, T0, T, p, v};
end
y = data.fhan(args{:});
end

function [prob, status, xtr] = po_remesh(prob, data, ~, old_u, old_V) 

[fdata, uidx] = coco_get_func_data(prob, data.cid, 'data', 'uidx');
maps         = fdata.coll_seg.maps;
data.xbp_idx = maps.xbp_idx;
data.T0_idx  = maps.T0_idx;
data.T_idx   = maps.T_idx;
data.p_idx   = maps.p_idx;
data.v_idx   = data.p_idx(end)+(1:numel(data.v_idx));
data.data.coll_seg = fdata.coll_seg;

xtr    = 1:numel(data.v_idx);
prob   = coco_change_func(prob, data, 'uidx', uidx, ...
  'u0', old_u(end-numel(data.v_idx)+1:end), ...
  'vecs', old_V(end-numel(data.v_idx)+1:end,:));
status = 'success';

end
