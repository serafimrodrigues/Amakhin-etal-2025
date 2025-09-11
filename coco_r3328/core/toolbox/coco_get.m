function varargout = coco_get(prob, varargin)
%COCO_GET   Read optional settings from a continuation problem structure.
%
% COCO_GET(PROB, [MODE,] [PATH, [P]... ])
%
% get property P of PATH using inheritance mode MODE.

assert(isfield(prob, 'opts') && isa(prob.opts, 'coco_opts_tree'), ...
  '%s: %s', 'argument must be a continuation problem structure', ...
  mfilename);

mode = '-inherit';
s = coco_stream(varargin{:});
if coco_opts_tree.is_inherit_mode(s.peek)
  mode = s.get;
end
level = coco_opts_tree.inherit_level(mode);
path  = s.get;
if strcmpi(path, 'all')
  path = '';
end

idx = 1;
while idx==1 || (idx<=nargout && ~isempty(s))
  varargout{idx} = prob.opts.prop_get(path, s.get, level); %#ok<AGROW>
  idx = idx+1;
end

end
