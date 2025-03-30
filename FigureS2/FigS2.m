%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.S2 of the supplemental material
%--------------------------------------------------------------------
clear
s=load('../mat_files/vcruns.mat','vcruns','ip','xnames');
[vcruns,ip,xnames]=deal(s.vcruns,s.ip,s.xnames);
s=load('../mat_files/ccruns.mat','ccruns');
ccruns=s.ccruns;
bd.I=[-Inf,450];
bd.t=[0,50];
bd.V=[-Inf,Inf];
geti=@(x,i)x(i);
checkbd=@(x,s)x(:,ip.(s))>geti(bd.(s),1)&x(:,ip.(s))<geti(bd.(s),2);
nruns=length(vcruns);

%%% filter VC runs with various window lengths
wvcsize=[5000,15000,16000];
for i=nruns:-1:1
    x=vcruns(i).data;
    vr{i}=x(checkbd(x,'I')&checkbd(x,'t'),:);
    for k=1:length(wvcsize)
        Is{i,k}=smoothdata(vr{i}(:,ip.I),'movmedian',wvcsize(k));
    end
end
runlens=arrayfun(@(i)size(vr{i},1),1:nruns);

%%% order cells according to "type-II"-ness
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
neurontype=arrayfun(@(i)sum(idiff(i)),1:nruns);
[~,icellorder]=sort(neurontype,'ascend');
[vr,Is]=deal(vr(icellorder),Is(icellorder,:));
v0=vr;
ccruns=ccruns(icellorder);
wccisize=1500;
wccvsize=10;
for i=nruns:-1:1
    x=ccruns(i).data;
    cr{i}=x(checkbd(x,'I')&checkbd(x,'t'),:);
    for k=1:length(wccisize)
        Icc{i,k}=smoothdata(cr{i}(:,ip.I),'movmean',wccisize(k));
    end
    for k=1:length(wccvsize)
        Vcc{i,k}=smoothdata(cr{i}(:,ip.V),'movmean',wccvsize(k));
    end
end
runlens=runlens(icellorder);
idiff=@(i)[-diff(Is{i,2}).*(diff(Is{i,2})<0).*diff(vr{i}(:,ip.V));0];
Vall=cellfun(@(v)v(:,ip.V),vr,'UniformOutput',false);

%%% Panel a
iccsmall=@(irun)cr{irun}(:,ip.I)<150;
V0cross_ind=arrayfun(@(irun)find(diff(sign(Vcc{irun,1}(iccsmall(irun))))>0),1:nruns,'UniformOutput',false);
V0cross_time=arrayfun(@(irun)cr{irun}(V0cross_ind{irun},ip.t),1:nruns,'UniformOutput',false);
V0cross_C=arrayfun(@(irun)Icc{irun,1}(V0cross_ind{irun}),1:nruns,'UniformOutput',false);
figure(1);clf;ax=gca;hold(ax,'on');
symbols='ox+sd';
for i=1:nruns
    plot(V0cross_C{i}(2:end-1),diff(V0cross_time{i}(1:end-1)),...
        [symbols(i),'-'],'markersize',8,...
        'DisplayName',sprintf('cell %d',i),'Linewidth',2);
end
legend(ax,'location','best');
hold(ax,'off');
grid(ax,'on');
xlabel('$I_h$\,(pA)','Interpreter','latex');
yl=ylabel('$\delta_{t,V=0}$ (s)','Interpreter','latex');
set(ax,'FontSize',18,'Box','on');
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([60 140 0 0.5]);
set(gca,'XTick',60:40:140);
set(gca,'YTick',0:0.25:0.5);

%%% Panel b
iccsmall=@(irun)cr{irun}(:,ip.I)<150;
V0cross_ind=arrayfun(@(irun)find(diff(sign(Vcc{irun,1}(iccsmall(irun))))>0),1:nruns,'UniformOutput',false);
V0cross_time=arrayfun(@(irun)cr{irun}(V0cross_ind{irun},ip.t),1:nruns,'UniformOutput',false);
V0cross_C=arrayfun(@(irun)Icc{irun,1}(V0cross_ind{irun}),1:nruns,'UniformOutput',false);
figure(2);clf;ax=gca;hold(ax,'on');
symbols='ox+sd';
for i=1:nruns
    plot(V0cross_C{i}(2:end-1),1./diff(V0cross_time{i}(1:end-1)),...
        [symbols(i),'-'],'markersize',8,...
        'DisplayName',sprintf('cell %d',i),'Linewidth',2);
end
legend(ax,'location','best');
hold(ax,'off');
grid(ax,'on');
xlabel('$I_h$\,(pA)','Interpreter','latex');
yl=ylabel('$(\delta_{t,V=0})^{-1}$ (Hz)','Interpreter','latex');
set(ax,'FontSize',18,'Box','on');
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([60 140 0 20]);
set(gca,'XTick',60:40:140);
set(gca,'YTick',0:10:20);

