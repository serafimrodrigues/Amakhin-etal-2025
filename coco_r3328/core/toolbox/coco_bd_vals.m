function col = coco_bd_vals(bd, labs, name)
% COCO_BD_VALS   Extract column data for labeled charts from bifurcation data
%
% VALS = COCO_BD_VALS(BD, LABS, NAME)
% BD   = { BDATA | RUNID }
% LABS = { LABELS | PT_TYPE }
%
%   returns data from the columns denoted by NAME of the bifurcation data
%   cell array BDATA or associated with the run RUNID corresponding to
%   chart labels LABS or associated with charts of type PT_TYPE.

% Copyright (C) Frank Schilder, Harry Dankowicz

if ischar(bd)
  bd = coco_bd_read(bd);
end

if ~isnumeric(labs) || isempty(labs)
  idx = coco_bd_idxs(bd, labs);
else
  idx = coco_bd_lab2idx(bd, labs);
end

if iscell(name)
  col = cell(1,numel(name));
  for i=1:numel(name)
    col{i} = coco_get_col(bd, name{i}, idx);
  end
  col = cat_arrays(col);
else
  col = coco_get_col(bd, name, idx);
end

end

function col = coco_get_col(bd, name, idx)
col = strcmp(name, bd(1,:));
if ~any(col)
  error('%s: column not found: ''%s''', mfilename, name);
end

col = bd(1+idx, find(col,1));
if isempty(col)
  return
end

col = merge_arrays(col);
end

function col = merge_arrays(col)
if all(cellfun(@isnumeric, col)) || all(cellfun(@isempty, col))
  cat_flag = true;
  for d = 1:ndims(col{1})
    if any(cellfun('size', col, d) ~= size(col{1},d))
      cat_flag = false;
      break
    end
  end
  if cat_flag
    if d==2
      [m, n] = size(col{1});
      if n == 1
        col = horzcat(col{:});
      elseif m == 1
        col = vertcat(col{:});
      else
        col = cat(d+1, col{:});
      end
    else
      col = cat(d+1, col{:});
    end
  end
end
end

function col = cat_arrays(col)
if all(cellfun(@isnumeric, col)) || all(cellfun(@isempty, col))
  cat_flag = true;
  for d = 2:ndims(col{1})
    if any(cellfun('size', col, d) ~= size(col{1},d))
      cat_flag = false;
      break
    end
  end
  if cat_flag
    col = cat(1, col{:});
  end
end
end
