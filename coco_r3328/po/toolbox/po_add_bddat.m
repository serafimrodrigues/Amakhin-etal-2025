function prob = po_add_bddat(prob, oid, labels, fhan, varargin)
no_utils = 0;
if isfield(prob, 'slots')
  for i=1:numel(prob.slots.funcs)
    fid = prob.slots.funcs(i).identifyer;
    if length(fid)>length(oid)+8 && strcmpi(fid(1:length(oid)+8), ...
        coco_get_id(oid,'utils.po'))
      no_utils = no_utils + 1;
    end
  end
end
fid = coco_get_id(oid, sprintf('utils.po%d', no_utils+1));
if ischar(labels)
  labels = {labels};
end
data = struct('fhan', fhan, 'labels', {labels}, 'oid', oid, 'data', [], ...
  'sn', false, 'pd', false, 'tr', false);
argidx = 1;
while argidx<=nargin-4
  oarg   = varargin{argidx};
  argidx = argidx + 1;
  oname  = lower(oarg);
  switch oname
    
    case 'data'
      data.data = varargin{argidx};
      argidx = argidx + 1;
      
    case 'sn'
      data.sn = true;
      
    case 'pd'
      data.hb = true;
      
    case 'tr'
      data.var = true;
      
    otherwise
      if ischar(oarg)
        error('%s: option ''%s'' not recognised', mfilename, oarg);
      else
        error('%s: in argument %d: expected string, got a ''%s''', ...
          mfilename, 1+argidx, class(oarg));
      end
      
  end
end
prob = coco_add_slot(prob, fid, @bddat, data, 'bddat');
prob = coco_add_slot(prob, fid, @print, data, 'cont_print');
end

function [data, res] = bddat(prob, data, command, varargin)

switch command
  case 'init'
    res = data.labels;
  case 'data'
    chart = varargin{1};
    tbid = coco_get_id(data.oid, 'po.orb.coll');
    [fdata, uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
    maps = fdata.coll_seg.maps;
    upo = chart.x(uidx);
    xbp = upo(maps.xbp_idx);
    T0  = upo(maps.T0_idx);
    T   = upo(maps.T_idx);
    p   = upo(maps.p_idx);
    data.data.coll_seg = fdata.coll_seg;
    res = data.fhan(data.data, xbp, T0, T, p);
end

end

function data = print(prob, data, command, LogLevel, varargin)

switch command
  case 'init'
    for i=1:numel(data.labels)
      coco_print(prob, LogLevel, '%12s', data.labels{i});
    end
  case 'data'
    chart = varargin{1};
    tbid = coco_get_id(data.oid, 'po.orb.coll');
    [fdata, uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
    maps = fdata.coll_seg.maps;
    upo = chart.x(uidx);
    xbp = upo(maps.xbp_idx);
    T0  = upo(maps.T0_idx);
    T   = upo(maps.T_idx);
    p   = upo(maps.p_idx);
    data.data.coll_seg = fdata.coll_seg;
    res = data.fhan(data.data, xbp, T0, T, p);
    if iscell(res)
      for i=1:numel(res)
        coco_print(prob, LogLevel, '%12.4e', res{i}(1));
      end
    else
      coco_print(prob, LogLevel, '%12.4e', res(1));
    end
end

end
