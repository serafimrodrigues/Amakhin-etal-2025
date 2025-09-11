function data = ode_init_data(prob, src_data, oid, varargin)
%ODE_INIT_DATA   Initialize ODE toolbox family data structure.
%
% DATA = ODE_INIT_DATA(PROB, SRC_DATA, OID, VARARGIN)
% VARARGIN = { [NAME]... }
%
% This function is part of the toolbox developers interface and should
% typically not be used directly.
%
% Construct ODE toolbox family data structure and initialize data structure
% with definition of an ODE with right-hand side f. The constructed data
% structure is suitable for use as function data for toolboxes implementing
% computations related to ODEs. For autonomous ODEs the right-hand side f
% must be defined in a function f that expects two arguments x (state
% variables) and p (problem parameters) and returns x':=dx/dt as in
%
%   x' = f(x,p) .
%
% For non-autonomous ODEs the right-hand side f must be defined in a
% function f that expects three arguments t (time), x (state variables) and
% p (problem parameters) and returns x' as in
%
%   x' = f(t,x,p) .
%
% In addition, for non-autonomous ODEs the ODE toolbox setting autonomous
% must be set to off/false.
%
% Input arguments:
%
% PROB     : Continuation problem structure.
% SRC_DATA : Source data structure.
% OID      : Object identifier of ODE toolbox instance.
% VARARGIN : List of toolbox field names to copy or initialize.
%
% On return, DATA contains at least the following fields:
%
% oid        : Object identifier, set to OID.
% fhan       : Function handle to RHS f of evolution equation.
% dfdxhan    : (Possibly empty) function handle to Jacobian df/dx.
% dfdphan    : (Possibly empty) function handle to Jacobian df/dp.
% dfdthan    : (Possibly empty) function handle to Jacobian df/dt.
% dfdxdxhan  : (Possibly empty) function handle to Jacobian d2f/dx2.
% dfdxdphan  : (Possibly empty) function handle to Jacobian d2f/dxdp.
% dfdpdphan  : (Possibly empty) function handle to Jacobian d2f/dp2.
% dfdtdxhan  : (Possibly empty) function handle to Jacobian d2f/dtdx.
% dfdtdphan  : (Possibly empty) function handle to Jacobian d2f/dtdp.
% dfdtdthan  : (Possibly empty) function handle to Jacobian d2f/dt2.
% xdim       : Number of state variables.
% pdim       : Number of problem parameters.
% pnames     : List of parameter names.
% ode        : Settings of ODE toolbox instance.
% ode_F      : Wrapper to vectorized evaluation of f.
% ode_DFDX   : Wrapper to vectorized evaluation of df/dx.
% ode_DFDP   : Wrapper to vectorized evaluation of df/dp.
% ode_DFDT   : Wrapper to vectorized evaluation of df/dt.
% ode_DFDXDX : Wrapper to vectorized evaluation of d2f/dx2.
% ode_DFDXDP : Wrapper to vectorized evaluation of d2f/dxdt.
% ode_DFDPDP : Wrapper to vectorized evaluation of d2f/dp2.
% ode_DFDTDX : Wrapper to vectorized evaluation of d2f/dtdx.
% ode_DFDTDP : Wrapper to vectorized evaluation of d2f/dtdp.
% ode_DFDTDT : Wrapper to vectorized evaluation of d2f/dt2.
% no_save    : List of field names to be excluded by coco_save_data.
%
% and any fields with names listed in VARARGIN.
%
% The fields fhan, dfdxhan, dfdphan, dfdthan, dfdxdxhan, dfdxdphan,
% dfdpdphan, dfdtdxhan, dfdtdphan, dfdtdthan, xdim, pdim, and pnames are
% copied from the source data structure SRC_DATA and must be present. Any
% fields with names passed in VARARGIN are either copied from SRC_DATA, if
% a field with this name is present in SRC_DATA, or initialized to the
% empty structure. The fields ode_F, ode_DFDX, ode_DFDP, ode_DFDT,
% ode_DFDXDX, ode_DFDXP, ode_DFDPDP, ode_DFDTDX, ode_DFDTDP, ode_DFDTDT,
% ode_DFDX_dx, ode_DFDXDX_dx, ode_DFDPDX_dx, and ode_DFDTDX_dx are
% initialized to function handles that provide wrappers for vectorized
% evaluation of the right-hand side of a given ODE and its derivatives,
% taking the value of the ODE setting 'vectorized' and the presence/absence
% of the fields dfdxhan, dfdphan, dfdthan, dfdxdxhan, dfdxdphan, dfdpdphan,
% dfdtdxhan, dfdtdphan, and dfdtdthan into account. The field no_save is
% initialized to the empty set and collects names of fields to be omitted
% by the slot function COCO_SAVE_DATA. The constructed data structure DATA
% is a protected instance of COCO_FUNC_DATA.
%
% See also ODE_SETTINGS, COCO_SAVE_DATA, COCO_FUNC_DATA.

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: ode_init_data.m 3317 2025-01-07 21:10:49Z hdankowicz $

data = coco_func_data('protect');
data.oid = oid;

fields = [ 'ode' varargin ];
for i=1:numel(fields)
  field = fields{i};
  if isfield(src_data, field)
    data.(field) = src_data.(field);
  else
    data.(field) = struct();
  end
end

tbid = coco_get_id(oid, 'ode');
data.ode = ode_get_settings(prob, tbid, data.ode);

data.fhan = src_data.fhan;
fnames = fieldnames(src_data);
for i=1:length(fnames)
  if strncmp(fnames(i), 'dfd', 3)
    data.(fnames{i}) = src_data.(fnames{i});
  end
