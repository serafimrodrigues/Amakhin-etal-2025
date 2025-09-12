%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(b), zoom in near I_db of CC
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
Idb=ccrun.Is(i_cc_hopf(2));
zoom_rg=10*[-1,1];
sel=ccrun.Is>Idb+zoom_rg(1)&ccrun.Is<Idb+zoom_rg(2);
fig=figure(3);clf;
%%% LAY-OUT
txt={'Fontsize',16};
ltx=[{'Interpreter','LaTeX'},txt];
set(gcf,'color','white');
pcc=plot(ccrun.Is(sel),ccrun.V(sel),'color',[1 0.6 0.4],'DisplayName','$V(I_\mathrm{h})$ (spike)');
hold on;
peq=plot(cceq.Is(sel),cceq.V(sel),'color',[1 0.5 0.3],'LineWidth',2,'DisplayName','$V(I_\mathrm{h})$ (slow)');
pidb=xline(Idb,':','linewidth',2,'DisplayName','$I_\mathrm{db}$')
set(gca,'FontName','Courier','FontWeight','bold',txt{:});
axis('tight');
lg=legend([pcc,peq,pidb],ltx{:})
ylabel('$V_\mathrm{cc}$ (mV)',ltx{:});
xlabel('$I_\mathrm{h}$\,(pA)',ltx{:});
%%
fig.Position(3:4)=[560,420];
folder=[pwd(),'/../../figures/'];
exportgraphics(fig,[folder,'FigureSI9.pdf'],'ContentType','vector');
