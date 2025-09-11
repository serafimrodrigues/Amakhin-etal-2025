function labs = coco_bd_labs(bd, pt_type)
% COCO_BD_LABS   Extract chart labels from bifurcation data
%
% LABS = COCO_BD_LABS(BD, PT_TYPE)
% BD      = { BDATA | RUNID }
% PT_TYPE = { ([]|''|'all'|TYPE) }
%
%   returns chart labels from the bifurcation data cell array
%   BDATA or associated with the run RUNID corresponding to
%   charts of type TYPE or to all labeled charts.

% Copyright (C) Frank Schilder, Harry Dankowicz

if nargin<2
  pt_type = [];
end

if ischar(pt_type)
	if strcmpi(pt_type, 'all')
		pt_type = '';
  end
end

labs = coco_bd_col(bd, 'LAB', false);

if isempty(pt_type)
  labs = [ labs{:} ];
else
  types = coco_bd_col(bd, 'TYPE');
  idx   = strcmp(pt_type, types);
  labs  = [ labs{idx} ];
end
