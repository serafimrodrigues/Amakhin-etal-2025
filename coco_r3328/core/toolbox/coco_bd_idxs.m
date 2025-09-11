function idxs = coco_bd_idxs(bd, pt_type)
% COCO_BD_IDXS   Extract row indices from bifurcation data
%
% IDXS = COCO_BD_IDXS(BD, PT_TYPE)
% BD      = { BDATA | RUNID }
% PT_TYPE = { ([]|''|'all'|TYPE) }
%
%   returns row indices in the bifurcation data cell array BDATA or
%   associated with the run RUNID corresponding to charts of type TYPE or
%   to all labeled charts.

% Copyright (C) Frank Schilder, Harry Dankowicz

if nargin<2
  pt_type = [];
end

if ischar(pt_type)
	if strcmpi(pt_type, 'all')
		pt_type = '';
  end
end

if isempty(pt_type)
  labs = coco_bd_col(bd, 'LAB', false);
  f    = @(x) ~isempty(x);
  idxs = find(cellfun(f, labs))';
else
  types = coco_bd_col(bd, 'TYPE');
  idxs  = find(strcmp(pt_type, types))';
end
