function varargout = coco_get_slot_data(prob, signame, fid, varargin)

% Copyright (C) Harry Dankowicz
% $Id: coco_get_func_data.m 3258 2023-06-03 22:17:44Z hdankowicz $

slots     = prob.slots;
varargout = {};
if isfield(slots, signame)
  fidx = slots.(signame);
  fids = { slots.funcs(fidx).identifyer };
  idx  = find(strcmpi(fid, fids));
  if isempty(idx)
    error('%s: could not find function with identifyer ''%s''', mfilename, fid);
  else
    func = slots.funcs(fidx(idx));
    for oarg = 1:nargin-3
      switch lower(varargin{oarg})
        case 'data'  % function data structure
          if isa(func.data, 'coco_func_data')
            varargout = [ varargout { coco_func_data.loadobj(func.data.saveobj()) } ]; %#ok<AGROW>
          else
            varargout = [ varargout { func.data } ]; %#ok<AGROW>
          end
        otherwise
          error('%s: unknown function data field ''%s''', ...
            mfilename, varargin{oarg});
      end
    end
  end
else
  error('%s: could not find signal with name ''%s''', mfilename, signame);
end

end
