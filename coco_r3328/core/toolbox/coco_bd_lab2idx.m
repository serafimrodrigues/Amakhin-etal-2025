function idx = coco_bd_lab2idx(bd, labs)
%COCO_BD_LAB2IDX    Compute indices corresponding to labels.
%
% IDX = COCO_BD_LAB2IDX(BD, LABS)
% BD   = { BDATA | RUNID }
%
%   returns row indices in the bifurcation data cell array BDATA or
%   associated with the run RUNID corresponding to charts labels LABS.
%
%   Usage:
%
%   idx = coco_bd_lab2idx(bd, 1);   % get row-index of label 1
%   x   = coco_bd_col(bd, '||U||'); % extract column ||U||
%   y   = x(idx);                   % get ||U|| for solution with label 1

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: coco_bd_lab2idx.m 3218 2023-05-29 00:23:24Z hdankowicz $

LCOL = coco_bd_col(bd, 'LAB', false);
idx  = zeros(size(labs));
N    = numel(labs);

for i=1:N
  func = @(x) ~isempty(x) && (x==labs(i));
  idx(i) = find(cellfun(func, LCOL), 1, 'first');
end
end
