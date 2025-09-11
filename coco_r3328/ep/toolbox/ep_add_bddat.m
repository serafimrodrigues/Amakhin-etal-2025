function prob = ep_add_bddat(prob, oid, labels, fhan, varargin)
no_utils = 0;
if isfield(prob, 'slots')
  for i=1:numel(prob.slots.funcs)
    fid = prob.slots.funcs(i).identifyer;
    if length(fid)>length(oid)+8 && strcmpi(fid(1:length(oid)+8), ...
        coco_get_id(oid,'utils.ep'))
      no_utils = no_utils + 1;
    end
  end
end
fid = coco_get_id(oid, sprintf('utils.ep%d', no_utils+1));
if ischar(labels)
  labels = {labels};
end
data = struct('fhan', fhan, 'labels', {labels}, 'oid', oid, 'data', [], ...
  'sn', false, 'hb', false);
argidx = 1;
while argidx<=nargin-4
  oarg   = varargin{argidx};
  argidx = argidx + 1;
  oname  = lower(oarg);
  switch oname
    
    case 'data'
      data.data = varargin{argidx};
      argidx = argidx + 1;
      
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
    tbid = coco_get_id(data.oid, 'ep');
    [fdata, uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
    ep_eqn = fdata.ep_eqn;
    x = chart.x(uidx(ep_eqn.x_idx));
    p = chart.x(uidx(ep_eqn.p_idx));
    data.data.ep_eqn = ep_eqn;
    res = data.fhan(data.data, x, p);
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
    tbid = coco_get_id(data.oid, 'ep');
    [fdata, uidx] = coco_get_func_data(prob, tbid, 'data', 'uidx');
    ep_eqn = fdata.ep_eqn;
    x = chart.x(uidx(ep_eqn.x_idx));
    p = chart.x(uidx(ep_eqn.p_idx));
    data.data.ep_eqn = ep_eqn;
    res = data.fhan(data.data, x, p);
    if iscell(res)
      for i=1:numel(res)
        coco_print(prob, LogLevel, '%12.4e', res{i}(1));
      end
    else
      coco_print(prob, LogLevel, '%12.4e', res(1));
    end
end

end
