function [fmt,err,fhandle,pairs]=sco_compare(y,args,names,isvector,dby,varargin)
default={'newf','tmp'};
[opts,pass_on]=sco_set_options(default,varargin,'pass-on');
[dyp,var,dvar,~,~,dim]=simple_symderiv(y,args,names,'dby',dby,'vector',isvector);
[fn,pairs]=multi_subs(dyp,var,dvar,'dim',dim,pass_on{:});
if ischar(opts.newf)
    sco_sym2funcs(y,args,names,'filename',[opts.newf,'.m'],'vector',isvector,pass_on{:});
    fhandle=@(varargin)feval(opts.newf,varargin{:});
else
    fhandle=opts.newf;
end
F=sco_gen(fhandle);
df=F(dby);
fn_sco=df(pairs{2,:});
fmt={size(fn),size(fn_sco)};
assert(length(fmt{1})==length(fmt{2})&&all(fmt{1}==fmt{2}));
err=max(abs(fn-fn_sco),[],'all');
end