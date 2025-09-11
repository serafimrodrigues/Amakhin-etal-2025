function [args, nvec] = sco_argexpand(args, fmt)
%% manual vectorization singleton expansion
argsnvec=cellfun(@(x)size(x,2),args);
nvec=max(argsnvec(:));
if nargin>1 && fmt.debug
    assert(all(argsnvec==1|argsnvec==nvec,'all'),'sco_gen:args',...
        'sco_gen: all arguments must have same column dimension or single column');
end
for i=1:numel(args)
    if argsnvec(i)==1
        args{i}=args{i}(:,ones(1,nvec));
    end
end
end