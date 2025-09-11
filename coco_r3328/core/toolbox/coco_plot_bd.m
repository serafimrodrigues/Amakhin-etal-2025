function coco_plot_bd(varargin)
%COCO_PLOT_BD    Plot bifurcation diagram.
%
%   COCO_PLOT_BD([AH], [THEME], RUN, [COL1, [IDX1], [COL2, [IDX2], [COL3, [IDX3]]]])
%  
%   COCO_PLOT_BD(RUN) plots the default solution measure as a function of
%   the primary continuation parameter. RUN is the run name of the branch.
%
%   COCO_PLOT_BD(RUN, COL1, [IDX1], ...) plots the user specified columns
%   of the bifurcation data. Each of COL1 ... COL3 contains a single column
%   header or a cell array of columns headers. A header may be included
%   several times. For COL1 ... COL3 with multi-dimensional data in each
%   row, IDX1 ... IDX3 select the dimension to plot or defines a
%   scalar-valued function that takes the row data as input. COCO_PLOT_BD
%   tries to be smart when selecting default dimensions to plot.
%
%   COCO_PLOT_BD(THEME, ...) uses a user-specified theme for plotting.
%   THEME is a struct and the fields given in THEME are merged into the
%   default theme recursively. See coco_plot_theme for help on default
%   themes and what fields are available.
%
%   COCO_PLOT_BD(AH, ...) uses the provided axes for plotting.
%
% See also: COCO_PLOT_THEME

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: coco_plot_bd.m 3015 2017-08-19 03:25:33Z hdankowicz $

thm = struct();

grammar   = '[AH] [THM] RUN [COL1 [IDX1] [COL2 [IDX2] [COL3 [IDX3]]]]';
args_spec = {
    'AH',     '',   'axes',    'ah', gca, 'read', {}
   'THM',     '',   'stct', 'theme', thm, 'read', {}
   'RUN',     '',    'str',   'run',  '', 'read', {}
  'COL1', 'cell',  '{str}',  'col1',  {}, 'read', {}
  'IDX1',     '', 'num|@f',  'idx1',  [], 'read', {}
  'COL2', 'cell',  '{str}',  'col2',  {}, 'read', {}
  'IDX2',     '', 'num|@f',  'idx2',  [], 'read', {}
  'COL3', 'cell',  '{str}',  'col3',  {}, 'read', {}
  'IDX3',     '', 'num|@f',  'idx3',  [], 'read', {}
  };
opts_spec = {};
[args, opts] = coco_parse(grammar, args_spec, opts_spec, varargin{:}); %#ok<ASGLU>

tbinfid = 'tb_info';
if isfield(args.theme, 'oid')
  tbinfid = coco_get_id(args.theme.oid, tbinfid);
end
[bd, tb_info, bddat] = coco_bd_read(args.run, 'bd', tbinfid, 'bddat');
if ~isempty(tb_info)
  thm = coco_plot_theme(tb_info);
else
  thm = coco_plot_theme();
end
thm = coco_merge(thm, args.theme);

if isempty(args.col1)
  if isempty(thm.bd.col1)
    args.col1 = {bddat.op_names{1}};
  else
    args.col1 = {thm.bd.col1};
  end
end

if isempty(args.idx1)
  assert(numel(args.col1)==1, '%s: %s', ...
    'missing function along 1st dimension', mfilename);
  args.idx1 = 1;
end

if isempty(args.col2)
  if isempty(thm.bd.col2)
    if numel(bddat.op_names)>1
      args.col2 = {bddat.op_names{2}};
    else
      error('%s: theme error: ''theme.bd.col2'' empty', mfilename);
    end
  else
    args.col2 = {thm.bd.col2};
  end
end

if isempty(args.idx2)
  assert(numel(args.col2)==1, '%s: %s', ...
    'missing function along 2nd dimension', mfilename);
  args.idx2 = 1;
  if numel(args.col1)==1 && isnumeric(args.idx1) ...
      && strcmp(args.col2, args.col1)
    args.idx2 = args.idx1 + 1;  
  end
