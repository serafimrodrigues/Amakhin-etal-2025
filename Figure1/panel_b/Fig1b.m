%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(b)
%--------------------------------------------------------------------


%% First unzip the data file
%%% Then load CC for cell #5
clear 
c5=load('cell5.txt');
c5=c5(1:1200000,:);
s1=load('../../mat_files/vcruns.mat','vcruns','ip','xnames');
s2=load('../../mat_files/ccruns.mat','ccruns');
%%
ccruns=s2.ccruns;
[vcar,ip,xnames]=deal(s1.vcruns(4).data,s1.ip,s1.xnames);
bd.I=[-Inf,450];
bd.t=[0,50];
bd.V=[-Inf,Inf];
geti=@(x,i)x(i);
checkbd=@(x,s)x(:,ip.(s))>geti(bd.(s),1)&x(:,ip.(s))<geti(bd.(s),2);
vcar=vcar(checkbd(vcar,'I')&checkbd(vcar,'t'),:);
ccrun=struct('I',c5(:,3),'V',c5(:,2),'t',c5(:,1));
vcrun=struct('I',vcar(:,ip.I),'V',vcar(:,ip.V),'t',vcar(:,ip.t));
[wsize,maxrep,degree]=deal(60000,500,10);
[vcrun.Is,num]=smooth_I_sg(vcrun.I,wsize,maxrep,degree);
wsize=1500;
thresholds=struct('spike',25,'isi',100e-3,'si',0.5);
[i_cc_hopf,i_vc_hopf,i_vc_unst,ccrun.Vs]=match_spikes(ccrun,vcrun,wsize*mean(diff(vcrun.t)),thresholds);
wsize=1500;
ccrun.Is=smoothdata(ccrun.I,'movmean',wsize);
[weqsize,eqthresh]=deal(0.01,0.05);
cceq=match_cc_stst(ccrun,weqsize,eqthresh);
%% % Plot CC after smoothing
fig=figure(1);clf;
pcc=plot(ccrun.Is,ccrun.V,'color',[1 0.6 0.4],'DisplayName','$V(I_\mathrm{h})$');
hold on;
%cc_spike_rg=i_cc_hopf(1):i_cc_hopf(2);
%plot(ccrun.Is(cc_spike_rg),ccrun.Vs(cc_spike_rg),'color',[1 0.4 0.2]);
plot(cceq.Is,cceq.V,'color',[1 0.5 0.3],'LineWidth',1.5);
%% order cells
ind_hopf=i_vc_hopf;
ind_fold=find(diff(sign(diff(vcrun.Is))));
stab_rg=[1;sort([ind_fold;ind_hopf]);length(vcrun.t)];
stab_rg=[stab_rg(1:end-1),stab_rg(2:end)];
%% %
txt={'Fontsize',16};
ltx=[{'Interpreter','LaTeX'},txt];
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cund=[1,0.9,0];
cneg=cunst/2;
chopf=[1,1,1];
shopf='ks';
cfold=[0,1,0];
sfold='ks';
c_cc=[1 0.6 0.4];%in.cc.color;
bg=cm*1/3+2/3;
stab_names={...
    'stable','VC stable';...
    'ubyfold','$$\frac{\normalsize\mathrm{d}I_\mathrm{vc}}{\normalsize\mathrm{d}V_\mathrm{h}}<0$$';...
    'undet','VC stab. undet.';...
    'ubyhopf', 'VC\,unst.\,by Hopf'}';
stab_struct=struct(stab_names{:});
stab_flags={'stable','ubyfold','ubyhopf','ubyhopf','stable'};
stab_cl={      cm,      cneg,   cunst,    cunst,   cm};
stab_lw={      2,        2,      2,       2,      2};
pvcraw=plot(vcrun.I,vcrun.V,'-','color',bg,'linewidth',1.5,'DisplayName','VC\,unfiltered');
for i=1:length(stab_flags)
    rg=stab_rg(i,1):stab_rg(i,2);
    pvcstab(i)=plot(vcrun.Is(rg),vcrun.V(rg),'-','color',stab_cl{i},'linewidth',stab_lw{i},'DisplayName',stab_struct.(stab_flags{i}));
end
ph=plot(vcrun.Is(ind_hopf(2)),vcrun.V(ind_hopf(2)),shopf,'MarkerFaceColor',chopf,'MarkerSize',8,'DisplayName','Hopf');
pf=plot(vcrun.Is(ind_fold),vcrun.V(ind_fold),sfold,'MarkerFaceColor',cfold,'MarkerSize',8,'DisplayName','Fold');
pe=plot(NaN,NaN,'w.','DisplayName',' ');
%%
xbd=[min(vcrun.Is),430];%min(vcrun.Is)-30,max(vcrun.Is)+30];
ybd=[min(vcrun.V),max(ccrun.V)];
%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontWeight','bold',txt{:});
axis([xbd ybd]);
set(gca,'XTick',0:200:400,'LineWidth',1);
set(gca,'YTick',-80:40:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)',ltx{:});
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)',ltx{:});
text(xbd(1)+5,ybd(2)-2,'(b)',...
    'VerticalAlignment','top','HorizontalAlignment','left',ltx{:},'Fontsize',18);
lg=legend([pcc,pvcraw,pvcstab(1:3),pe,ph,pf],...
    'NumColumns',3,'Interpreter','latex','Location','southeast','FontSize',16);
%%% LAY-OUT for panel (a2) of Figure 5
% axis([190 210 -40 40]);
% set(gca,'XTick',190:10:210);
%%
fig.Position(3:4)=[650,400]; % fix size of figure for repeatable plotting
folder=[pwd(),'/../../../PLoS-amakhin/PLoS revision/'];
exportgraphics(fig,[folder,'Figure1b.pdf'],'ContentType','vector');

