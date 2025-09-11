function varargout=sym_bistable(action,varargin)
%% Automatically generated with matlabFunction
%#ok<*DEFNU,*INUSD,*INUSL>

switch action
  case 'nargs'
   varargout{1}=3;
   return
  case 'nout'
   varargout{1}=2;
   return
  case 'argrange'
   varargout{1}=struct('t',1:1,'x',2:3,'p',4:6);
   return
  case 'argsize'
   varargout{1}=struct('t',1,'x',2,'p',3);
   return
  case 'vector'
   varargout{1}=struct('t',0,'x',1,'p',1);
   return
  case 'extension'
   varargout{1}='rhs';
   return
  case 'maxorder'
   varargout{1}=3;
   return
end
nout=2;
order=varargin{1};
f=str2func(sprintf('sym_bistable_%s_%d',action,order));
varargout=cell(nout,1);
[varargout{:}]=f(varargin{2:end});
end