end

if isempty(args.col3)
  dim = 2;
  spfunc = @(ah,HH,S,PT,SP, x,y,z, ST) stab_plot(ah,HH,S,PT,SP, x,y, ST);
  pfunc  = @(ah, x,y,z, varargin) plot(ah, x,y, varargin{:});
else
  dim = 3;
  spfunc = @(ah,HH,S,PT,SP, x,y,z, ST) stab_plot3(ah,HH,S,PT,SP, x,y,z, ST);
  pfunc  = @(ah, x,y,z, varargin) plot3(ah, x,y,z, varargin{:});
  
  if isempty(args.idx3)
    assert(numel(args.col3)==1, '%s: %s', ...
      'missing function along 3rd dimension', mfilename);
    args.idx3 = 1;
    if numel(args.col1)==1 && numel(args.col2)==1 ...
        && isnumeric(args.idx1) && isnumeric(args.idx2)
      flags = strcmp(args.col3, [args.col1, args.col2]);
      if all(flags)
        args.idx3 = max(args.idx1, args.idx2)+1;
      elseif flags(1)
        args.idx3 = args.idx1+1;
      elseif flags(2)
        args.idx3 = args.idx2+1;
      end
    elseif numel(args.col1)==1 && isnumeric(args.idx1) && ...
        strcmp(args.col3, args.col1)
      args.idx3 = args.idx1 + 1;
    elseif numel(args.col2)==1 && isnumeric(args.idx2) && ...
        strcmp(args.col3, args.col2)
      args.idx3 = args.idx2 + 1;
    end
  end
end

x = cell(1,numel(args.col1));
for i=1:numel(args.col1)
  x{i} = coco_bd_col(bd, args.col1{i});
end

if ~isa(args.idx1, 'function_handle')
  assert(numel(args.col1)==1, '%s: %s', ...
    'incorrect indexing along 1st dimension', mfilename);
  if isempty(thm.xlab)
    if size(x{1},1)>1
      thm.xlab = sprintf('%s_%d', args.col1{1}, args.idx1);
    else
      thm.xlab = args.col1{1};
    end
  end
  args.idx1 = @(x) x(args.idx1,:);
end
x = args.idx1(x{:});

y = cell(1,numel(args.col2));
for i=1:numel(args.col2)
  y{i} = coco_bd_col(bd, args.col2{i});
end

if ~isa(args.idx2, 'function_handle')
  assert(numel(args.col2)==1, '%s: %s', ...
    'incorrect indexing along 2nd dimension', mfilename);
  if isempty(thm.ylab)
    if size(y{1},1)>1
      thm.ylab = sprintf('%s_%d', args.col2{1}, args.idx2);
    else
      thm.ylab = args.col2{1};
    end
  end
  args.idx2 = @(x) x(args.idx2,:);
end
y = args.idx2(y{:});

if dim==2
  z = nan(size(x));
elseif dim==3
  z = cell(1,numel(args.col3));
  for i=1:numel(args.col3)
    z{i} = coco_bd_col(bd, args.col3{i});
  end
  
  if ~isa(args.idx3, 'function_handle')
    assert(numel(args.col3)==1, '%s: %s', ...
      'incorrect indexing along 3rd dimension', mfilename);
    if isempty(thm.zlab)
      if size(z{1},1)>1
        thm.zlab = sprintf('%s_%d', args.col3{1}, args.idx3);
      else
        thm.zlab = args.col3{1};
      end
    end
    args.idx3 = @(x) x(args.idx3,:);
  end
  z = args.idx3(z{:});
end

if isempty(thm.ustab)
  S   = ones(size(x));
  PT  = cell(size(x));
  SP  = {};
else
  assert(all(isfield(thm, {'ustabfun', 'usept'})), ...
    '%s: theme error: ''ustabfun'' or ''usept'' empty', mfilename);
  S   = thm.ustabfun(coco_bd_col(bd, thm.ustab));
  PT  = coco_bd_col(bd, 'TYPE', false);
  SP  = thm.usept;
