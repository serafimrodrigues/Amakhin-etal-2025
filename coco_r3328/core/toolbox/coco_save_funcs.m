function [prob, all_funcs] = coco_save_funcs(prob)
all_funcs.efunc   = prob.efunc;
if isfield(prob, 'adjoint')
  all_funcs.adjoint = prob.adjoint;
end
all_funcs.slots   = prob.slots;
if isfield(prob.efunc, 'events')
  all_funcs.events = prob.efunc.events;
  all_funcs.ev     = prob.efunc.ev;
end

% call toolbox data copy functions

nefuncs = numel(prob.efunc.funcs);
nsfuncs = numel(prob.slots.funcs);
if isfield(prob.efunc, 'events')
  nhfuncs = numel(prob.efunc.events);
else
  nhfuncs = 0;
end
if isfield(prob, 'adjoint')
  nafuncs = numel(prob.adjoint.funcs);
else
  nafuncs = 0;
end

objidx = [];

for i=1:nefuncs
  data = prob.efunc.funcs(i).data;
  fid  = prob.efunc.funcs(i).identifyer; %#ok<NASGU> % for debugging only
  copy = prob.efunc.funcs(i).copy;
  if ~isempty(copy)
    prob.efunc.funcs(i).data = copy(prob, data);
  end
  if isa(data,'coco_func_data')
    objidx = union(objidx, data.getobjidx);
  end
end

for i=1:nsfuncs
  data = prob.slots.funcs(i).data;
  fid  = prob.slots.funcs(i).identifyer; %#ok<NASGU> % for debugging only
  copy = prob.slots.funcs(i).copy;
  if ~isempty(copy)
    prob.slots.funcs(i).data = copy(prob, data);
  end
  if isa(data,'coco_func_data')
    objidx = union(objidx, data.getobjidx);
  end
end

for i=1:nhfuncs
  data = prob.efunc.events(i).data;
  fid  = prob.efunc.events(i).name{1}; %#ok<NASGU> % for debugging only
  copy = prob.efunc.events(i).copy;
  if ~isempty(copy)
    prob.efunc.events(i).evdata{i} = copy(prob, data);
  end
  if isa(data,'coco_func_data')
    objidx = union(objidx, data.getobjidx);
  end
end

for i=1:nafuncs
  data = prob.adjoint.funcs(i).data;
  fid  = prob.adjoint.funcs(i).identifyer; %#ok<NASGU> % for debugging only
  copy = prob.adjoint.funcs(i).copy;
  if ~isempty(copy)
    prob.adjoint.funcs(i).data = copy(prob, data);
  end
  if isa(data,'coco_func_data')
    objidx = union(objidx, data.getobjidx);
  end
end

all_funcs.ptrs = coco_func_data.pointers('copy', setdiff(objidx,0));

end
