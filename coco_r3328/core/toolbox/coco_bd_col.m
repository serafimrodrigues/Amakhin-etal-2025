function col = coco_bd_col(bd, name, cat_flag)
% COCO_BD_COL   Extract column data from bifurcation data
%
% COL = COCO_BD_COL(BD, NAME, CAT_FLAG)
% BD       = { BDATA | RUNID }
% CAT_FLAG = { (true|false) }
%
%   returns data from the columns denoted by NAME of the bifurcation data
%   cell array BDATA or associated with the run RUNID. By default (unless
%   CAT_FLAG is false), and if compatible, data from multiple columns is
%   concatenated along the first dimension.

% Copyright (C) Frank Schilder, Harry Dankowicz

if ischar(bd)
  bd = coco_bd_read(bd);
end

if nargin<3
  cat_flag = true;
end

if iscell(name)
  col = cell(1,numel(name));
  for i=1:numel(name)
    col{i} = coco_get_col(bd, name{i}, cat_flag);
  end
  if cat_flag
    col = cat_arrays(col);
  end
else
  col = coco_get_col(bd, name, cat_flag);
end

end

function col = coco_get_col(bd, name, cat_flag)
col = strcmp(name, bd(1,:));
if ~any(col)
  error('%s: column not found: ''%s''', mfilename, name);
end

col = bd(2:end, find(col,1));
if isempty(col)
  return
end

if cat_flag
  col = merge_arrays(col);
end
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