end

HH = ~ishold;

if ~iscell(thm.lspec{1})
  thm.lspec = {thm.lspec};
end

spfunc(args.ah,HH,S,PT,SP, x,y,z, thm.lspec);

N = numel(thm.special);
for i=1:N
  SP = thm.special{i};
  assert(isfield(thm,SP), 'Format not defined for special point %s', SP);
  LS = thm.(SP);
  idx = coco_bd_idxs(bd, SP);
  pfunc(args.ah, x(:,idx),y(:,idx),z(:,idx), LS{:});
end

if thm.axlabs
  xlabel(thm.xlab, thm.xlstyle{:});
  ylabel(thm.ylab, thm.ylstyle{:});
  if dim==3
    zlabel(thm.zlab, thm.zlstyle{:});
  end
end

if HH; hold off; end

end

function stab_plot(ah,HH,S,PT,SP, x,y, ST)

CF  = @(x) (isempty(x) || any(strcmp(x, {'RO', 'EP'})));
PTF = ~cellfun(CF, PT);
NSP = numel(SP);
II  = 1;
EI  = size(x,2);
I   = II;
while true
  if II>=EI; break; end
  %[I, I0] = next_index(EI, S, PT, PTF, NSP, SP, I, II);
  [I, II] = next_index(EI, S, PT, NSP, SP, II);
  if numel(ST)>=S(I-1)
    plot(ah, x(:,II:I)', y(:,II:I)', ST{S(I-1)}{:});
  end
  %II = I0;
  II = I;
  if HH; hold on; end
end

end

function stab_plot3(ah,HH,S,PT,SP, x,y,z, ST)

CF  = @(x) (isempty(x) || any(strcmp(x, {'RO', 'EP'})));
PTF = ~cellfun(CF, PT);
NSP = numel(SP);
II = 1;
EI = size(x,2);
I  = II;
while true
  if II>=EI; break; end
  %[I, I0] = next_index(EI, S, PT, PTF, NSP, SP, I, II);
  [I, II] = next_index(EI, S, PT, NSP, SP, II);
  if numel(ST)>=S(I-1)
    plot3(ah, x(:,II:I)', y(:,II:I)', z(:,II:I)', ST{S(I-1)}{:});
  end
  II = I;
%   if numel(ST)>=S(II)
%     plot3(ah, x(:,II:I0)', y(:,II:I0)', z(:,II:I0)', ST{S(II)}{:});
%   end
%   II = I0;
  if HH; hold on; end
end

end

function [I, II] = next_index(EI, S, PT, NSP, SP, II)

BP = false;
for J=1:NSP
  CSP = SP{J};
  if strcmp(PT{II},CSP)
    BP = true;
    break
  end
end
if BP
  eflag = false;
  while ~eflag
    for J=1:NSP
      CSP = SP{J};
      if II<EI && strcmp(PT{II+1},CSP)
        II = II+1;
        eflag = false;
        break
      end
      eflag = true;
    end
  end
end
I = II;
eflag = false;
while ~eflag && I<EI
  for J=1:NSP
    CSP = SP{J};
    if strcmp(PT{I+1},CSP)
      eflag = true;
      break
    end
  end
  I = I+1;
  if NSP==0 && S(I-1)~=S(I)
    eflag = true;
  end
end

end

function [I, I0] = next_index_old(EI, S, PT, PTF, NSP, SP, I, II) %#ok<DEFNU>

while (I<EI && S(II)==S(I)); I=I+1; end
I0 = I-1;
while (I0>II && PTF(I0)); I0 = I0-1; end
eflag = false;
for J=1:NSP
  CSP = SP{J};
  for K=(I0+1):(I-1)
    if strcmp(PT{K},CSP)
      I0 = K;
      eflag = true;
      break;
    end
  end
  if eflag; break; end
end
if ~eflag
  I0 = I;
end

end
