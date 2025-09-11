function fout=sco_gen(fun,name,debug)
%% Return function or its derivative stored in symbolical toolbox created fun
%
% *Inputs:*
%
% * |fun|: function name (or filename) of function created by sco_sym2funcs
% * |name|: if not present, |f| is returned, if char array or single cell with
% character, first derivative of |f| with respect to this argument is
% returned, if name is cell of length two, second derivative of |f| is
% returned. If name is numeric integer k then the directional derivative of
% order k is returned.
% * |debug|: if present assertions (which cost some time) are switched on
%
% If argument |name| is not present,
% |F=@(varargin)sco_gen(fun,varargin{:})| is returned, which can be used as
% an abbreviated call to |sco_gen|. E.g., |F('x')| is the same as
% |sco_gen(fun,'x')| after this initial call.
%
% number, format and names of arguments of functions can be checked with
% call |args=fun('argrange');|, which returns a struct |args|.
%
% *Outputs:* function handle |fout|,which can be called with the number and
% format of arguments indicated by |args|. At the moment only functions
% with column vector inputs and a single column vector output are
% supported. All functions are vectorized, such that, e.g.,
%
% * After |f=sco_gen(fun,'')|, |y=f(x,p)| has output |y| with
% |size(x,2)==size(p,2)| columns. Single-column expansion is enabled.
% 
% * After |df=sco_gen(fun,'x')|, |dy=df(x,p)| has output |dy| with
% |size(dy,2)==size(x,1)|, |size(dy,3)==size(x,2)==size(p,2)|.
%
% After |df2=sco_gen(fun,{'x','p'}|, |dy=df2(x,p)| has output |dy| with
% |size(dy,2)==size(x,1)|, |size(dy,3)==size(p,1)|,
% |size(dy,4)==size(x,2)==size(p,2)|.
%
% If ones of the input arguments has single column it will get expanded by repmat.
%
% Directional derivatives: if a '*' is present in any of the arguments of
% sco_gen then a directional derivative in this direction is returned. For
% example, after
% dfxvp=sco_gen(fun,{'x*v','p'}),dy=dfxvp(x,p,v) output dy has
% |size(dy,2)==size(p,1), |size(y,3)==max(size(x,2),size(p,2))|. It equals
% $\partial_{xp}f(x,p)v(.)$ where v is the deviation wrt x.
%%
maxorder=fun('maxorder');
if (nargin==3 && islogical(debug) && debug)||...
        (nargin==2&&ischar(name)&&strcmp(name,'_debug'))
    debug=true;
else
    debug=false;
end
if nargin<=1 || (nargin==2&&debug)
    fout=@(name)sco_gen(fun,name,debug);
elseif (ischar(name) && strcmp(name,'')) || ... % F('') is function
        (iscell(name) && isempty(name)) || ...  % or F({})
        (iscell(name) && ischar(name{1}) && isempty(name{1})) % or F({''})
    fmt=arg_preprocess_derivative(fun,0,debug);
    fout=@(varargin)dfdirprep(fun,fmt,varargin{:});
elseif isnumeric(name) && ismember(name,0:maxorder) % F(1), F(2),...
    fmt=arg_preprocess_derivative(fun,name,debug);
    fout=@(varargin)dfdirprep(fun,fmt,varargin{:});
elseif ischar(name) || (iscell(name)&&ischar(name{1})) % F('x'), F({'x'}), F({'w','p'}) 
    [args,ndirs]=assemble_directions(fun,name);
    fmt=arg_preprocess_derivative(fun,size(args,2),debug);
    fout=@(varargin)dfnamed(fun,args,ndirs,fmt,varargin{:});
elseif iscell(name) && length(name)==1 && isnumeric(name{1})
    fmt=arg_preprocess_derivative(fun,name{1},debug);
    fout=@(varargin)dfdir_wI(fun,fmt,varargin{:});
else    
    error('sco_gen:arg',['sco_gen: second argument ''name'' not',...
        'recognized, only derivatives up to order %d implemented'],maxorder);
end
end
%% wrapper for named partial derivatives, converting them to directional derivatives
function y=dfnamed(fun,args,ndirs,fmt,varargin)
nargs=size(args,1);
args(ndirs)=varargin(nargs+(1:length(ndirs)));
devargs=arrayfun(@(i)cat(2,args(i,:)),1:nargs,'UniformOutput',false);
[u0,udev,dims]=arg_expand_mixed_derivative(fmt,{varargin{1:nargs},devargs{:}}); %#ok<CCAT>
y=dfdir_wrap(fun,fmt,u0,udev,dims);
end
%% wrapper for directional derivatives, expanding directions indicated by 'I'
function y=dfdir_wI(fun,fmt,varargin)
devargs=varargin(fmt.nargs+1:end);
[u0,udev,dims]=arg_expand_mixed_derivative(fmt,{varargin{1:fmt.nargs},devargs{:}}); %#ok<CCAT>
y=dfdir_wrap(fun,fmt,u0,udev,dims);
end
%% wrapper for directional derivatives, expanding directions not provided
function y=dfdirprep(fun,fmt,varargin)
fargs=varargin(1:fmt.nargs);
devargs=varargin(fmt.nargs+1:end);
if isempty(devargs)
    devargs=repmat({},1,fmt.nargs);
end
[u0,udev,dims]=arg_expand_directional(fmt,fargs{1:fmt.nargs},devargs{:});
y=dfdir_wrap(fun,fmt,u0,udev,dims);
end
%% wrapper for directional derivatives of arbitrary order
function y=dfdir_wrap(fun,fmt,u0,udev,dims)
[n,nvec]=size(u0);
udev=reshape(udev,n*fmt.deg,nvec);
if fmt.deg==0
    y=fuwrap(fun,0,u0);
    return
end
nf=fun('nout');
cf=(dec2bin(2^(fmt.deg-1):2^fmt.deg-1)-'0')*2-1;
nfac=size(cf,1);
lfac=prod(cf,2)/factorial(fmt.deg)/2^(fmt.deg-1);
dev=kron(cf,eye(n))*udev;
dev=reshape(dev,n,nfac*nvec);
urep=reshape(repmat(u0,nfac,1),n,nfac*nvec);
yfac=fuwrap(fun,fmt.deg,urep,dev);
yfac=reshape(yfac,nf*nfac,nvec);
y=kron(lfac',eye(nf))*yfac;
if length(dims)>1
    y=full(y);
end
y=reshape(y,[nf,dims]);
end
%% Wrapper around automatically generated functions from symbolic differentiation
% converts numerical arrays into lists of scalar/vectorized arguments, as
% this is what the output from the symbolic toolbox produces.
function y=fuwrap(fun,order,u,du)
%% determine vectorized dimensions
[nu,nvec]=size(u);
nf=fun('nout');
ext=fun('extension');
if nargin<=3
    du=zeros(size(u));
end
mfrep=numel(du)/max(1,numel(u));
orep=ones(1,mfrep);
%% convert arrays to cells/argument lists in first 2 or 3 dimensions
for i=nu:-1:1
    uc{i}=u(i,:);
    duc{i}=reshape(du(i,:,orep),1,[]);
end
out=cell(1,nf);
[out{:}]=fun(ext,order,uc{:},duc{:});
%% The ith row gets either filled in or expanded
y=NaN(nf,nvec);
for i=nf:-1:1
    y(i,:)=out{i};
end
end
%% 
