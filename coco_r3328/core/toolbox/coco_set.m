function prob = coco_set(prob, varargin)
%COCO_SET   Modify optional settings of a continuation problem structure.
%
% COCO_SET(PROB, PATH, [P, VAL]... ])
%
% set property P of PATH to VAL.

assert(isfield(prob, 'opts') && isa(prob.opts, 'coco_opts_tree'), ...
  '%s: %s', 'argument must be a continuation problem structure', ...
  mfilename);

s = coco_stream(varargin{:});
assert(ischar(s.peek), '%s: path must be a string', mfilename);
path = s.get;
if strcmpi(path, 'all')
  path = '';
end
all = isempty(path);

while ~isempty(s)
  prop = s.get;
  val  = s.get;
  if all
    check_all_prop(prop, val);
  end
  prob.opts = prob.opts.prop_set(path, prop, val);
end

end

function check_all_prop(prop, val)

if ~ischar(prop)
  error ('%s: attempt to set illegal property at ''all''', mfilename);
end

switch lower(prop)
  
  case 'tol'
    assert(isnumeric(val) && numel(val)==1 && val>0, ...
      '%s: all.TOL must be a positive scalar', mfilename);
    
  case 'cleandata'
    assert(numel(val)==1 && (islogical(val) || isnumeric(val)), ...
      '%s: all.CleanData must be true, false, or a scalar', mfilename);
    
  case 'loglevel'
    assert(isnumeric(val) && numel(val)==1 && mod(val,1)==0 && val>=0, ...
      '%s: all.LogLevel must be an integer >= 0', mfilename);
    
  case 'data_dir'
    assert(ischar(val), ...
      '%s: all.data_dir must be a directory name', mfilename);
    
  otherwise
    error('%s: property ''%s'' cannot be set at ''all''', ...
      mfilename, prop);
end

end
