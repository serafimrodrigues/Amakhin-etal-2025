%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(c)
%--------------------------------------------------------------------

%%% Plot bifurcation diagrams for all cells in one 2d graph
clear
s=load('../../mat_files/vcruns.mat','vcruns','ip','xnames');
[vcruns,ip,xnames]=deal(s.vcruns,s.ip,s.xnames);
s=load('../../mat_files/ccruns.mat','ccruns');
ccruns=s.ccruns;
bd.I=[-Inf,450];
bd.t=[0,50];
bd.V=[-Inf,Inf];
geti=@(x,i)x(i);
checkbd=@(x,s)x(:,ip.(s))>geti(bd.(s),1)&x(:,ip.(s))<geti(bd.(s),2);
nruns=length(vcruns);
%%% filter VC runs with various window lengths
wsize=[5000,15000,16000];
for i=nruns:-1:1
    x=vcruns(i).data;
    vr{i}=x(checkbd(x,'I')&checkbd(x,'t'),:);
    for k=1:length(wsize)
        Is{i,k}=smoothdata(vr{i}(:,ip.I),'movmedian',wsize(k));
    end
end
runlens=arrayfun(@(i)size(vr{i},1),1:nruns);
%%% order cells according to "type-II"-ness
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
neurontype=arrayfun(@(i)sum(idiff(i)),1:nruns);
[~,icellorder]=sort(neurontype,'ascend');
[vr,Is]=deal(vr(icellorder),Is(icellorder,:));
ccruns=ccruns(icellorder);
runlens=runlens(icellorder);
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
Vall=cellfun(@(v)v(:,ip.V),vr,'UniformOutput',false);
%%% depolarizing current
I_depol=[233.154;338.745; 264.282; 365.601; 405.884];
I_depol=I_depol(icellorder);
ind_depol=arrayfun(@(i)find(vr{i}(Is{i,1}<I_depol(i),ip.V),1,'last'),1:nruns); 
%%% Determine other "Hopf" bifurcation, if present 
icv0_hopflow=arrayfun(@(i)find(ccruns(i).data(:,ip.V)>0,1,'first'),1:nruns);
icv_hopflow=arrayfun(@(i)find(diff(ccruns(i).data(:,ip.V))<0&...
    ccruns(i).data(2:end,ip.t)<ccruns(i).data(icv0_hopflow(i),ip.t),1,...
    'last'),1:nruns);
ind_hopflow=arrayfun(@(i)find(vr{i}(:,ip.I)>ccruns(i).data(icv_hopflow(i),...
    ip.I),1,'first'),1:nruns);
