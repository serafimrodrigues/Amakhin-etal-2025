function val = coco_bd_val(bd, lab, name)
% COCO_BD_VAL   Extract column data for a single labeled chart from bifurcation data
%
% VAL = COCO_BD_VAL(BD, LAB, NAME)
% BD = { BDATA | RUNID }
%
%   returns data from the column denoted by NAME of the bifurcation data
%   cell array BDATA or associated with the run RUNID corresponding to
%   chart label LAB.

% Copyright (C) Frank Schilder, Harry Dankowicz

val = coco_bd_vals(bd, lab, name);

end