end
if isstruct(data.fhan)
  assert(isfield(data.fhan, 'f') && isa(data.fhan.f, 'function_handle'), ...
    '%s: missing specification of vector field', mfilename);
  G = data.fhan;
  names = fieldnames(G);
  for i=1:length(names)
    data.(sprintf('%shan', names{i})) = G.(names{i});
  end
end
data.pnames    = src_data.pnames;
data.xdim      = src_data.xdim;
data.pdim      = src_data.pdim;
data.no_save   = {};

if data.ode.autonomous
  data.ode_F         = @aut_F;
  data.ode_DFDX      = @aut_DFDX;
  data.ode_DFDP      = @aut_DFDP;
  data.ode_DFDT      = @aut_DFDT;
  data.ode_DFDXDX    = @aut_DFDXDX;
  data.ode_DFDXDP    = @aut_DFDXDP;
  data.ode_DFDPDP    = @aut_DFDPDP;
  data.ode_DFDTDX    = @aut_DFDTDX;
  data.ode_DFDTDP    = @aut_DFDTDP;
  data.ode_DFDTDT    = @aut_DFDTDT;
  data.ode_DFDX_dx   = @aut_DFDX_dx;
  data.ode_DFDXDX_dx = @aut_DFDXDX_dx;
  data.ode_DFDPDX_dx = @aut_DFDPDX_dx;
  data.ode_DFDTDX_dx = @aut_DFDTDX_dx;
else
  data.ode_F         = @het_F;
  data.ode_DFDX      = @het_DFDX;
  data.ode_DFDP      = @het_DFDP;
  data.ode_DFDT      = @het_DFDT;
  data.ode_DFDXDX    = @het_DFDXDX;
  data.ode_DFDXDP    = @het_DFDXDP;
  data.ode_DFDPDP    = @het_DFDPDP;
  data.ode_DFDTDX    = @het_DFDTDX;
  data.ode_DFDTDP    = @het_DFDTDP;
  data.ode_DFDTDT    = @het_DFDTDT;
  data.ode_DFDX_dx   = @het_DFDX_dx;
  data.ode_DFDXDX_dx = @het_DFDXDX_dx;
  data.ode_DFDPDX_dx = @het_DFDPDX_dx;
  data.ode_DFDTDX_dx = @het_DFDTDX_dx;
end

end

function F = aut_F(data, ~, x, p)
%F   Vectorized evaluation of autonomous F.
if data.ode.vectorized
  F = data.fhan(x, p);
else
  [m,n] = size(x);
  F = zeros(m,n);
  for i=1:n, F(:,i) = data.fhan(x(:,i), p(:,i)); end
end
end

function dFdx = aut_DFDX(data, ~, x, p)
%DFDX   Vectorized evaluation of autonomous dF/dx.
if data.ode.vectorized
  if isempty(data.dfdxhan)
    opts = struct('hfac', data.ode.hfac1);
    dFdx = ode_num_DFDX_v(data.fhan, x, p, opts);
  else
    dFdx = data.dfdxhan(x, p);
  end
else
  if isempty(data.dfdxhan)
    opts = struct('hfac', data.ode.hfac1);
    dFdx = ode_num_DFDX(data.fhan, x, p, opts);
  else
    [m,n] = size(x);
    dFdx  = zeros(m,m,n);
    for i=1:n, dFdx(:,:,i) = data.dfdxhan(x(:,i), p(:,i)); end
  end
end
end

function dFdp = aut_DFDP(data, ~, x, p)
%DFDP   Vectorized evaluation of autonomous dF/dp.
if data.ode.vectorized
  if isempty(data.dfdphan)
    f    = @(x,y) data.fhan(y,x);
    opts = struct('hfac', data.ode.hfac1);
    dFdp = ode_num_DFDX_v(f, p, x, opts);
  else
    dFdp = data.dfdphan(x, p);
  end
else
  if isempty(data.dfdphan)
    opts = struct('hfac', data.ode.hfac1);
    dFdp = ode_num_DFDX(@(x,y) data.fhan(y,x), p, x, opts);
  else
    [m,n] = size(x);
    o     = size(p,1);
    dFdp  = zeros(m,o,n);
    for i=1:n, dFdp(:,:,i) = data.dfdphan(x(:,i), p(:,i)); end
  end
end
end

function Jt = aut_DFDT(~, ~, x, ~)
%DFDT   Vectorized evaluation of non-autonomous dF/dt.
Jt = zeros(size(x));
end

