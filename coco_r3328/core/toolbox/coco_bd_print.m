function varargout = coco_bd_print(runid, varargin)
%% COCO_BD_PRINT    Print bifurcation data for labeled charts to screen
%
% VARARGOUT = COCO_BD_PRINT(RUNID, VARARGIN)
% VARARGIN = { [COLS] }
%
%    prints bifurcation data for labeled charts associated with the run
%    RUNID with non-default columns specified by COLS.

% Copyright (C) Frank Schilder, Harry Dankowicz

if nargout>=1
  varargout{1} = coco_bd_read(runid);
end

coco_print_bd(runid, varargin);

end
