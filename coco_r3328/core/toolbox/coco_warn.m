function coco_warn(prob, prio, LogLevel, varargin)

assert(isfield(prob, 'opts') && isa(prob.opts, 'coco_opts_tree'), ...
  '%s: %s', 'argument must be a continuation problem structure', ...
  mfilename);

if isfield(prob, 'run')
  run      = prob.run;
  LogLevel = max(run.logPrioMN, LogLevel(1));
  fprintf(run.loghan, '\nwarning: ');
  fprintf(run.loghan, varargin{:});
end

if prio<=LogLevel(1)
  fprintf(2, '\nwarning: ');
  fprintf(2, varargin{:});
end

end
