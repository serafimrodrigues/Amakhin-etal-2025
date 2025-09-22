%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(b), zoom in near I_db of CC
%--------------------------------------------------------------------

%% First unzip the data file
%%% Then load CC for cell #5
clear 
s=load('../../mat_files/processed_runs.mat');
[ccrun,vcrun]=deal(s.ccruns(5),s.vcruns(5));
clr=lines();
cm=clr(1,:);
[  cunst,      cund,       cc,          ccslow,    chopf,   cfold]=deal(...
[1,0.2,0.2], [1,0.9,0], [1,0.6,0.4], [1 0.5 0.3], [1,1,1], [0,1,0]);
[cneg,bg]=deal(cunst/2,cm*1/3+2/3);
[shopf,sfold]=deal('ks');
xbd=[min(vcrun.Is),430];%min(vcrun.Is)-30,max(vcrun.Is)+30];
ybd=[min(vcrun.V),max(ccrun.V)];
relcoord=@(bd,frac)bd(1)+frac*diff(bd);
[labelx,labely]=deal(relcoord(xbd,0.02),relcoord(ybd,0.98));
stab_names={...
    'stable','VC stable';...
    'ubyfold','$$\frac{\normalsize\mathrm{d}I_\mathrm{vc}}{\normalsize\mathrm{d}V_\mathrm{h}}<0$$';...
    'undet','VC stab. undet.';...
    'ubyhopf', sprintf('VC unst. by Hopf')}';
txt={'FontSize',16,'FontName','Courier','FontWeight','bold'};
ltx=[txt,{'Interpreter','latex'}];
ms={'MarkerSize',8};
stab_flags={'stable','ubyfold','undet','ubyhopf','stable'};
stab_struct=struct(stab_names{:});
stab_ic=[stab_names(1,:);num2cell(1:size(stab_names,2))];
stab_ind=struct(stab_ic{:});
stab_cl([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          cm,             cunst,          cneg,            cund};
stab_lw([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          2,              2,               2,              2};
%% % Plot CC after smoothing
Idb=ccrun.Is(ccrun.i_hopf(2));
zoom_rg=10*[-1,1];
sel=ccrun.Is>Idb+zoom_rg(1)&ccrun.Is<Idb+zoom_rg(2);
fig=figure(3);fig.Name='Figure SI9';clf;
%%% LAY-OUT
txt={'Fontsize',16};
ltx=[{'Interpreter','LaTeX'},txt];
set(gcf,'color','white');
pcc=plot(ccrun.Is(sel),ccrun.V(sel),'color',cc,'DisplayName','$V(I_\mathrm{h})$ (spike)');
hold on;
peq=plot(ccrun.Ieq(sel),ccrun.Veq(sel),'color',ccslow,'LineWidth',2,'DisplayName','$V(I_\mathrm{h})$ (slow)');
pidb=xline(Idb,':','linewidth',2,'DisplayName','$I_\mathrm{db}$');
set(gca,'FontName','Courier','FontWeight','bold',txt{:});
axis('tight');
lg=legend([pcc,peq,pidb],ltx{:});
ylabel('$V_\mathrm{cc}$ (mV)',ltx{:});
xlabel('$I_\mathrm{h}$\,(pA)',ltx{:});
%%
fig.Position(3:4)=[560,420];
folder=[pwd(),'/../../figures/'];
exportgraphics(fig,[folder,'FigureSI9.pdf'],'ContentType','vector');
