%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.S1(b) of the supplemental material
%--------------------------------------------------------------------

%%% First unzip the data file 
%%% Then load CC for cell #2
% c2=load('cell2.txt');

%%% Plot CC after smoothing
wsize=(1500);
for k=1:length(wsize)
smoothc2=smoothdata(c2(1:1220000,3),'movmean',wsize(k));
end
plot(smoothc2,c2(1:1220000,2),'color',[1 0.6 0.4]);hold on;


%%% Plot VC for cell #2
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
%%% order cells
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
neurontype=arrayfun(@(i)sum(idiff(i)),1:nruns);
[~,icellorder]=sort(neurontype,'ascend');
[vr,Is]=deal(vr(icellorder),Is(icellorder,:));
ccruns=ccruns(icellorder);
runlens=runlens(icellorder);
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
Vall=cellfun(@(v)v(:,ip.V),vr,'UniformOutput',false);
%%% depolarizing current
I_depol=[233.154;338.745;264.282;365.601;405.884];
I_depol=I_depol(icellorder);
ind_depol=arrayfun(@(i)find(vr{i}(Is{i,1}<I_depol(i),ip.V),1,'last'),1:nruns); 
%%% Determine other "Hopf" bifurcation, if present 
icv0_hopflow=arrayfun(@(i)find(ccruns(i).data(:,ip.V)>0,1,'first'),1:nruns);
icv_hopflow=arrayfun(@(i)find(diff(ccruns(i).data(:,ip.V))<0&...
    ccruns(i).data(2:end,ip.t)<ccruns(i).data(icv0_hopflow(i),ip.t),1,'last'),1:nruns);
ind_hopflow=arrayfun(@(i)find(vr{i}(:,ip.I)>ccruns(i).data(icv_hopflow(i),ip.I),1,'first'),1:nruns);
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
%%%
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
for i=2:2
    isneg=idiff(i)>0;
    iunst=unst(1,i):unst(2,i);
    ismall=vr{i}(:,ip.I)<xbd(1);
    vr{i}(ismall,ip.I)=NaN;
    plot(vr{i}(:,ip.I),vr{i}(:,ip.V),'-','color',bg,'linewidth',1.5);
    hold on;
    plot(Is{i,1}(~isneg),vr{i}(~isneg,ip.V),'.','color',cm,'MarkerSize',6);
    hold on;
    plot(Is{i,1}(iunst),vr{i}(iunst,ip.V),'.','color',cunst,'MarkerSize',7);
    hold on;
    plot(Is{i,1}(isneg),vr{i}(isneg,ip.V),'.','color',cneg,'MarkerSize',8);
    hold on;
    iri=find(vr{i}(:,ip.I)>=labelx,1,'first');
    labely=vr{i}(iri,ip.V);
    for k=1:2
        if isfinite(ind_hopf(k,i))
            plot(Is{i,1}(ind_hopf(k,i)),vr{i}(ind_hopf(k,i),ip.V),shopf,...
                'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');
        end
        if isfinite(ind_fold(k,i))
            plot(Is{i,2}(ind_fold(k,i)),vr{i}(ind_fold(k,i),ip.V),sfold,...
                'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');
        end
    end
end
vn=plot(NaN,NaN,'o','MarkerEdgeColor',cneg,'MarkerFaceColor',cneg,'MarkerSize',6);
hold on;
vu=plot(NaN,NaN,'o','MarkerEdgeColor',cunst,'MarkerFaceColor',cunst,'MarkerSize',6);
hold on;
vp=plot(NaN,NaN,'o','MarkerEdgeColor',cm,'MarkerFaceColor',cm,'MarkerSize',6);
hold on;
vf=plot(NaN,NaN,'-','Color',bg,'MarkerFaceColor',bg,'LineWidth',2);
hold on;
vh=plot(NaN,NaN,shopf,'Color','k','MarkerFaceColor',chopf,'LineWidth',1);
hold on;
vsn=plot(NaN,NaN,sfold,'Color','k','MarkerFaceColor',cfold,'LineWidth',1);

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([-20 440 -80 40]);
set(gca,'XTick',0:200:400);
set(gca,'YTick',-80:40:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');

