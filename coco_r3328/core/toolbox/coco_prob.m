function prob_new = coco_prob(prob)
%COCO_PROB   Initialize COCO continuation problem structure.
%
% COCO_PROB([PROB])
%
% creates a new continuation problem structure if the optional argument
% PROB is absent and a copy of the continuation problem structure PROB
% otherwise.

if nargin<1
  prob_new = new_prob();
else
  assert(isfield(prob, 'opts') && isa(prob.opts, 'coco_opts_tree'), ...
    '%s: %s', 'argument must be a continuation problem structure', ...
    mfilename);
  prob_new = coco_copy_prob(prob);
end

end

function prob = new_prob()
prob = struct();
prob.opts = coco_opts_tree();
prob.opts = prob.opts.prop_set('', '', global_default_opts());
prob = read_global_user_opts(prob);
prob = read_project_user_opts(prob);
end

function opts = global_default_opts()
opts.TOL       = 1.0e-6; % overall tolerance for algorithms
opts.CleanData = false ; % clean destination directory prior to computation
opts.LogLevel  = 1     ; % general log level
opts.data_dir  = fullfile(pwd, 'data'); % default location for saving data
end

function prob = read_global_user_opts(prob)
if any(exist('coco_global_opts', 'file') == [2 3 6])
  f = which('coco_global_opts');
  p = fileparts(which('coco'));
  if strncmp(p,f,numel(p))
    prob = coco_global_opts(prob);
  else
    coco_warn(prob, 1, 1, ...
      '%s: %s%s\n%s: ''%s''\n%s\n', ...
      mfilename, 'global user settings shadowed ', ...
      'by a function not in the coco root folder', ...
      'shadow is', f, 'coco_global_opts not executed');
  end
end
end

function prob = read_project_user_opts(prob)
if any(exist('coco_project_opts', 'file') == [2 3 6])
  f = which('coco_project_opts');
  p = userpath;
  if strncmp(p,f,numel(p))
    prob = coco_project_opts(prob);
  else
    coco_warn(prob, 1, 1, ...
      '%s: %s%s\n%s: ''%s''\n%s\n', ...
      mfilename, 'project user settings shadowed ', ...
      'by a function not in the userpath', ...
      'shadow is', f, 'coco_project_opts not executed');
  end
end
end
