%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to prepare structures for Fig.1b, 1c, SI1
%--------------------------------------------------------------------
%%% Process runs for cells 1-5
clear
doplot=true;
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
%% define ccruns and vcruns structures
for i=nruns:-1:1
    x=ccruns(i).data;
    ccruns(i).data=x(checkbd(x,'I')&checkbd(x,'t'),:);
    [              ccruns(i).t,           ccruns(i).I,           ccruns(i).V]=...
    deal(ccruns(i).data(:,ip.t),ccruns(i).data(:,ip.I),ccruns(i).data(:,ip.V));
    x=vcruns(i).data;
    vcruns(i).data=x(checkbd(x,'I')&checkbd(x,'t'),:);
    [              vcruns(i).t,           vcruns(i).I,           vcruns(i).V]=...
    deal(vcruns(i).data(:,ip.t),vcruns(i).data(:,ip.I),vcruns(i).data(:,ip.V));
end
%% filter VC runs with various window lengths
wsize_smooth=struct('movmean',ones(1,5),'gaussian',[0.5,0.01]);
wsize=0.1;
for i=1:nruns
    vcout=smooth_I_mth(vcruns(i),wsize_smooth);
    vcruns(i).Is=vcout.Is;
    vcruns(i).Vs=smoothdata(vcruns(i).V,'gaussian',wsize,'SamplePoints',vcruns(i).t);
    ifold=find(diff(sign(diff(vcruns(i).Is))));
    isel=[true;diff(ifold)~=1];
    vcruns(i).i_fold=ifold(isel(1:length(ifold)));
end
%% order cells according to type-II-ness
idiff=@(r)[-diff(r.Is).*(diff(r.Is)<0).*diff(r.Vs);0];
neurontype=arrayfun(@(r)sum(idiff(r)),vcruns);
[~,icellorder]=sort(neurontype,'ascend');
vcruns=vcruns(icellorder);
ccruns=ccruns(icellorder);
%% for ccruns determine boundaries of oscillations, slow part of oscillations
thresholds=struct('spike',10,'isi',1,'trainlen',40,'wsize',wsize);
[weqsize,eqthresh]=deal([2e-5,0.01],5);
if doplot
    step=100;
    figure(2);clf;hold on;
end
for i=1:nruns
    ccruns(i).Is=smoothdata(ccruns(i).I,'gaussian',wsize,'SamplePoints',ccruns(i).t);
    [ccruns(i).i_hopf,vcruns(i).i_hopf,vcruns(i).i_unst,ccruns(i).Vs]=match_cc_spikes(ccruns(i),vcruns(i),thresholds);
    ccruns(i).dv_norm=match_cc_slow(ccruns(i),weqsize);
    ccruns(i).lslow=ccruns(i).dv_norm<eqthresh;
    ccruns(i).Veq=ccruns(i).V;
    ccruns(i).Ieq=ccruns(i).Is;
    ccruns(i).Veq(~ccruns(i).lslow)=NaN;
    rc=ccruns(i);
    rv=vcruns(i);
    disp(rc.Is(rc.i_hopf));
    if doplot
        plot(rc.Is,rc.V+i*step);
        plot(rc.Is,rc.Veq+i*step,'k','LineWidth',2);
        plot(rv.Is(rv.i_hopf),rv.Vs(rv.i_hopf)+i*step,'co','LineWidth',2);
        plot(rv.Is,rv.Vs+i*step,'b-','LineWidth',2);
        grid on
        drawnow
    end
end
%% save results
save('../mat_files/processed_runs.mat');