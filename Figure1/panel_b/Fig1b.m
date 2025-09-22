%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(b)
%--------------------------------------------------------------------

%%% Load CC run and VC run for cell #5
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
fig=figure(1);clf;
pcc=plot(ccrun.Is,ccrun.V,'color',cc,'DisplayName','$V(I_\mathrm{h})$');
hold on;
plot(ccrun.Ieq,ccrun.Veq,'color',ccslow,'LineWidth',1.5);
pvcraw=plot(vcrun.I,vcrun.V,'-','color',bg,'linewidth',1.5,'DisplayName','VC\,unfiltered');
i_bifs=sort([1;vcrun.i_fold;vcrun.i_hopf;length(vcrun.t)],'ascend');
for i=1:length(stab_flags)
    rg=i_bifs(i):i_bifs(i+1);
    ind=stab_ind.(stab_flags{i});
    pvcstab(i)=plot(vcrun.Is(rg),vcrun.V(rg),'-','color',stab_cl{ind},...
        'linewidth',stab_lw{ind},'DisplayName',stab_struct.(stab_flags{i}));
end
ph=plot(vcrun.Is(vcrun.i_hopf(2)),vcrun.V(vcrun.i_hopf(2)),shopf,'MarkerFaceColor',chopf,ms{:},'DisplayName','Hopf');
pf=plot(vcrun.Is(vcrun.i_fold),vcrun.V(vcrun.i_fold),sfold,'MarkerFaceColor',cfold,ms{:},'DisplayName','Fold');
pe=plot(NaN,NaN,'w.','DisplayName',' ');
%%
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
lg=legend([pcc,pvcraw,pvcstab(1:4),pe,ph,pf],...
    'NumColumns',3,'Interpreter','latex','Location','southeast','FontSize',16);
%%% LAY-OUT for panel (a2) of Figure 5
% axis([190 210 -40 40]);
% set(gca,'XTick',190:10:210);
%%
fig.Position(3:4)=[650,400]; % fix size of figure for repeatable plotting
folder=[pwd(),'/../../figures/'];
exportgraphics(fig,[folder,'Figure1b.pdf'],'ContentType','vector');

