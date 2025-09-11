function [dyp,var,dvar,dy,fs,dim]=simple_symderiv(f,args,names,varargin)
default={'dby',[],'vector',true(1,length(args))};
opts=sco_set_options(default,varargin,'pass-on');
if ischar(names)
    names=names{1};
end
if isempty(opts.dby)
    opts.dev=cell(1,length(opts.dby));
end
stars=strfind(opts.dby,'*');
isdirectional=~cellfun(@isempty,stars);
dev=repmat({''},1,length(opts.dby));
dev(isdirectional)=cellfun(@(s,pos)s(pos+1:end),...
    opts.dby(isdirectional),stars(isdirectional),'UniformOutput',false);
opts.dby(isdirectional)=cellfun(@(s,pos)s(1:pos-1),...
    opts.dby(isdirectional),stars(isdirectional),'UniformOutput',false);
dby=cellfun(@(s)find(strcmp(s,names)),opts.dby);
for i=length(names):-1:1
    sz{i}=size(args{i});
    var{i}=sym(names{i},sz{i});
end
dvar=cell(1,length(dev));
for k=length(dev):-1:1
    if ~isempty(dev{k})
        dvar{k}=sym(dev{k},sz{dby(k)});
    end
end
fs=fsubs(f,args,var);
dim=NaN(1,length(dby));
dim(1)=length(fs);
j=1;
for k=1:length(dby)
    fs=jacobian(fs,var{dby(k)});
    if isdirectional(k)
        fs=fs*dvar{k};
    elseif opts.vector(dby(k))
        j=j+1;
        dim(j)=size(fs,2);
    end
    fs=fs(:);
end
dim=dim(1:j);
if j>1
    dyp=reshape(fs,dim(1:j));
else
    dyp=fs;
end
dy=fsubs(dyp,var,args);
end
function fs=fsubs(f,var1,var2)
fs=f;
for i=1:numel(var1)
    fs=subs(fs,var1{i},var2{i});
end
end