clear;
f=figure(5);
ax=f.Children(1);
for i=1:length(ax.Children)
    c=ax.Children(i);
    curve(i)=struct('x',c.XData,'y',c.YData,'color',c.Color,...
        'name',c.DisplayName,'LineStyle',c.LineStyle,'Marker',c.Marker);
end
ic=struct('cc',13,'vcraw',12,'vcsmooth',11,'vc_unst',10);
indpts=find(arrayfun(@(c)isscalar(c.x)&&~isnan(c.x),curve));
bifs=[[curve(indpts).x];[curve(indpts).y]].';
hopf=bifs(bifs(:,1)>100,:);
fold=bifs(bifs(:,1)<=100,:);
fold=sortrows(fold,2);
[         cc,          vcraw,          vcsmooth,          vc_unst]=deal(...
 curve(ic.cc),curve(ic.vcraw),curve(ic.vcsmooth),curve(ic.vc_unst));
clear f ax
save('fig2a.mat');