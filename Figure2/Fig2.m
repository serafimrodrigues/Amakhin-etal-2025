%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.2
%--------------------------------------------------------------------
clear
addpath([pwd(),'/../m_files/']);
matfiles=[pwd(),'/../mat_files/'];
s=load([pwd(),'/../mat_files/processed_fig2runs.mat']);
[     vcrun,  ccrun,   ic,  wsize_vcIs0,  wsize_smooth]=deal(...
    s.vcrun,s.ccrun, s.ic,s.wsize_vcIs0,s.wsize_smooth);
clear s
%%
clr=lines();
cm=clr(1,:);
[  cunst,      cund,       cc,          ccslow,    chopf,   cfold]=deal(...
[1,0.2,0.2], [1,0.9,0], [1,0.6,0.4], [1 0.5 0.3], [1,1,1], [0,1,0]);
[cneg,bg]=deal(cunst/2,cm*1/3+2/3);
[shopf,sfold]=deal('s');
[xbd,ybd]=deal([-100,400],[-80,40]);
relcoord=@(bd,frac)bd(1)+frac*diff(bd);
[labelx,labely]=deal(relcoord(xbd,0.02),relcoord(ybd,0.98));
stab_names={...
    'stable','VC stable';...
    'ubyfold','$$\frac{\normalsize\mathrm{d}I_\mathrm{vc}}{\normalsize\mathrm{d}V_\mathrm{h}}<0$$';...
    'undet','VC stability undetermined';...
    'ubyhopf', sprintf('VC unstable by Hopf')}';
stab_struct=struct(stab_names{:});
stab_ic=[stab_names(1,:);num2cell(1:size(stab_names,2))];
stab_ind=struct(stab_ic{:});
stab_flags={'stable','ubyfold','ubyhopf','ubyhopf','stable','undet'};
stab_cl([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          cm,             cunst,          cneg,            cund};
stab_lw([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          2,              2,               2,              2};
txt={'FontSize',16};
ltx={'interpreter','latex','FontSize',18};
%
%
fig=figure(1);clf;set(gcf,'color','white');
tl=tiledlayout(1,2,'TileSpacing','tight','Padding','tight');
for k=1:2
    ax(k)=nexttile(k);
    hold(ax(k),'on');
    pcc=plot(ax(k),ccrun(k).Is,ccrun(k).V,'color',cc,'linewidth',1,...
        'DisplayName','CC');
    peq=plot(ccrun(k).Ieq,ccrun(k).Veq,'color',ccslow,'LineWidth',2,'DisplayName','$V(I_\mathrm{h})$ (slow)');
    pvraw=plot(ax(k),vcrun(k).Is0,vcrun(k).V,'color',bg,'linewidth',1.5,...
        'DisplayName',sprintf('VC filtered\n($w=%g$)',wsize_vcIs0));
    pvstab=plot(ax(k),vcrun(k).Is,vcrun(k).V,'color',cm,'linewidth',1.5,...
        'DisplayName',sprintf('VC smoothed\n($w=%2.1g$) stable',wsize_smooth.movmean(1)));
    i_unst=vcrun(k).i_unst;
    pvhu=plot(ax(k),vcrun(k).Is(i_unst),vcrun(k).V(i_unst),...
        'color',cunst,'linewidth',1.5,...
        'DisplayName',sprintf('VC smoothed\nunst. by Hopf'));
    for j=1:2:length(vcrun(k).i_fold)-1
        rg=vcrun(k).i_bif(j):vcrun(k).i_bif(j+1)-1;
        pvtop=plot(ax(k),vcrun(k).Is(rg),vcrun(k).V(rg),'-',...
        'color',cneg,'linewidth',2.5,'DisplayName',sprintf('VC smoothed,\nunst by fold'));
    end
    for j=2:2:length(vcrun(k).i_fold)-2
        rg=vcrun(k).i_bif(j):vcrun(k).i_bif(j+1)-1;
        pvund=plot(ax(k),vcrun(k).Is(rg),vcrun(k).V(rg),...
        'color',cund,'linewidth',2.5,'DisplayName',sprintf('VC smoothed,\nstab. undet.'));
    end
    if ~isempty(vcrun(k).i_fold)
        i_fold=vcrun(k).i_fold;
        pfold=plot(ax(k),vcrun(k).Is(i_fold),vcrun(k).V(i_fold),sfold,'MarkerFaceColor',...
            cfold,'MarkerSize',5,'MarkerEdgeColor','k','DisplayName','fold');
    end
    if ~isempty(vcrun(k).i_hopf)
        i_hopf=vcrun(k).i_hopf;
        phopf=plot(ax(k),vcrun(k).Is(i_hopf),vcrun(k).V(i_hopf),shopf,'MarkerFaceColor',...
            chopf,'MarkerSize',5,'MarkerEdgeColor','k','DisplayName','Hopf');
    end
    set(ax(k),'FontName','Courier','FontWeight','bold',txt{:});
    xlabel(ax(k),'$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)',ltx{:});
    grid(ax(k),'on');
    axis(ax(k),'tight');
    axis(ax(k),[-100 400 -80 40]);
    set(ax(k),'XTick',-100:125:400,'YTick',-80:40:40,'linewidth',1,'box','on');
    text(ax(k),-95,38,['(',char('a'+k-1),')'],'HorizontalAlignment','left','VerticalAlignment','top',...
        ltx{:});
end
ylabel(ax(1),'$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)',ltx{:});
yticklabels(ax(2),{});
ax(2).XTickLabel{1}=['  ',num2str(ax(2).XTick(1))];
lg=legend(ax(2),[pcc,pvraw,pvstab,pvhu,pvtop,pvund,pfold,phopf],...
    'Location','layout','Interpreter','latex');
lg.Layout.Tile='east';
%set(lg,'Position',[ax(2).Position(1)+ax(2).Position(3),lg.Position(2:4)]);
%%
fig.Position(3:4)=[982,325]; % fix size of figure for repeatable plotting
folder=[pwd(),'/../figures/'];
exportgraphics(fig,[folder,'Figure2.pdf'],'ContentType','vector');