ind_hopf=[ind_hopflow;ind_depol];
%%% "Fold" location
idiff3=@(i)[-diff(Is{i,3}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
ind_fold1=arrayfun(@(i)find(idiff3(i)>0,1,'first'),1:nruns,'UniformOutput',false);
ind_fold2=arrayfun(@(i)find(idiff3(i)>0,1,'last'),1:nruns,'UniformOutput',false);
ind_fold(1,:)=cellfun(@(x)cat(1,x,Inf(1-numel(x),1)),ind_fold1);
ind_fold(2,:)=cellfun(@(x)cat(1,x,-Inf(1-numel(x),1)),ind_fold2);
%%% remove low-I "Hopf" if onset of oscillations at "fold", label region of instability
ind_hopf(1,ind_hopf(1,:)>ind_fold(1,:))=Inf;
unst=[min(ind_hopf(1,:),ind_fold(1,:));...
    min(max(ind_hopf(2,:),ind_fold(2,:)),runlens)];

%%% Plot
figure(2);clf;set(gcf,'color','white');ax=gca;
hold(ax,'on');
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;
xbd=[min(cat(1,Is{:}))-30,max(cat(1,Is{:}))+30];
zbd=[min(cat(1,Vall{:}))-5,max(cat(1,Vall{:}))+3];
bddeco={':','color',(clr(2,:)+1)/2,'linewidth',2};
cfac=50;
labelx=400;
cshift=@(i,v)(i-1)*cfac+v;
for i=1:nruns
    isneg=idiff(i)>0;
    iunst=unst(1,i):unst(2,i);
    ismall=vr{i}(:,ip.I)<xbd(1);
    vr{i}(ismall,ip.I)=NaN;
    plot(ax,vr{i}(:,ip.I),cshift(i,vr{i}(:,ip.V)),'-','color',bg,'linewidth',1.5);    
    plot(ax,Is{i,1}(~isneg),cshift(i,vr{i}(~isneg,ip.V)),'.','color',cm,'MarkerSize',6);
    plot(ax,Is{i,1}(iunst),cshift(i,vr{i}(iunst,ip.V)),'.','color',cunst,'MarkerSize',7);
    plot(ax,Is{i,1}(isneg),cshift(i,vr{i}(isneg,ip.V)),'.','color',cneg,'MarkerSize',8);
    iri=find(vr{i}(:,ip.I)>=labelx,1,'first');
    labely=cshift(i,vr{i}(iri,ip.V));
    text(ax,labelx,labely,sprintf('%d',i),'VerticalAlignment','top',...
        'FontName','Courier','FontWeight','bold','FontSize',12);
    for k=1:2
        if isfinite(ind_hopf(k,i))
            plot(ax,Is{i,1}(ind_hopf(k,i)),cshift(i,vr{i}(ind_hopf(k,i),ip.V)),shopf,...
                'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');
        end
        if isfinite(ind_fold(k,i))
            plot(ax,Is{i,2}(ind_fold(k,i)),cshift(i,vr{i}(ind_fold(k,i),ip.V)),sfold,...
                'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');
        end
    end
end
vn=plot(ax,NaN,NaN,'o','MarkerEdgeColor',cneg,'MarkerFaceColor',cneg,'MarkerSize',6);
vu=plot(ax,NaN,NaN,'o','MarkerEdgeColor',cunst,'MarkerFaceColor',cunst,'MarkerSize',6);
vp=plot(ax,NaN,NaN,'o','MarkerEdgeColor',cm,'MarkerFaceColor',cm,'MarkerSize',6);
vf=plot(ax,NaN,NaN,'-','Color',bg,'MarkerFaceColor',bg,'LineWidth',2);
vh=plot(ax,NaN,NaN,shopf,'Color','k','MarkerFaceColor',chopf,'LineWidth',1);
vsn=plot(ax,NaN,NaN,sfold,'Color','k','MarkerFaceColor',cfold,'LineWidth',1);
hold(ax,'off');
grid(ax,'on');
xlim(ax,xbd);
vlab=[-75;-50];
[rlabmsh,vlabmsh]=meshgrid(1:nruns,vlab);
yticks=cshift(1:nruns,vlab);
yticklabels=arrayfun(@(r,v)sprintf('%2.0f_%1d',v,r),rlabmsh,vlabmsh,'UniformOutput',false);
ax.YTick=yticks(:);
ax.YTickLabel=yticklabels(:);
box(ax,'on');
ax.Clipping='off';
ax.FontSize=16;
ax.FontWeight='bold';
ax.FontName='Courier';
ax.LineWidth=1.5;
ax.PlotBoxAspectRatio=[1,1,1];
yl=ylabel('$V_\mathrm{h}$ (mV)','Interpreter','latex');
xl=xlabel('$I_\mathrm{vc}$\,(pA)','Interpreter','latex');
lg=legend(ax,[vn,vu,vp,vf,vh,vsn],{...
    '$$\frac{\mathrm{d}I_\mathrm{vc}^{\phantom{I}}}{\mathrm{d}V_\mathrm{h}}\!<\!0\mbox{\ (unst.)}$$',...
    '$I_\mathrm{vc}(V_\mathrm{h})$\hspace*{1.2ex} (unst.)',...
    '$I_\mathrm{vc}(V_\mathrm{h})$\hspace*{1.2ex} (stab.)',...
    '$I_\mathrm{vc}(V_\mathrm{h})$ (unf.)',...
    '``Hopf" bif.',...
    '``fold" bif.'...
    },'Location','southeast','Interpreter','latex','NumColumns',2);
lg.Position([1,2])=[0.45,0.11];
lg.FontSize=12;
