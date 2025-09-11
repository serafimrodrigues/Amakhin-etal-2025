function fout=sco_gen(fun,name)
%% Return function or its derivative stored in symbolical toolbox created fun
%
% *Inputs:*
%
% * |fun|: function name (or filename) of function created by sco_sym2funcs
% * |name|: if empty, |f| is returned, if char array or single cell with
% character, first derivative of |f| with respect to this argument is
% returned, if name is cell of length two, second derivative of |f| is
% returned. If name is numeric integer k then the directional derivative of
% order k is returned.
%
% If argument |name| is not present,
% |F=@(varargin)sco_gen(fun,varargin{:})| is returned, which can be used as
% an abbreviated call to |sco_gen|. E.g., |F('x')| is the same as
% |sco_gen(fun,'x')| after this initial call.
%
% number, format and names of arguments of functions can be checked with
% call |args=fun('args');|, which returns a struct |args|.
%
% *Outputs:* function handle |fout|,which can be called with the number and
% format of arguments indicated by |args|. At the moment only functions
% with column vector inputs and a single column vector output are
% supported. All functions are vectorized, such that, e.g.,
%
% * After |f=sco_gen(fun,'')|, |y=f(x,p)| has output |y| with
% |size(x,2)==size(p,2)| columns.
% 
% * After |df=sco_gen(fun,'x')|, |dy=df(x,p)| has output |dy| with
% |size(dy,2)==size(x,1)|, |size(dy,3)==size(x,2)==size(p,2)|.
%
% After |df2=sco_gen(fun,{'x','p'}|, |dy=df2(x,p)| has output |dy| with
% |size(y,2)==size(x,1)|, |size(y,3)==size(p,1)|,
% |size(y,4)==size(x,2)==size(p,2)|.
%
% If ones of the input arguments has ewer columns than others (e.g., single
% column), it will get expanded by repmat.
%%
maxorder=fun('maxorder');
if nargin<=1
    fout=@(varargin)sco_gen_orig(fun,varargin{:});
elseif ischar(name) && strcmp(name,'')
    fout=@(varargin)f_wrap(fun,varargin{:});
elseif ischar(name) && isvarname(name)
    fout=@(varargin)df_wrap(fun,name,varargin{:});
elseif iscell(name) && length(name)==1
    fout=@(varargin)df_wrap(fun,name{1},varargin{:});
elseif iscell(name) && length(name)==2
    fout=@(varargin)d2f_wrap(fun,name,varargin{:});
elseif isnumeric(name) && ismember(name,0:maxorder)
    fout=@(varargin)dfdir_wrap(fun,name,varargin{:});
else    
    error('sco_gen:arg',['sco_gen: second argument ''name'' not',...
        'recognized, only full derivatives up to order 2\n',...
        'and directional derivatives up to order %d implemented'],maxorder);
end
end
%% wrapper for simple function call
function y=f_wrap(fun,varargin)
u=arg_expand_full_derivative(fun,varargin);
y=fuwrap(fun,0,u);
end
%% wrapper for directional derivatives of arbitrary order
function y=dfdir_wrap(fun,deg,varargin)
[u0,udev,dims]=arg_expand_mixed_derivative(fun,deg,varargin);
[n,nvec]=size(u0);
udev=reshape(udev,n*deg,nvec);
if deg==0
    y=fuwrap(fun,0,u0);
    return
end
nf=fun('nout');
cf=(dec2bin(2^(deg-1):2^deg-1)-'0')*2-1;
nfac=size(cf,1);
lfac=prod(cf,2)/factorial(deg)/2^(deg-1);
dev=kron(cf,speye(n))*udev;
dev=reshape(dev,n,nfac*nvec);
urep=reshape(repmat(u0,nfac,1),n,nfac*nvec);
yfac=fuwrap(fun,deg,urep,dev);
yfac=reshape(yfac,nf*nfac,nvec);
y=kron(lfac',speye(nf))*yfac;
y=reshape(y,[nf,dims]);
end
%% wrapper for Jacobian, assembling directional derivatives to produce full matrix
function y=df_wrap(fun,name,varargin)
u=arg_expand_full_derivative(fun,varargin);
iargsize=fun('argrange');
iargvec=fun('vector');
nf=fun('nout');
[nu,nvec]=size(u);
devrg=iargsize.(name);
isvec=iargvec.(name);
ndev=length(devrg);
urep=reshape(repmat(u,ndev,1),nu,[]);
durep=zeros(nu,ndev*nvec);
durep(devrg,:)=reshape(repmat(eye(ndev),1,1,nvec),ndev,[]);
y=fuwrap(fun,1,urep,durep);
dims=[nf,ndev,nvec];
dims=dims([true,logical(isvec),true]);
y=reshape(y,dims);
end
%% wrapper for Hessian, assembling directional derivatives to produce full tensor
function y=d2f_wrap(fun,name,varargin)
u=arg_expand_full_derivative(fun,varargin);
iargsize=fun('argrange');
iargvec=fun('vector');
nf=fun('nout');
[nu,nvec]=size(u);
devrg={iargsize.(name{1}),iargsize.(name{2})};
isvec=[iargvec.(name{1}),iargvec.(name{2})];
ndev=[length(devrg{1}),length(devrg{2})];
nrep=ndev(1)*ndev(2);
urep=reshape(repmat(u,nrep,1),nu,[]);
du{1}=repmat(eye(ndev(1)),1,ndev(2)*nvec);
du{2}=reshape(repmat(eye(ndev(2)),ndev(1),1),ndev(2),[]);
du{2}=repmat(du{2},1,nvec);
durep{1}=zeros(nu,nrep*nvec);
durep{2}=durep{1};
durep{1}(devrg{1},:)=du{1};
durep{2}(devrg{2},:)=du{2};
yp=fuwrap(fun,2,urep,durep{1}+durep{2});
ym=fuwrap(fun,2,urep,durep{1}-durep{2});
y=0.25*(yp-ym);
dims=[nf,ndev,nvec];
dims=dims([true,logical(isvec),true]);
y=reshape( y,dims);
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
mfrep=numel(du)/numel(u);
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
%% check and expand arguments in second dimension if necessary and possible
% collect them into single argument vector
function u=arg_expand_full_derivative(fun,args)
%% check args number
nargs=fun('nargs');
assert(nargs==numel(args),'sco_gen:args',...
    'sco_gen: number of arguments given, %d, different from expected: %d',...
    numel(args),nargs);
%% check args size
argsz=fun('argsize');
s1=cellfun(@(x)size(x,1),args);
s2=cellfun(@(x)size(x,2),args);
assert(all(s1(:)==reshape(cell2mat(struct2cell(argsz)),[],1)),...
    'sco_gen:args',...
    'sco_gen: size of arguments should be\n%s\nbut is\n%s',...
    evalc('disp(argsz)'),num2str(s1));
%% check if scalar declaration is consistent
argvec=fun('vector');
assert(all(s1(:)==1 | reshape(cell2mat(struct2cell(argvec)),[],1)),...
    'sco_gen:args',...
    ['sco_gen: non-scalar arguments declared not declared as vector\n',...
    'declared:\n%s\nsize:\n%s'],...
    evalc('disp(argvec)'),evalc('disp(argsz)'));
%% expand if necessary
ms2=max(s2);
s_exp=max(s2)./s2;
assert(all(mod(s_exp,1)==0),'sco_gen:args',...
    'sco_gen: second argument dimensions:\n%s\nnot expandable',s2);
xargs=cellfun(@(x,i)reshape(x(:,:,ones(i,1)),[],ms2),...
    args,num2cell(s_exp),'uniformoutput',false);
%% concatenate
u=vertcat(xargs{:});
end
%% 
function [u0,udev,dims]=arg_expand_mixed_derivative(fun,deg,args)
%% check args number
nargs=fun('nargs');
argsexp=(1+(deg>0))*nargs;
assert((deg==0&& numel(args)==nargs) || (deg>0 && numel(args)==2*nargs),...
    'sco_gen:args',...
    'sco_gen: number of arguments given, %d, different from expected: %d',...
    numel(args),argsexp);
u0args=args(1:nargs);
udevargs=args(nargs+1:end);
udevcell=cellfun(@iscell,udevargs);
assert(deg<2||all(udevcell),'sco_gen:args',...
    'sco_gen: directional derivative of degree>1, but deviations are not grouped in 1xdeg cells');
assert(deg<2||all(cellfun(@length,udevargs)==deg),...
    'sco_gen:args',...
    'sco_gen: directional derivative of degree=%d>1,\n but number of deviations ',...
    'provided for each argument are %s',deg,num2str(cellfun(@length,udevargs)));
%% reshape args into rectangular deg x nargs cel array
udevargs(~udevcell)=cellfun(@(x){{x}},udevargs(~udevcell));
udevargs=cellfun(@(x)reshape(x,1,[]),udevargs,'UniformOutput',false);
fargs=u0args(:);
devargs=cat(1,udevargs{:});
%% check correctness of format: column lengths
argsize_exp=reshape(cell2mat(struct2cell(fun('argsize'))),1,[]);
fargsize_prov=reshape(cellfun(@(x)size(x,1),fargs),1,[]);
%% function arguments have to have exact column length
assert(all(argsize_exp==fargsize_prov),'sco_gen:args',...
    'sco_gen: function args should have length %s bu have length %s',...
    num2str(argsize_exp),num2str(fargsize_prov))
if isempty(devargs)
    devargs=cell(nargs,0);
end
%% among deviations detect 'I' and 0 and expand column length to full argsize 
% (replacing 'I' with NaN)
isid=cellfun(@(x)ischar(x)&&strcmp(x,'I'),devargs);
is0=cellfun(@(x)isnumeric(x)&&numel(x)==1&&x==0,devargs);
assert(all(sum(isid,1)<=1),'sco_gen:args',...
    'sco_gen: at most one deviation can be ''I'' per degree')
assert(all(sum(isid,1)==0|sum(isid+is0,1)==nargs),'sco_gen:args',...
    'sco_gen: if one deviation is ''I'' all others must be 0');
devargsize_exp=repmat(argsize_exp(:),1,deg);
devargs(isid)=arrayfun(@(sz)NaN(sz,1),devargsize_exp(isid),'UniformOutput',false);
devargs(is0)=arrayfun(@(sz)zeros(sz,1),devargsize_exp(is0),'UniformOutput',false);
devargsize_prov=cellfun(@(x)size(x,1),devargs);
assert(all(devargsize_exp==devargsize_prov,'all'),'sco_gen:args',...
    'sco_gen: function args should have length %s but have length %s',...
    num2str(devargsize_exp),num2str(devargsize_prov))
%% manual vectorization singleton expansion
args=cat(2,fargs,devargs);
argsnvec=cellfun(@(x)size(x,2),args);
nvec=max(argsnvec(:));
assert(all(argsnvec==1|argsnvec==nvec,'all'),'sco_gen:args',...
    'sco_gen: all arguments must have same column dimension or single column');
args=cellfun(@(x,i)repmat(x,1,i),args,num2cell(nvec./argsnvec),'UniformOutput',false);
vec_expand=@(y,n)reshape(repmat(reshape(y,size(y,1),1,size(y,2)),1,n,1),size(y,1),[]);
id_create=@(y)reshape(repmat(eye(size(y,1)),1,1,size(y,2)),size(y,1),[]);
isidall=cat(2,false(nargs,1),isid);
n_id=find(isidall);
dims=[NaN(1,length(n_id)),nvec];
for i=length(n_id):-1:1
    [ir,~]=ind2sub(size(isidall),n_id(i));
    dims(i)=argsize_exp(ir);
    args{n_id(i)} =id_create(args{n_id(i)});
    iother=setdiff(1:numel(isidall),n_id(i));
    args(iother)=cellfun(@(y)vec_expand(y,dims(i)),args(iother),...
        'UniformOutput',false);
end
u0=cat(1,args{:,1});
[nargs_all,nvec_all]=size(u0);
udev=arrayfun(@(i)cat(1,args{:,i+1}),1:deg,'UniformOutput',false);
udev=reshape(cat(1,udev{:}),nargs_all,deg,nvec_all);
end
%%
function [u0,udev]=arg_expand_directional_derivative(fun,deg,args)
%% check args number
nargs=fun('nargs');
assert((deg==0&& numel(args)==nargs) || (deg>0 && numel(args)==2*nargs),...
    'sco_gen:args',...
    'sco_gen: number of arguments given, %d, different from expected: %d',...
    numel(args),nargs);
u0args=args(1:nargs);
udevargs=args(nargs+1:end);
%% check u0args size
s_argsz=fun('argsize');
argsz=cell2mat(struct2cell(s_argsz));
s10=cellfun(@(x)size(x,1),u0args);
s20=cellfun(@(x)size(x,2),u0args);
assert(all(s10(:)==reshape(argsz,[],1)),...
    'sco_gen:args',...
    'sco_gen: sizes of arguments should be\n%s\nbut is\n%s',...
    evalc('disp(s_argsz)'),num2str(s10));
%% determine argument column lengths
s2d=ones(deg,nargs);
for i=1:length(udevargs)
    if ~iscell(udevargs{i})
        s2d(:,i)=size(udevargs{i},2);
        assert(size(udevargs{i},1)==argsz(i),'sco_gen:args',...
            'sco_gen: size of arguments %d should be %d but is %d.',...
            nargs+i,argsz(i),size(udevargs{i},1));
        udevargs{i}=repmat(udevargs(i),1,deg);
    elseif length(udevargs{i})~=deg
        assert(length(udevargs{i})==1,'sco_gen:args',['sco_gen: argument %d',...
            'should have length 1 or %d'],nargs+i,deg);
        s2d(:,i)=size(udevargs{i}{1},2);
        assert(size(udevargs{i}{1},1)==argsz(i),'sco_gen:args',...
            'sco_gen: size of arguments %d should be %d but is %d.',...
            nargs+i,argsz(i),size(udevargs{i}{1},1));
        udevargs{i}=repmat(udevargs{i},1,deg);        
    else
        s2d(:,i)=cellfun(@(x)size(x,2),udevargs{i});
        s1d=cellfun(@(x)size(x,1),udevargs{i});
        assert(all(s1d(:)==argsz(i)),'sco_gen:args',...
            'sco_gen: size of arguments in arg %d should be %d but is %s.',...
            nargs+i,argsz(i),num2str(s1d));
    end
end
nvec=max([s20(:)',s2d(:)']);
nexp0=nvec./s20;
nexpd=nvec./s2d;
assert(all(mod(nexp0,1)==0) && all(mod(nexpd(:),1)==0),'sco_gen:args',...
    'sco_gen: size(arg,2) of arguments such that they are not expandable');
u0xargs=cellfun(@(x,i)reshape(x(:,:,ones(i,1)),[],nvec),...
    u0args,num2cell(nexp0),'uniformoutput',false);
u0=vertcat(u0xargs{:});
udev=NaN(size(u0,1),deg,nvec);
udrg=struct2cell(fun('argrange'));
for i=1:length(udevargs)
    udxargs=cellfun(@(x,j)reshape(x(:,:,ones(j,1)),argsz(i),nvec),...
        udevargs{i},num2cell(nexpd(:,i))','uniformoutput',false);
    udev(udrg{i},:,:)=reshape(vertcat(udxargs{:}),argsz(i),deg,nvec);
end
end
