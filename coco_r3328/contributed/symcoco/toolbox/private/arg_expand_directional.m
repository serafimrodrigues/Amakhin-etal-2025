function [u0,udev,dims]=arg_expand_directional(fmt,varargin)
u0args=varargin(1:fmt.nargs);
u0args=u0args(:);
devargs=varargin(fmt.nargs+1:end);
if isempty(devargs) && fmt.deg>0
    devargs=repmat({},fmt.nargs,1);
end
if fmt.debug
    assert(numel(devargs)==fmt.nargs,...
        'sco_gen:args',...
        'sco_gen: number of arguments given, %d, different from expected: %d',...
        numel(devargs),fmt.args_exp);
end
devargs=cellfun(@(c)reshape(c,1,[]),devargs(:));
%% manual vectorization singleton expansion
[args,nvec]=sco_argexpand([u0args,devargs],fmt);
%% expand missing deviations
u0=cat(1,args{:,1});
u0dim=size(u0,1);
dev=arrayfun(@(i)cat(1,args{:,i}),2:size(args,2),'UniformOutput',false);
n_exp=max(fmt.deg-size(args,2)+1,0);
dims=[u0dim*ones(1,n_exp),nvec];
vec_expand=@(y,n)reshape(repmat(reshape(y,size(y,1),1,size(y,2)),1,n,1),size(y,1),[]);
id_create=@(y)reshape(repmat(eye(size(y,1)),1,1,size(y,2)),size(y,1),[]);
dev=[dev,repmat({NaN(u0dim,nvec)},1,n_exp)];
args=[u0,dev];
for i=fmt.deg-n_exp+2:fmt.deg+1
    args{i}=id_create(args{i});
    for k=1:numel(args)
        if k~=i
            args{k}=vec_expand(args{k},u0dim);
        end
    end    
end
nvec_all=size(args{1},2);
u0=args{1};
udev=reshape(cat(1,args{2:end}),u0dim,fmt.deg,nvec_all);
end