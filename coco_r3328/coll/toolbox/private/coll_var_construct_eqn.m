function [prob, data] = coll_var_construct_eqn(prob, data, sol)
%COLL_VAR_CONSTRUCT_EQN   Add COLL variational equation.

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: coll_var_construct_eqn.m 3317 2025-01-07 21:10:49Z hdankowicz $

[data, sol] = init_data(data, sol);
var  = data.coll_var;
fid  = var.fid;
tbid = data.coll_seg.fid;
uidx = coco_get_func_data(prob, tbid, 'uidx');
prob = coco_add_func(prob, fid, @FDF, data, 'zero', ...
  'uidx', uidx, 'u0', sol.var.u0, 't0', sol.var.t0, ...
  'fdim', var.fdim, 'remesh', @remesh, 'F+DF', 'requires', tbid);

end

function [data, sol] = init_data(data, sol)
%INIT_DATA   Initialize data for variational equation.

seg  = data.coll_seg;
tbid = seg.fid;
fid  = coco_get_id(tbid, 'var');

assert(isfield(data, 'coll_Jx'), ...
  '%s: %s: cannot add variational equation, ''%s'' not constructed with option ''-cache-jac''', ...
  mfilename, fid, tbid);

int  = seg.int;
maps = seg.maps;
mesh = seg.mesh;

var.nvec = size(sol.var.v,2);
var.fid  = fid;
var = var_mesh(var, mesh, maps, int);

if ~isfield(sol.var, 'u0')
  C   = [data.coll_Jx; maps.Q];
  rhs = C(:,1:int.dim)*sol.var.v;
  sol.var.w = -C(:,int.dim+1:end)\rhs;
  sol.var.u0 = reshape([sol.var.v; sol.var.w],[],1);
  sol.var.t0 = [];
end

data.coll_var  = var;
data.no_save = union(data.no_save, ...
  {'coll_var.Q' 'coll_var.Qv' 'coll_var.zeros' 'coll_var.J' ....
  'coll_var.rows' 'coll_var.cols' 'coll_var.xbp_shp' 'coll_var.tbp' ...
  'coll_var.tbp_idx' 'coll_var.xtr' 'coll_var.xtrbeg', 'coll_var.xtrend' });

end

function var = var_mesh(var, mesh, maps, int)

dim         = int.dim;
var.tbp     = mesh.tbp;
var.tbp_idx = maps.tbp_idx;
var.xbp_shp = maps.xbp_shp;
var.xbp_idx = maps.xbp_idx;
var.T0_idx  = maps.T0_idx;
var.T_idx   = maps.T_idx;
var.p_idx   = maps.p_idx;

xbpdim = numel(var.xbp_idx);
xcndim = dim*maps.x_shp(2);
nvec   = var.nvec;
idx = reshape(1:xbpdim*nvec, [xbpdim nvec]);

var.v_idx  = var.p_idx(end)+idx;
var.v0_idx = var.v_idx(maps.x0_idx,:);
var.v1_idx = var.v_idx(maps.x1_idx,:);
var.fdim   = maps.fdim * nvec;

var.rows = repmat(reshape(1:xcndim*nvec, [xcndim nvec]), [xbpdim 1]);
var.cols = repmat(1:xbpdim*nvec, [xcndim 1]);

var.J    = zeros(xcndim*nvec, var.p_idx(end));

Q = maps.Q;
var.Q = Q;
m = maps.Qnum;
Q = repmat(Q, [1 nvec]);
r = reshape(1:nvec*m, [m nvec]);
r = repmat(r, [xbpdim 1]);
c = repmat(1:nvec*xbpdim, [m 1]);
var.Qv = sparse(r, c, Q);
var.zeros = zeros(maps.Qnum*nvec,var.p_idx(end));

var.xtr   = var.v_idx-var.v_idx(1)+1;
var.xtr(dim+1:end-dim,:) = 0;
var.xtrbeg = maps.x0_idx; 
var.xtrend = maps.x1_idx;

end

function [data, y, J] = FDF(prob, data, u) %#ok<INUSL>
%FDF   Variational equation and linearization.

pr = data.pr;
var = pr.coll_var;

x  = u(var.xbp_idx);
T0 = u(var.T0_idx);
T  = u(var.T_idx);
p  = u(var.p_idx);
v  = u(var.v_idx);

