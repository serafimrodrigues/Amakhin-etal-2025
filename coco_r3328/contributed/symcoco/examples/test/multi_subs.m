function [fnum,pairs]=multi_subs(f,var,dvar,varargin)
default={'seed',[],'nvec',2,'dim',NaN};
opts=sco_set_options(default,varargin,'pass_on');
if ~isempty(opts.seed)
    rng(opts.seed)
end
fnum=f;
dvar=dvar(cellfun(@(s)~isempty(s),dvar));
allvar=[var,dvar];
for k=length(allvar):-1:1
    values{k}=rand(size(allvar{k}));
    if mod(k,2)
        values{k}(:,1+(1:opts.nvec-1))=rand(size(allvar{k},1),opts.nvec-1);
    end
end
pairs=cat(1,allvar(:)',values(:)');
if ~isnan(opts.dim)
    sz=opts.dim;
else
    sz=size(fnum);
    if length(sz)==2&&sz(2)==1
        sz=sz(1);
    end
end
fnum=fnum(:);
fnum=repmat(fnum,1,opts.nvec);
for i=1:size(values,2)
    lvec=size(values{i},2);
    for k=1:opts.nvec
        fnum(:,k)=subs(fnum(:,k),allvar{i},values{i}(:,min(k,lvec)));
    end
end
fnum=reshape(fnum,[sz,opts.nvec]);
fnum=double(fnum);
end
