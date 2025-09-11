function prob = coco_copy_prob(oldprob)

prob = oldprob;

if isfield(prob, 'efunc')
  nefuncs = numel(prob.efunc.funcs);
  if isfield(prob.efunc, 'events')
    nhfuncs = numel(prob.efunc.events);
  else
    nhfuncs = 0;
  end
else
  nefuncs = 0;
  nhfuncs = 0;
end
if isfield(prob, 'adjoint')
  nafuncs = numel(prob.adjoint.funcs);
else
  nafuncs = 0;
end
if isfield(prob, 'slots')
  nsfuncs = numel(prob.slots.funcs);
else
  nsfuncs = 0;
end

% call toolbox data copy functions

objidx = [];
data_array = {};

for i=1:nefuncs
  data = prob.efunc.funcs(i).data;
  fid  = prob.efunc.funcs(i).identifyer; %#ok<NASGU> % for debugging only
  copy = prob.efunc.funcs(i).copy;
  if ~isempty(copy)
    prob.efunc.funcs(i).data = copy(prob, data);
  end
  if isa(data,'coco_func_data')
    from = data.getobjidx;
    idx = find(objidx==from, 1, 'first');
    if ~isempty(idx)
      prob.efunc.funcs(i).data = data_array{idx};
    else
      data = coco_func_data(data.loadobj(data.saveobj()));
      prob.efunc.funcs(i).data = data;
      objidx = [objidx; from]; %#ok<AGROW>
      data_array = [data_array {data}]; %#ok<AGROW>
    end
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
    from = data.getobjidx;
    idx = find(objidx==from, 1, 'first');
    if ~isempty(idx)
      prob.slots.funcs(i).data = data_array{idx};
    else
      data = coco_func_data(data.loadobj(data.saveobj()));
      prob.slots.funcs(i).data = data;
      objidx = [objidx; from]; %#ok<AGROW>
      data_array = [data_array {data}]; %#ok<AGROW>
    end
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
    from = data.getobjidx;
    idx = find(objidx==from, 1, 'first');
    if ~isempty(idx)
      prob.efunc.events(i).data = data_array{idx};
    else
      data = coco_func_data(data.loadobj(data.saveobj()));
      prob.efunc.events(i).data = data;
      objidx = [objidx; from]; %#ok<AGROW>
      data_array = [data_array {data}]; %#ok<AGROW>
    end
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
    from = data.getobjidx;
    idx = find(objidx==from, 1, 'first');
    if ~isempty(idx)
      prob.adjoint.funcs(i).data = data_array{idx};
    else
      data = coco_func_data(data.loadobj(data.saveobj()));
      prob.adjoint.funcs(i).data = data;
      objidx = [objidx; from]; %#ok<AGROW>
      data_array = [data_array {data}]; %#ok<AGROW>
    end
  end
end

end
