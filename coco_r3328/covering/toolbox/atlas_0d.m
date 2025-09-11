classdef atlas_0d < AtlasBase
  
  properties
    cont       = struct()
    base_chart = struct()
  end
  
  methods % constructor
    
    function atlas = atlas_0d(prob, cont, dim)
      assert(dim==0, '%s: wrong manifold dimension dim=%d, expected dim=0', ...
        mfilename, dim);
      atlas      = atlas@AtlasBase(prob);
      atlas.cont = atlas.get_settings(cont);
    end
    
  end
  
  methods (Static=true, Access = private)
    
    function cont = get_settings(cont)
      defaults.NAdapt    =  0; % perform NAdapt remesh->correct cycles
      defaults.RMMX      = 10; % maximum number of remesh loops
      cont = coco_merge(defaults, cont);
    end
    
  end
  
  methods (Static=true) % static construction method
    
    function [prob, cont, atlas] = create(prob, cont, dim)
      atlas = atlas_0d(prob, cont, dim);
      cont  = atlas.cont;
      prob  = coco_add_signal(prob, 'remesh', mfilename);
    end
    
  end
  
  methods % interface methods
    
    function [prob, atlas, cseg, correct] = init_prcond(atlas, prob, chart)
      chart.R       = 0;
      chart.pt      = -1;
      chart.pt_type = 'IP';
      chart.ep_flag = 1;
      cseg          = CurveSegmentBase(prob, chart, true);
      % regularize, if necessary
      [prob, chart, J] = prob.efunc.DFDX(prob, chart, chart.x); %#ok<ASGLU>
      [m, n] = size(J);
      if m>n
        [L, U, P]  = lu(J); %#ok<ASGLU>
        Y  = L(1:n, 1:n)' \ L(n+1:end, 1:n)';
        B(:,1:m-n) = P'*[Y; -speye(m-n)];
        cseg.curr_chart.NV = orth(full(B));
      end
      correct       = true;
      prob = coco_add_signal(prob, 'update', mfilename); % Harry added
    end
    
    function [prob, atlas, cseg, flush] = init_atlas(atlas, prob, cseg)
      chart         = cseg.curr_chart;
      chart.pt      = 0;
      chart.pt_type = 'EP';
      chart.ep_flag = 1;
      [prob, chart, chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist   = { chart };
      flush         = true;
    end
    
    function [prob, atlas, cseg] = flush(atlas, prob, cseg)
      [prob, atlas, cseg] = atlas.flush@AtlasBase(prob, cseg, 'all');
      if cseg.Status == cseg.CurveSegmentOK
        atlas.base_chart = cseg.ptlist{end};
        if atlas.base_chart.pt>=atlas.cont.NAdapt
          cseg.Status = cseg.BoundaryPoint;
        end
      end
    end
    
    function [prob, atlas, cseg, flush] = add_chart(atlas, prob, cseg)
      chart    = cseg.curr_chart;
      chart.pt = chart.pt + 1;
      if chart.pt >= atlas.cont.NAdapt
        chart.pt_type = 'EP';
        chart.ep_flag = 1;
      end
      [prob, chart, chart.p] = prob.efunc.monitor_F(prob, chart, chart.x, chart.t);
      cseg.ptlist = { chart };
      flush       = true;
    end
    
    function [prob, atlas, cseg, correct] = predict(atlas, prob, cseg) %#ok<INUSD>
      chart = atlas.base_chart;
      
      % remesh base chart of new curve segment
      x0              = chart.x;
      [prob, chart, x0] = coco_remesh(prob, chart, x0, [], atlas.cont.RMMX);
      chart.x         = x0;
      
      % construct new curve segment
      cseg    = CurveSegmentBase(prob, chart, false);
      prob    = coco_emit(prob, 'update', cseg); % Harry added
      correct = true;
    end
    
  end
  
end