Jx = data.coll_Jx;
vode = Jx*v;
vcnt = var.Q*v;
y = [vode(:); vcnt(:)];

if nargout>=3
  J = var.J;
  xcndim = size(Jx,1);
  for i=1:var.nvec
    [Vx, VT, Vp] = derivs(pr, [x; T0; T; p], v(:,i));
    J((i-1)*xcndim+(1:xcndim),:) = [Vx VT Vp];
  end
  Jx = sparse(var.rows, var.cols, repmat(Jx, [1 var.nvec]));
  J = [J Jx; var.zeros var.Qv];
end


end

function [Jx, JT, Jp] = derivs(data, u, w)

seg  = data.coll_seg;
maps = seg.maps;
mesh = seg.mesh;

x  = u(maps.xbp_idx);
T0 = u(maps.T0_idx);
T  = u(maps.T_idx);
p  = u(maps.p_idx);

xcn = reshape(maps.W*x, maps.x_shp);
wcn = reshape(maps.W*w, maps.x_shp);
pcn = repmat(p, maps.p_rep);

fdxcn = data.ode_DFDXDX_dx(data, T0+T*mesh.tcn', xcn, pcn, wcn);
dxode = mesh.fdxka.*fdxcn;
dxode = sparse(maps.fdxrows, maps.fdxcols, dxode(:));
Jx = (0.5*T/maps.NTST)*dxode*maps.W;

fcn    = data.ode_DFDX_dx(data, T0+T*mesh.tcn', xcn, pcn, wcn);
fdtcn  = data.ode_DFDTDX_dx(data, T0+T*mesh.tcn', xcn, pcn, wcn);
dT0ode = mesh.fka.*(T*fdtcn);
dTode  = mesh.fka.*(fcn+T*fdtcn.*repmat(mesh.tcn',[data.xdim 1]));
JT = (0.5/maps.NTST)*[dT0ode(:) dTode(:)];

fdpcn = data.ode_DFDPDX_dx(data, T0+T*mesh.tcn', xcn, pcn, wcn);
dpode = mesh.fdpka.*fdpcn;
dpode = sparse(maps.fdprows, maps.fdpcols, dpode(:));
Jp = (0.5*T/maps.NTST)*dpode;

end

function [prob, stat, xtr] = remesh(prob, data, ~, ub, Vb)
% Remesh variational problem

pr = data.pr;
var  = pr.coll_var;
seg  = pr.coll_seg;
int  = seg.int;
maps = seg.maps;
mesh = seg.mesh;

tbp = var.tbp(var.tbp_idx);

u = ub(var.v_idx);   % Extract current basepoint values
ua = zeros(numel(mesh.tbp)*int.dim, var.nvec);
for i=1:var.nvec
  vbp = reshape(u(:,i), var.xbp_shp);
  vbp = vbp(:, var.tbp_idx);
  v0  = interp1(tbp', vbp', mesh.tbp, 'pchip')'; % Update basepoint values
  ua(:,i) = v0(:);
end
ua = ua(:);

Vdim = size(Vb,2);
Va = zeros(numel(mesh.tbp)*int.dim, var.nvec*Vdim);
for i=1:Vdim
  V = Vb(:,i);
  V = V(var.v_idx); % Extract current tangent vector and tangent space
  for j=1:var.nvec
    vbp = reshape(V(:,j), var.xbp_shp);
    vbp = vbp(:, var.tbp_idx);
    v0  = interp1(tbp', vbp', mesh.tbp, 'pchip')'; % Update tangent vectors and tangent space
    Va(:,(i-1)*var.nvec+j) = v0(:);
  end
end
Va = reshape(Va, [numel(mesh.tbp)*int.dim*var.nvec Vdim]);

xtr    = var.xtr; % Current invariant elements
xtrend = var.xtrend;
xtrbeg = var.xtrbeg;
var    = var_mesh(var, mesh, maps, int);
xtr(xtrend,:) = var.xtr(var.xtrend,:);
xtr(xtrbeg,:) = var.xtr(var.xtrbeg,:);

pr.coll_var  = var;
data.pr = pr;

uidx = coco_get_func_data(prob, seg.fid, 'uidx');
prob = coco_change_func(prob, data, 'uidx', uidx, 'u0', ua, ...
  'fdim', var.fdim, 'vecs', Va); % Update data and solution
stat = 'success';

end