function dFdxdx = aut_DFDXDX(data, ~, x, p)
%DFDXDX   Vectorized evaluation of autonomous d2F/dx2.
if data.ode.vectorized
  if isempty(data.dfdxdxhan)
    if isempty(data.dfdxhan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(x,p) ode_num_DFDX_v(data.fhan, x, p, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdx = ode_num_DFDX_v(dfdx, x, p, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdx = ode_num_DFDX_v(data.dfdxhan, x, p, opts);
    end
  else
    dFdxdx = data.dfdxdxhan(x, p);
  end
else
  if isempty(data.dfdxdxhan)
    if isempty(data.dfdxhan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(x,p) ode_num_DFDX(data.fhan, x, p, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdx = ode_num_DFDX(dfdx, x, p, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdx = ode_num_DFDX(data.dfdxhan, x, p, opts);
    end
  else
    [m,n]  = size(x);
    dFdxdx = zeros(m,m,m,n);
    for i=1:n, dFdxdx(:,:,:,i) = data.dfdxdxhan(x(:,i), p(:,i)); end
  end
end
end

function dFdxdp = aut_DFDXDP(data, ~, x, p)
%DFDXDP   Vectorized evaluation of autonomous d2F/dxdp.
if data.ode.vectorized
  if isempty(data.dfdxdphan)
    if isempty(data.dfdxhan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(x,y) ode_num_DFDX_v(data.fhan, x, y, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdp = ode_num_DFDX_v(@(x,y) dfdx(y,x), p, x, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdp = ode_num_DFDX_v(@(x,y) data.dfdxhan(y,x), p, x, opts);
    end
  else
    dFdxdp = data.dfdxdphan(x, p);
  end
else
  if isempty(data.dfdxdphan)
    if isempty(data.dfdxhan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(x,y) ode_num_DFDX(data.fhan, x, y, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdp = ode_num_DFDX(@(x,y) dfdx(y,x), p, x, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdp = ode_num_DFDX(@(x,y) data.dfdxhan(y,x), p, x, opts);
    end
  else
    [m,n]  = size(x);
    o      = size(p,1);
    dFdxdp = zeros(m,m,o,n);
    for i=1:n, dFdxdp(:,:,:,i) = data.dfdxdphan(x(:,i), p(:,i)); end
  end
end
end

function dFdpdp = aut_DFDPDP(data, ~, x, p)
%DFDPDP   Vectorized evaluation of autonomous d2F/dp2.
if data.ode.vectorized
  if isempty(data.dfdpdphan)
    if isempty(data.dfdphan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdp   = @(x,y) ode_num_DFDX_v(@(x,y) data.fhan(y,x), y, x, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdpdp = ode_num_DFDX_v(@(x,y) dfdp(y,x), p, x, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdpdp = ode_num_DFDX_v(@(x,y) data.dfdphan(y,x), p, x, opts);
    end
  else
    dFdpdp = data.dfdpdphan(x, p);
  end
else
  if isempty(data.dfdpdphan)
    if isempty(data.dfdphan)
      opts   = struct('hfac', data.ode.hfac1);
      dfdp   = @(x,y) ode_num_DFDX(@(x,y) data.fhan(y,x), y, x, opts);
      opts   = struct('hfac', data.ode.hfac2);
      dFdpdp = ode_num_DFDX(@(x,y) dfdp(y,x), p, x, opts);
    else
      opts   = struct('hfac', data.ode.hfac1);
      dFdpdp = ode_num_DFDX(@(x,y) data.dfdphan(y,x), p, x, opts);
    end
  else
    [m,n]  = size(x);
    o      = size(p,1);
    dFdpdp = zeros(m,o,o,n);
    for i=1:n, dFdpdp(:,:,:,i) = data.dfdpdphan(x(:,i), p(:,i)); end
  end
end
end

function Jtx = aut_DFDTDX(~, ~, x, ~)
%DFDTDX   Vectorized evaluation of autonomous d2F/dtdx.
Jtx = zeros([size(x,1), size(x)]);
end

function Jtp = aut_DFDTDP(~, ~, x, p)
%DFDTDP   Vectorized evaluation of autonomous d2F/dtdp.
Jtp = zeros([size(x,1), size(p)]);
end

function Jtt = aut_DFDTDT(~, ~, x, ~)
%DFDTDT   Vectorized evaluation of autonomous d2F/dtdt.
Jtt = zeros(size(x));
end

function dFdx_dx = aut_DFDX_dx(data, ~, x, p, w)
%DFDX_dx   Vectorized evaluation of autonomous dF(x+hw,p)/dh.
if data.ode.vectorized
  if isfield(data,'dfdx_dxhan') && isa(data.dfdx_dxhan,'function_handle')
    dFdx_dx = data.dfdx_dxhan(x, p, w);
  else
    if isempty(data.dfdxhan)
      opts    = struct('hfac', data.ode.hfac1);
      dFdx_dx = ode_num_DFDX_dx_v(data.fhan, x, p, w, opts);
    else
      [m,n]   = size(x);
      rows    = repmat(reshape(1:m*n, [m n]),[m 1]);
      cols    = repmat(1:m*n, [m 1]);
      dfdx    = data.dfdxhan(x, p);
      dfdx    = sparse(rows, cols, dfdx(:));
      dFdx_dx = reshape(dfdx*w(:), [m n]);
    end
  end
else
  if isfield(data,'dfdx_dxhan') && isa(data.dfdx_dxhan,'function_handle')
    [m,n]   = size(x);
    dFdx_dx = zeros(m,n);
    for i=1:n
      dFdx_dx(:,i) = data.dfdx_dxhan(x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxhan)
      opts    = struct('hfac', data.ode.hfac1);
      dFdx_dx = ode_num_DFDX_dx(data.fhan, x, p, w, opts);
    else
      [m,n]   = size(x);
      dFdx_dx = zeros(m,n);
      for i=1:n
        dFdx_dx(:,i) = data.dfdxhan(x(:,i), p(:,i))*w(:,i);
      end
    end
  end
end
end

function dFdxdx_dx = aut_DFDXDX_dx(data, ~, x, p, w)
%DFDXDX_dx   Vectorized evaluation of autonomous d(dF/dx(x+hw,p))/dh.
if data.ode.vectorized
  if isfield(data, 'dfdxdx_dxhan') && ...
      isa(data.dfdxdx_dxhan,'function_handle')
    dFdxdx_dx = data.dfdxdx_dxhan(x, p, w);
  else
    if isempty(data.dfdxdxhan)
      if isempty(data.dfdxhan)
        opts      = struct('hfac', data.ode.hfac1);
        dfdx      = @(x,p) ode_num_DFDX_v(data.fhan, x, p, opts);
        opts      = struct('hfac', data.ode.hfac2);
        dFdxdx_dx = ode_num_DFDX_dx_v(dfdx, x, p, w, opts);
      else
        opts      = struct('hfac', data.ode.hfac1);
        dFdxdx_dx = ode_num_DFDX_dx_v(data.dfdxhan, x, p, w, opts);
      end
    else
      [m,n]     = size(x);
      rows      = repmat(reshape(1:m^2*n, [m^2 n]),[m 1]);
      cols      = repmat(1:m*n, [m^2 1]);
      dfdxdx    = data.dfdxdxhan(x, p);
      dfdxdx    = sparse(rows, cols, dfdxdx(:));
      dFdxdx_dx = reshape(dfdxdx*w(:), [m, m, n]);
    end
  end
else
  if isfield(data, 'dfdxdx_dxhan') && ...
      isa(data.dfdxdx_dxhan,'function_handle')
    [m,n]     = size(x);
    dFdxdx_dx = zeros(m,m,n);
    for i=1:n
      dFdxdx_dx(:,:,i) = data.dfdxdx_dxhan(x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxdxhan)
      if isempty(data.dfdxhan)
        opts      = struct('hfac', data.ode.hfac1);
        dfdx      = @(x,p) ode_num_DFDX(data.fhan, x, p, opts);
        opts      = struct('hfac', data.ode.hfac2);
        dFdxdx_dx = ode_num_DFDX_dx(dfdx, x, p, w, opts);
      else
        opts      = struct('hfac', data.ode.hfac1);
        dFdxdx_dx = ode_num_DFDX_dx(data.dfdxhan, x, p, w, opts);
      end
    else
      [m,n]     = size(x);
      dFdxdx_dx = zeros(m,m,n);
      for i=1:n
        dFdxdx_dx(:,:,i) = reshape(reshape(...
          data.dfdxdxhan(x(:,i), p(:,i)), [m^2, m])*w(:,i), [m, m]);
      end
    end
  end
end
end

function dFdpdx_dx = aut_DFDPDX_dx(data, ~, x, p, w)
%DFDPDX_dx   Vectorized evaluation of autonomous d(dF/dp(x+hw,p))/dh.
if data.ode.vectorized
  if isfield(data, 'dfdpdx_dxhan') && ...
      isa(data.dfdpdx_dxhan,'function_handle')
    dFdpdx_dx = data.dfdpdx_dxhan(x, p, w);
  else
    if isempty(data.dfdxdphan)
      if isempty(data.dfdphan)
        f         = @(x,y) data.fhan(y,x);
        opts      = struct('hfac', data.ode.hfac1);
        dfdp      = @(x,p) ode_num_DFDX_v(f, p, x, opts);
        opts      = struct('hfac', data.ode.hfac2);
        dFdpdx_dx = ode_num_DFDX_dx_v(dfdp, x, p, w, opts);
      else
        opts      = struct('hfac', data.ode.hfac1);
        dFdpdx_dx = ode_num_DFDX_dx_v(data.dfdphan, x, p, w, opts);
      end
    else
      [m,n]     = size(x);
      o         = size(p,1);
      rows      = repmat(reshape(1:m*o*n, [m*o n]),[m 1]);
      cols      = repmat(1:m*n, [m*o 1]);
      dfdpdx    = permute(data.dfdxdphan(x, p), [1 3 2 4]);
      dfdpdx    = sparse(rows, cols, dfdpdx(:));
      dFdpdx_dx = reshape(dfdpdx*w(:), [m, o, n]);
    end
  end
else
  if isfield(data, 'dfdpdx_dxhan') && ...
      isa(data.dfdpdx_dxhan,'function_handle')
    [m,n]     = size(x);
    o         = size(p,1);
    dFdpdx_dx = zeros(m,o,n);
    for i=1:n
      dFdpdx_dx(:,:,i) = data.dfdpdx_dxhan(x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxdphan)
      if isempty(data.dfdphan)
        f         = @(x,y) data.fhan(y,x);
        opts      = struct('hfac', data.ode.hfac1);
        dfdp      = @(x,p) ode_num_DFDX(f, p, x, opts);
        opts      = struct('hfac', data.ode.hfac2);
        dFdpdx_dx = ode_num_DFDX_dx(dfdp, x, p, w, opts);
      else
        opts      = struct('hfac', data.ode.hfac1);
        dFdpdx_dx = ode_num_DFDX_dx(data.dfdphan, x, p, w, opts);
      end
    else
      [m,n]     = size(x);
      o         = size(p,1);
      dFdpdx_dx = zeros(m,o,n);
      for i=1:n
        dFdpdx_dx(:,:,i) = reshape(reshape(...
          permute(data.dfdxdphan(x(:,i), p(:,i)), [1 3 2]), ...
          [m*o, m])*w(:,i), [m, o]);
      end
    end
  end
end
end

function dFdtdx_dx = aut_DFDTDX_dx(~, ~, x, ~, ~)
%DFDTDX_dx   Vectorized evaluation of autonomous d(dF/dt(x+hw,p))/dh.
dFdtdx_dx = zeros(size(x));
end

function F = het_F(data, t, x, p)
%F   Vectorized evaluation of non-autonomous F.
if data.ode.vectorized
  F = data.fhan(t, x, p);
else
  [m,n] = size(x);
  F = zeros(m,n);
  for i=1:n, F(:,i) = data.fhan(t(i), x(:,i), p(:,i)); end
end
end

function dFdx = het_DFDX(data, t, x, p)
%DFDX   Vectorized evaluation of non-autonomous dF/dx.
if data.ode.vectorized
  if isempty(data.dfdxhan)
    f    = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
    opts = struct('hfac', data.ode.hfac1);
    dFdx = ode_num_DFDX_v(f, x, [t; p], opts);
  else
    dFdx = data.dfdxhan(t, x, p);
  end
else
  if isempty(data.dfdxhan)
    f    = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
    opts = struct('hfac', data.ode.hfac1);
    dFdx = ode_num_DFDX(f, x, [t; p], opts);
  else
    [m,n] = size(x);
    dFdx  = zeros(m,m,n);
    for i=1:n, dFdx(:,:,i) = data.dfdxhan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdp = het_DFDP(data, t, x, p)
%DFDP   Vectorized evaluation of non-autonomous dF/dp.
if data.ode.vectorized
  if isempty(data.dfdphan)
    f    = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
    opts = struct('hfac', data.ode.hfac1);
    dFdp = ode_num_DFDX_v(f, p, [t; x], opts);
  else
    dFdp = data.dfdphan(t, x, p);
  end
else
  if isempty(data.dfdphan)
    f    = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
    opts = struct('hfac', data.ode.hfac1);
    dFdp = ode_num_DFDX(f, p, [t; x], opts);
  else
    [m,n] = size(x);
    o     = size(p,1);
    dFdp  = zeros(m,o,n);
    for i=1:n, dFdp(:,:,i) = data.dfdphan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdt = het_DFDT(data, t, x, p)
%DFDT   Vectorized evaluation of non-autonomous dF/dt.
if data.ode.vectorized
  if isempty(data.dfdthan)
    [m,n] = size(x);
    f     = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
    opts  = struct('hfac', data.ode.hfac1);
    dFdt  = reshape(ode_num_DFDX_v(f, t, [x; p], opts), [m n]);
  else
    dFdt  = data.dfdthan(t, x, p);
  end
else
  if isempty(data.dfdthan)
    [m,n] = size(x);
    f     = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
    opts  = struct('hfac', data.ode.hfac1);
    dFdt  = reshape(ode_num_DFDX(f, t, [x; p], opts), [m n]);
  else
    [m,n] = size(x);
    dFdt  = zeros(m,n);
    for i=1:n, dFdt(:,i) = data.dfdthan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdxdx = het_DFDXDX(data, t, x, p)
%DFDXDX   Vectorized evaluation of non-autonomous d2F/dx2.
if data.ode.vectorized
  if isempty(data.dfdxdxhan)
    if isempty(data.dfdxhan)
      f      = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(t,x,p) ode_num_DFDX_v(f, x, [t; p], opts);
      dfdx   = @(x,y) dfdx(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdx = ode_num_DFDX_v(dfdx, x, [t; p], opts);
    else
      f      = @(x,y) data.dfdxhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdx = ode_num_DFDX_v(f, x, [t; p], opts);
    end
  else
    dFdxdx = data.dfdxdxhan(t, x, p);
  end
else
  if isempty(data.dfdxdxhan)
    if isempty(data.dfdxhan)
      f      = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(t,x,p) ode_num_DFDX(f, x, [t; p], opts);
      dfdx   = @(x,y) dfdx(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdx = ode_num_DFDX(dfdx, x, [t; p], opts);
    else
      f      = @(x,y) data.dfdxhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdx = ode_num_DFDX(f, x, [t; p], opts);
    end
  else
    [m,n]  = size(x);
    dFdxdx = zeros(m,m,m,n);
    for i=1:n, dFdxdx(:,:,:,i) = data.dfdxdxhan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdxdp = het_DFDXDP(data, t, x, p)
%DFDXDP   Vectorized evaluation of non-autonomous d2F/dxdp.
if data.ode.vectorized
  if isempty(data.dfdxdphan)
    if isempty(data.dfdxhan)
      f      = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(t,x,p) ode_num_DFDX_v(f, x, [t; p], opts);
      dfdx   = @(x,y) dfdx(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdp = ode_num_DFDX_v(dfdx, p, [t; x], opts);
    else
      dfdx   = @(x,y) data.dfdxhan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdp = ode_num_DFDX_v(dfdx, p, [t; x], opts);
    end
  else
    dFdxdp = data.dfdxdphan(t, x, p);
  end
else
  if isempty(data.dfdxdphan)
    if isempty(data.dfdxhan)
      f      = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdx   = @(t,x,p) ode_num_DFDX(f, x, [t; p], opts);
      dfdx   = @(x,y) dfdx(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdxdp = ode_num_DFDX(dfdx, p, [t; x], opts);
    else
      dfdx   = @(x,y) data.dfdxhan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdxdp = ode_num_DFDX(dfdx, p, [t; x], opts);
    end
  else
    [m,n]  = size(x);
    o      = size(p,1);
    dFdxdp = zeros(m,m,o,n);
    for i=1:n, dFdxdp(:,:,:,i) = data.dfdxdphan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdpdp = het_DFDPDP(data, t, x, p)
%DFDXDP   Vectorized evaluation of non-autonomous d2F/dxdp.
if data.ode.vectorized
  if isempty(data.dfdpdphan)
    if isempty(data.dfdphan)
      f      = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dfdp   = @(t,x,p) ode_num_DFDX_v(f, p, [t; x], opts);
      dfdp   = @(x,y) dfdp(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdpdp = ode_num_DFDX_v(dfdp, p, [t; x], opts);
    else
      dfdp   = @(x,y) data.dfdphan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdpdp = ode_num_DFDX_v(dfdp, p, [t; x], opts);
    end
  else
    dFdpdp = data.dfdpdphan(t, x, p);
  end
else
  if isempty(data.dfdpdphan)
    if isempty(data.dfdphan)
      f      = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dfdp   = @(t,x,p) ode_num_DFDX(f, p, [t; x], opts);
      dfdp   = @(x,y) dfdp(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdpdp = ode_num_DFDX(dfdp, p, [t; x], opts);
    else
      dfdp   = @(x,y) data.dfdphan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdpdp = ode_num_DFDX(dfdp, p, [t; x], opts);
    end
  else
    [m,n]  = size(x);
    o      = size(p,1);
    dFdpdp = zeros(m,o,o,n);
    for i=1:n, dFdpdp(:,:,:,i) = data.dfdpdphan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdtdx = het_DFDTDX(data, t, x, p)
%DFDTDX   Vectorized evaluation of non-autonomous d2F/dtdx.
if data.ode.vectorized
  if isempty(data.dfdtdxhan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX_v(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdx = ode_num_DFDX_v(dfdt, x, [t; p], opts);
    else
      dfdt   = @(x,y) data.dfdthan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdx = ode_num_DFDX_v(dfdt, x, [t; p], opts);
    end
  else
    dFdtdx = data.dfdtdxhan(t, x, p);
  end
else
  if isempty(data.dfdtdxhan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdx = ode_num_DFDX(dfdt, x, [t; p], opts);
    else
      dfdt   = @(x,y) data.dfdthan(y(1,:), x, y(2:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdx = ode_num_DFDX(dfdt, x, [t; p], opts);
    end
  else
    [m,n]  = size(x);
    dFdtdx = zeros(m,m,n);
    for i=1:n, dFdtdx(:,:,i) = data.dfdtdxhan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdtdp = het_DFDTDP(data, t, x, p)
%DFDTDP   Vectorized evaluation of non-autonomous d2F/dtdp.
if data.ode.vectorized
  if isempty(data.dfdtdphan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX_v(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdp = ode_num_DFDX_v(dfdt, p, [t; x], opts);
    else
      dfdt   = @(x,y) data.dfdthan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdp = ode_num_DFDX_v(dfdt, p, [t; x], opts);
    end
  else
    dFdtdp = data.dfdtdphan(t, x, p);
  end
else
  if isempty(data.dfdtdphan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdp = ode_num_DFDX(dfdt, p, [t; x], opts);
    else
      dfdt   = @(x,y) data.dfdthan(y(1,:), y(2:end,:), x);
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdp = ode_num_DFDX(dfdt, p, [t; x], opts);
    end
  else
    [m,n]  = size(x);
    o      = size(p,1);
    dFdtdp = zeros(m,o,n);
    for i=1:n, dFdtdp(:,:,i) = data.dfdtdphan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdtdt = het_DFDTDT(data, t, x, p)
%DFDTDT   Vectorized evaluation of non-autonomous d2F/dt2.

if data.ode.vectorized
  if isempty(data.dfdtdthan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX_v(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdt = reshape(ode_num_DFDX_v(dfdt, t, [x; p], opts), [m n]);
    else
      [m,n]  = size(x);
      dfdt   = @(x,y) data.dfdthan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdt = reshape(ode_num_DFDX_v(dfdt, t, [x; p], opts), [m n]);
    end
  else
    dFdtdt = data.dfdtdthan(t, x, p);
  end
else
  if isempty(data.dfdtdthan)
    if isempty(data.dfdthan)
      [m,n]  = size(x);
      f      = @(x,y) data.fhan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dfdt   = @(t,x,p) reshape(ode_num_DFDX(f, t, [x; p], opts), m, []);
      dfdt   = @(x,y) dfdt(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac2);
      dFdtdt = reshape(ode_num_DFDX(dfdt, t, [x; p], opts), [m n]);
    else
      [m,n]  = size(x);
      dfdt   = @(x,y) data.dfdthan(x(1,:), y(1:m,:), y(m+1:end,:));
      opts   = struct('hfac', data.ode.hfac1);
      dFdtdt = reshape(ode_num_DFDX(dfdt, t, [x; p], opts), [m n]);
    end
  else
    [m,n]  = size(x);
    dFdtdt = zeros(m,n);
    for i=1:n, dFdtdt(:,i) = data.dfdtdthan(t(i), x(:,i), p(:,i)); end
  end
end
end

function dFdx_dx = het_DFDX_dx(data, t, x, p, w)
%DFDX_dx   Vectorized evaluation of non-autonomous dF(t,x+hw,p)/dh.
if data.ode.vectorized
  if isfield(data,'dfdx_dxhan') && isa(data.dfdx_dxhan,'function_handle')
    dFdx_dx = data.dfdx_dxhan(t, x, p, w);
  else
    if isempty(data.dfdxhan)
      f       = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts    = struct('hfac', data.ode.hfac1);
      dFdx_dx = ode_num_DFDX_dx_v(f, x, [t; p], w, opts);
    else
      [m,n]   = size(x);
      rows    = repmat(reshape(1:m*n, [m n]),[m 1]);
      cols    = repmat(1:m*n, [m 1]);
      dfdx    = data.dfdxhan(t, x, p);
      dfdx    = sparse(rows, cols, dfdx(:));
      dFdx_dx = reshape(dfdx*w(:), [m n]);
    end
  end
else
  if isfield(data,'dfdx_dxhan') && isa(data.dfdx_dxhan,'function_handle')
    [m,n]   = size(x);
    dFdx_dx = zeros(m,n);
    for i=1:n
      dFdx_dx(:,i) = data.dfdx_dxhan(t(i), x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxhan)
      f       = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
      opts    = struct('hfac', data.ode.hfac1);
      dFdx_dx = ode_num_DFDX_dx(f, x, [t; p], w, opts);
    else
      [m,n]   = size(x);
      dFdx_dx = zeros(m,n);
      for i=1:n
        dFdx_dx(:,i) = data.dfdxhan(t(i), x(:,i), p(:,i))*w(:,i);
      end
    end
  end
end
end

function dFdxdx_dx = het_DFDXDX_dx(data, t, x, p, w)
%DFDXDX_dx   Vectorized evaluation of non-autonomous d(dF/dx(t,x+hw,p))/dh.
if data.ode.vectorized
  if isfield(data, 'dfdxdx_dxhan') && ...
      isa(data.dfdxdx_dxhan,'function_handle')
    dFdxdx_dx = data.dfdxdx_dxhan(t, x, p, w);
  else
    if isempty(data.dfdxdxhan)
      if isempty(data.dfdxhan)
        f         = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dfdx      = @(t,x,p) ode_num_DFDX_v(f, x, [t; p], opts);
        dfdx      = @(x,y) dfdx(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdxdx_dx = ode_num_DFDX_dx_v(dfdx, x, [t; p], w, opts);
      else
        dfdx      = @(x,y) data.dfdxhan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdxdx_dx = ode_num_DFDX_dx_v(dfdx, x, [t; p], w, opts);
      end
    else
      [m,n]     = size(x);
      rows      = repmat(reshape(1:m^2*n, [m^2 n]),[m 1]);
      cols      = repmat(1:m*n, [m^2 1]);
      dfdxdx    = data.dfdxdxhan(t, x, p);
      dfdxdx    = sparse(rows, cols, dfdxdx(:));
      dFdxdx_dx = reshape(dfdxdx*w(:), [m, m, n]);
    end
  end
else
  if isfield(data, 'dfdxdx_dxhan') && ...
      isa(data.dfdxdx_dxhan,'function_handle')
    [m,n]   = size(x);
    dFdxdx_dx = zeros(m,m,n);
    for i=1:n
      dFdxdx_dx(:,:,i) = data.dfdxdx_dxhan(t(i), x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxdxhan)
      if isempty(data.dfdxhan)
        f         = @(x,y) data.fhan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dfdx      = @(t,x,p) ode_num_DFDX(f, x, [t; p], opts);
        dfdx      = @(x,y) dfdx(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdxdx_dx = ode_num_DFDX_dx(dfdx, x, [t; p], w, opts);
      else
        dfdx      = @(x,y) data.dfdxhan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdxdx_dx = ode_num_DFDX_dx(dfdx, x, [t; p], w, opts);
      end
    else % not fixed
      [m,n]     = size(x);
      rows      = repmat(reshape(1:m^2*n, [m^2 n]),[m 1]);
      cols      = repmat(1:m*n, [m^2 1]);
      dfdxdx = zeros(m,m,m,n);
      for i=1:n
        dfdxdx(:,:,:,i) = data.dfdxdxhan(t(i), x(:,i), p(:,i));
      end
      dfdxdx    = sparse(rows, cols, dfdxdx(:));
      dFdxdx_dx = reshape(dfdxdx*w(:), [m, m, n]);
    end
  end
end
end

function dFdpdx_dx = het_DFDPDX_dx(data, t, x, p, w)
%DFDPDX_dx   Vectorized evaluation of non-autonomous d(dF/dp(t,x+hw,p))/dh.
if data.ode.vectorized
  if isfield(data, 'dfdpdx_dxhan') && ...
      isa(data.dfdpdx_dxhan,'function_handle')
    dFdpdx_dx = data.dfdpdx_dxhan(t, x, p, w);
  else
    if isempty(data.dfdxdphan)
      if isempty(data.dfdphan)
        f         = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
        opts      = struct('hfac', data.ode.hfac1);
        dfdp      = @(t,x,p) ode_num_DFDX_v(f, p, [t; x], opts);
        dfdp      = @(x,y) dfdp(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdpdx_dx = ode_num_DFDX_dx_v(dfdp, x, [t; p], w, opts);
      else
        dfdp      = @(x,y) data.dfdphan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdpdx_dx = ode_num_DFDX_dx_v(dfdp, x, [t; p], w, opts);
      end
    else
      [m,n]     = size(x);
      o         = size(p,1);
      rows      = repmat(reshape(1:m*o*n, [m*o n]),[m 1]);
      cols      = repmat(1:m*n, [m*o 1]);
      dfdpdx    = permute(data.dfdxdphan(t, x, p), [1 3 2 4]);
      dfdpdx    = sparse(rows, cols, dfdpdx(:));
      dFdpdx_dx = reshape(dfdpdx*w(:), [m, o, n]);
    end
  end
else
  if isfield(data, 'dfdpdx_dxhan') && ...
      isa(data.dfdpdx_dxhan,'function_handle')
    [m,n]   = size(x);
    o       = size(p,1);
    dFdpdx_dx = zeros(m,o,n);
    for i=1:n
      dFdpdx_dx(:,:,i) = data.dfdpdx_dxhan(t(i), x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdxdphan)
      if isempty(data.dfdphan)
        f         = @(x,y) data.fhan(y(1,:), y(2:end,:), x);
        opts      = struct('hfac', data.ode.hfac1);
        dfdp      = @(t,x,p) ode_num_DFDX(f, p, [t; x], opts);
        dfdp      = @(x,y) dfdp(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdpdx_dx = ode_num_DFDX_dx(dfdp, x, [t; p], w, opts);
      else
        dfdp      = @(x,y) data.dfdphan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdpdx_dx = ode_num_DFDX_dx(dfdp, x, [t; p], w, opts);
      end
    else
      [m,n]     = size(x);
      o         = size(p,1);
      rows      = repmat(reshape(1:m*o*n, [m*o n]),[m 1]);
      cols      = repmat(1:m*n, [m*o 1]);
      dfdpdx = zeros(m,m,o,n);
      for i=1:n
        dfdpdx(:,:,:,i) = data.dfdxdphan(t(i), x(:,i), p(:,i));
      end
      dfdpdx    = permute(dfdpdx, [1 3 2 4]);
      dfdpdx    = sparse(rows, cols, dfdpdx(:));
      dFdpdx_dx = reshape(dfdpdx*w(:), [m, o, n]);
    end
  end
end
end

function dFdtdx_dx = het_DFDTDX_dx(data, t, x, p, w)
%DFDTDX_dx   Vectorized evaluation of non-autonomous d(dF/dt(t,x+hw,p))/dh.
if data.ode.vectorized
  if isfield(data, 'dfdtdx_dxhan') && ...
      isa(data.dfdtdx_dxhan,'function_handle')
    dFdtdx_dx = data.dfdtdx_dxhan(t, x, p, w);
  else
    if isempty(data.dfdtdxhan)
      [m,n]     = size(x);
      if isempty(data.dfdthan)
        f         = @(x,y) data.fhan(x, y(1:m,:), y(m+1:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dfdt      = @(t,x,p) ode_num_DFDX_v(f, t, [x; p], opts);
        dfdt      = @(x,y) dfdt(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdtdx_dx = ode_num_DFDX_dx_v(dfdt, x, [t; p], w, opts);
      else
        dfdt      = @(x,y) data.dfdthan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdtdx_dx = ode_num_DFDX_dx_v(dfdt, x, [t; p], w, opts);
      end
      dFdtdx_dx = reshape(dFdtdx_dx, [m, n]);
    else
      [m,n]     = size(x);
      rows      = repmat(reshape(1:m*n, [m n]),[m 1]);
      cols      = repmat(1:m*n, [m 1]);
      dfdtdx    = data.dfdtdxhan(t, x, p);
      dfdtdx    = sparse(rows, cols, dfdtdx(:));
      dFdtdx_dx = reshape(dfdtdx*w(:), [m, n]);
    end
  end
else
  if isfield(data, 'dfdtdx_dxhan') && ...
      isa(data.dfdtdx_dxhan,'function_handle')
    [m,n]   = size(x);
    dFdtdx_dx = zeros(m,n);
    for i=1:n
      dFdtdx_dx(:,i) = data.dfdtdx_dxhan(t(i), x(:,i), p(:,i), w(:,i));
    end
  else
    if isempty(data.dfdtdxhan)
      [m,n]     = size(x);
      if isempty(data.dfdthan)
        f         = @(x,y) data.fhan(x, y(1:m,:), y(m+1:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dfdt      = @(t,x,p) ode_num_DFDX(f, t, [x; p], opts);
        dfdt      = @(x,y) dfdt(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac2);
        dFdtdx_dx = ode_num_DFDX_dx(dfdt, x, [t; p], w, opts);
      else
        dfdt      = @(x,y) data.dfdthan(y(1,:), x, y(2:end,:));
        opts      = struct('hfac', data.ode.hfac1);
        dFdtdx_dx = ode_num_DFDX_dx(dfdt, x, [t; p], w, opts);
      end
      dFdtdx_dx = reshape(dFdtdx_dx, [m, n]);
    else
      [m,n]     = size(x);
      rows      = repmat(reshape(1:m*n, [m n]),[m 1]);
      cols      = repmat(1:m*n, [m 1]);
      dfdtdx = zeros(m,m,n);
      for i=1:n
        dfdtdx(:,:,i) = data.dfdtdxhan(t(i), x(:,i), p(:,i));
      end
      dfdtdx    = sparse(rows, cols, dfdtdx(:));
      dFdtdx_dx = reshape(dfdtdx*w(:), [m, n]);
    end
  end
end
end

%% First-order finite difference approximations of Jacobians

% Vectorized algorithm
function J = ode_num_DFDX_v(F, x, y, opts)

[m, n] = size(x);
idx    = repmat(1:n, [m 1]);
x0     = x(:,idx);
y0     = y(:,idx);

idx = repmat(1:m, [1 n]);
idx = sub2ind([m m*n], idx, 1:m*n);

h = opts.hfac*(1.0 + abs(x0(idx)));
x = x0;

x(idx) = x0(idx)+h;
fr     = F(x, y0);
x(idx) = x0(idx)-h;
fl     = F(x, y0);

l  = size(fr);
hi = reshape(repmat(0.5./h, [prod(l(1:end-1)),1]), l);
J  = reshape(hi.*(fr-fl), [l(1:end-1) m n]);

end

% Non-vectorized algorithm
function J = ode_num_DFDX(F, x, y, opts)

[m, n] = size(x);

fr = F(x(:,1), y(:,1));
l  = size(fr);

J  = zeros(prod(l),m,n);

for j=1:n
  x0 = x(:,j);
  h  = opts.hfac*( 1.0 + abs(x0) );
  hi = 0.5./h;
  for i=1:m
    xx       = x0;
    xx(i)    = x0(i)+h(i);
    fr       = F(xx, y(:,j));
    xx(i)    = x0(i)-h(i);
    fl       = F(xx, y(:,j));
    J(:,i,j) = hi(i)*(fr(:)-fl(:));
  end
end

if numel(l)==2 && l(2)==1
  J = reshape(J, [l(1) m n]);
else
  J = reshape(J, [l m n]);
end

end

%% First-order finite difference approximations of directional derivatives

% Vectorized algorithm
function J_dx = ode_num_DFDX_dx_v(F, x, y, w, opts)

[m, n] = size(x);

h  = opts.hfac*(1.0 + max(abs(x),[], 1));
fr = F(x+repmat(h, m, 1).*w, y);
fl = F(x-repmat(h, m, 1).*w, y);

l  = size(fr);
if n>1
  hi = reshape(repmat(0.5./h, [prod(l(1:end-1)),1]), l);
else
  hi = repmat(0.5./h, l);
end
J_dx = hi.*(fr-fl);

end

% Non-vectorized algorithm
function J_dx = ode_num_DFDX_dx(F, x, y, w, opts)

n = size(x,2);

fr = F(x(:,1), y(:,1));
l  = size(fr);

J_dx  = zeros(prod(l),n);

for i=1:n
  h  = opts.hfac*(1.0 + max(abs(x(:,i))));
  fr = F(x(:,i)+h*w(:,i), y(:,i));
  fl = F(x(:,i)-h*w(:,i), y(:,i));
  J_dx(:,i) = 0.5/h*(fr(:)-fl(:));
end

if numel(l)==2 && l(2)==1
  J_dx = reshape(J_dx, [l(1) n]);
else
  J_dx = reshape(J_dx, [l n]);
end

end
