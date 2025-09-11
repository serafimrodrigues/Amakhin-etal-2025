function [u0,udev,dims]=arg_expand_mixed_derivative(fmt,args)
%% check args number and format  for directional derivatives
% directional derivatives may contain 'I' or 0 to expand to full tensor
if fmt.debug
    assert((fmt.deg==0&& numel(args)==fmt.nargs) || (fmt.deg>0 && numel(args)==2*fmt.nargs),...
        'sco_gen:args',...
        'sco_gen: number of arguments given, %d, different from expected: %d',...
        numel(args),fmt.args_exp);
end
u0args=args(1:fmt.nargs);
udevargs=args(fmt.nargs+1:end);
udevcell=cellfun(@iscell,udevargs);
if fmt.debug
    assert(fmt.deg<2||all(udevcell),'sco_gen:args',...
        'sco_gen: directional derivative of degree>1, but deviations are not grouped in 1xdeg cells');
    assert(fmt.deg<2||all(cellfun(@length,udevargs)==fmt.deg),...
        'sco_gen:args',...
        'sco_gen: directional derivative of degree=%d>1,\n but number of deviations ',...
        'provided for each argument are %s',fmt.deg,num2str(cellfun(@length,udevargs)));
end
%% reshape args into rectangular deg x nargs cell array
udevargs(~udevcell)=cellfun(@(x){{x}},udevargs(~udevcell));
udevargs=cellfun(@(x)reshape(x,1,[]),udevargs,'UniformOutput',false);
fargs=u0args(:);
devargs=cat(1,udevargs{:});
%% check correctness of format: column lengths
fargsize_prov=reshape(cellfun(@(x)size(x,1),fargs),1,[]);
%% function arguments have to have exact column length
if fmt.debug
    assert(all(fmt.argsize_exp==fargsize_prov),'sco_gen:args',...
        'sco_gen: function args should have length %s bu have length %s',...
        num2str(fmt.argsize_exp),num2str(fargsize_prov))
end
if isempty(devargs)
    devargs=cell(fmt.nargs,0);
end
%% among deviations detect 'I' and 0 and expand column length to full argsize 
% (replacing 'I' with NaN)
isid=cellfun(@(x)ischar(x)&&strcmp(x,'I'),devargs);
is0=cellfun(@(x)isnumeric(x)&&numel(x)==1&&x==0,devargs);
if fmt.debug
    assert(all(sum(isid,1)<=1),'sco_gen:args',...
        'sco_gen: at most one deviation can be ''I'' per degree')
    assert(all(sum(isid,1)==0|sum(isid+is0,1)==fmt.nargs),'sco_gen:args',...
        'sco_gen: if one deviation is ''I'' all others must be 0');
end
devargsize_exp=repmat(fmt.argsize_exp(:),1,fmt.deg);
devargs(isid)=arrayfun(@(sz)NaN(sz,1),devargsize_exp(isid),'UniformOutput',false);
devargs(is0)=arrayfun(@(sz)zeros(sz,1),devargsize_exp(is0),'UniformOutput',false);
devargsize_prov=cellfun(@(x)size(x,1),devargs);
if fmt.debug
    assert(all(devargsize_exp==devargsize_prov,'all'),'sco_gen:args',...
        'sco_gen: function args should have length %s but have length %s',...
        num2str(devargsize_exp),num2str(devargsize_prov))
end
%% manual vectorization singleton expansion
[args, nvec] = sco_argexpand(cat(2,fargs,devargs), fmt);
args=reshape(args,size(fargs,1),[]);
%% expand all 'I' entries to identity matrices, expand all arguments
isidall=cat(2,false(fmt.nargs,1),isid);
n_id=find(isidall);
dims=[NaN(1,length(n_id)),nvec];
vec_expand=@(y,n)reshape(repmat(reshape(y,size(y,1),1,size(y,2)),1,n,1),size(y,1),[]);
id_create=@(y)reshape(repmat(eye(size(y,1)),1,1,size(y,2)),size(y,1),[]);
for i=length(n_id):-1:1
    [ir,~]=ind2sub(size(isidall),n_id(i));
    args{n_id(i)} =id_create(args{n_id(i)});
    if ~fmt.isvec(ir)
        continue;
    end
    dims(i)=fmt.argsize_exp(ir);
    for k=1:numel(args)
        if k~=n_id(i)
            args{k}=vec_expand(args{k},dims(i));
        end
    end
end
dims=dims(~isnan(dims));
u0=cat(1,args{:,1});
[nargs_all,nvec_all]=size(u0);
udev=arrayfun(@(i)cat(1,args{:,i+1}),1:fmt.deg,'UniformOutput',false);
udev=reshape(cat(1,udev{:}),nargs_all,fmt.deg,nvec_all);
end
