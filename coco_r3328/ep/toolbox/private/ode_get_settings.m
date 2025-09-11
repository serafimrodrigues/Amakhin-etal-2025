function [ode, spec] = ode_get_settings(prob, tbid, ode)
%ODE_GET_SETTINGS   Merge ODE toolbox family settings with default values.

% Copyright (C) Frank Schilder, Harry Dankowicz
% $Id: ode_get_settings.m 3288 2023-07-01 16:43:41Z hdankowicz $

spec = {% Name    Type   Default  Action  Args  Description
  'vectorized', 'log|on',  true, 'switch', {}, 'enable/disable vectorized evaluation'
  'autonomous', 'log|on',  true, 'switch', {}, 'indicate whether ODE is autonomous or not'
       'hfac1',    'num',  1e-8,   'read', {}, 'first-order finite-difference step size'
       'hfac2',    'num',  1e-4,   'read', {}, 'second-order finite-difference step size'
  };

ode = coco_parse_settings(prob, spec, ode, tbid);

end
