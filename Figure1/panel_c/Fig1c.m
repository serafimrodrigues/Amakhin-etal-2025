%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.1(c)
%--------------------------------------------------------------------

%%% Plot bifurcation diagrams for all cells in one 2d graph
clear 
s=load('../../mat_files/processed_runs.mat');
[ccruns,vcruns]=deal(s.ccruns,s.vcruns);
clr=lines();
cm=clr(1,:);
[  cunst,      cund,       cc,          ccslow,    chopf,   cfold]=deal(...
[1,0.2,0.2], [1,0.9,0], [1,0.6,0.4], [1 0.5 0.3], [1,1,1], [0,1,0]);
[cneg,bg]=deal(cunst/2,cm*1/3+2/3);
[shopf,sfold]=deal('s');
stab_names={...
    'stable','VC stable';...
    'ubyfold','$$\frac{\normalsize\mathrm{d}I_\mathrm{vc}}{\normalsize\mathrm{d}V_\mathrm{h}}<0$$';...
    'undet','VC stability undetermined';...
    'ubyhopf', sprintf('VC unstable by Hopf')}';
stab_struct=struct(stab_names{:});
stab_ic=[stab_names(1,:);num2cell(1:size(stab_names,2))];
stab_ind=struct(stab_ic{:});
stab_cl([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          cm,             cunst,          cneg,            cund};
stab_lw([stab_ind.stable,stab_ind.ubyhopf,stab_ind.ubyfold,stab_ind.undet])=...
        {          2,              2,               2,              2};
txt={'FontSize',16,'FontName','Courier','FontWeight','bold'};
ltx=[txt,{'Interpreter','latex'}];
ms={'MarkerSize',8};
%% Plot
fig=figure(2);clf;set(gcf,'color','white');ax=gca;
hold(ax,'on');
xbd=[min(cat(1,vcruns.Is))-30,max(cat(1,vcruns.Is))+30];
zbd=[min(cat(1,vcruns.Vs))-5,max(cat(1,vcruns.Vs))+3];
relcoord=@(bd,frac)bd(1)+frac*diff(bd);
%[labelx,labely]=deal(relcoord(xbd,0.02),relcoord(ybd,0.98));
bddeco={':','color',(clr(2,:)+1)/2,'linewidth',2};
cfac=50;
labelx=400;
cshift=@(i,v)(i-1)*cfac+v;
nruns=length(vcruns);
for i=1:nruns
    rv=vcruns(i);
    ibifs=sort([1;rv.i_fold;rv.i_hopf;length(rv.t)],'ascend');
    %isneg=idiff(i)>0;
    %iunst=unst(1,i):unst(2,i);
    ismall=rv.I<xbd(1);
    rv.I(ismall)=NaN;
    [rv.V,rv.Vs]=deal(cshift(i,rv.V),cshift(i,rv.Vs));
        % raw data of VC run
    pvcraw=plot(ax,rv.I,rv.V,'LineWidth',1,'color',bg,...
        'LineWidth',1,'DisplayName','VC raw');
    % stable parts of VC runs: above depolarization and below first bif
    rg=1:min([rv.i_hopf;rv.i_fold]);
    pstable=plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.stable},...
        'LineWidth',stab_lw{stab_ind.stable},'DisplayName',stab_struct.stable);
    rg=max([vcruns(i).i_hopf;vcruns(i).i_fold]):length(rv.Is);
    plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.stable},...
        'LineWidth',stab_lw{stab_ind.stable},'DisplayName',stab_struct.stable);
    % parts of VC run with undetermined stability
    pund=[];
    for k=2:2:length(rv.i_fold)
        rg=adjacent_bif(ibifs,rv.i_fold(k),+1);
        pund=plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.undet},...
            'LineWidth',stab_lw{stab_ind.undet},'DisplayName',stab_struct.undet);
    end
    % parts of VC run next to Hopf bifurcation
    rg=adjacent_bif(ibifs,rv.i_hopf(1),+1);
    punst=plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.ubyhopf},...
        'LineWidth',stab_lw{stab_ind.ubyhopf},'DisplayName',stab_struct.ubyhopf);
    rg=adjacent_bif(ibifs,rv.i_hopf(2),-1);
    plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.ubyhopf},...
        'LineWidth',stab_lw{stab_ind.ubyhopf},'DisplayName',stab_struct.ubyhopf);
    % parts of VC that are unstable for topolgical reasons
    pneg=[];
    for k=1:2:length(rv.i_fold)
        rg=rv.i_fold(k):rv.i_fold(k+1);
        pneg=plot(ax,rv.Is(rg),rv.Vs(rg),'Color',stab_cl{stab_ind.ubyfold},...
            'LineWidth',stab_lw{stab_ind.ubyfold},'DisplayName',stab_struct.ubyfold);
    end
    % fold bifurcations
    pfold=plot(ax,rv.Is(rv.i_fold),rv.Vs(rv.i_fold),sfold,...
        'Color','k','MarkerFaceColor',cfold,ms{:},...
            'LineWidth',1,'DisplayName','Fold');
    % Hopf bifurcations
    i_hopf=rv.i_hopf;
    [~,i_left]=adjacent_bif(ibifs,i_hopf(1),-1);
    if ismember(i_left,rv.i_fold)
        i_hopf=i_hopf(2:end);
    end
    phopf=plot(ax,rv.Is(i_hopf),rv.Vs(i_hopf),shopf,...
        'Color','k','MarkerFaceColor',chopf,ms{:},...
            'LineWidth',1,'DisplayName','Hopf');
    % 
    % plot(ax,rv.I,cshift(i,rv.I),'-','color',bg,'linewidth',1.5);    
    % plot(ax,rv.Is(~isneg),cshift(i,rv.Vs(~isneg)),'.','color',cm,'MarkerSize',6);
    % plot(ax,rv.Is(iunst),cshift(i,rv.V(iunst)),'.','color',cunst,'MarkerSize',7);
    % plot(ax,rv.Is(isneg),cshift(i,rv.V(isneg)),'.','color',cneg,'MarkerSize',8);
    % iri=find(rv.I>=labelx,1,'first');
    % labely=cshift(i,rv.V(iri));
    % text(ax,labelx,labely,sprintf('%d',i),'VerticalAlignment','top',...
    %     'FontName','Courier','FontWeight','bold','FontSize',12);
    % for k=1:2
    %     if isfinite(ind_hopf(k,i))
    %         plot(ax,Is{i,1}(ind_hopf(k,i)),cshift(i,vr{i}(ind_hopf(k,i),ip.V)),shopf,...
    %             'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');
    %     end
    %     if isfinite(ind_fold(k,i))
    %         plot(ax,Is{i,2}(ind_fold(k,i)),cshift(i,vr{i}(ind_fold(k,i),ip.V)),sfold,...
    %             'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');
    %     end
    % end
end
%%
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
ax.PlotBoxAspectRatio=[0.6,1,1];
txt={'Fontsize',16};
ltx=[{'Interpreter','LaTeX'},txt];
yl=ylabel('$V_\mathrm{h}$ (mV)',ltx{:});
xl=xlabel('$I_\mathrm{vc}$\,(pA)',ltx{:});
% lg=legend(ax,[vn,ve,vu,ve,vp,ve,vf,ve,vh,vsn],{...
%     sprintf('$$\\frac{\\mathrm{d}I_\\mathrm{vc}^{\\phantom{I}}}{\\mathrm{d}V_\\mathrm{h}}\\!<\\!0$$\nunstable'),...
%     '',...
%     sprintf('$I_\\mathrm{vc}(V_\\mathrm{h})$\npossibly\nunstable'),...
%     '',...
%     sprintf('$I_\\mathrm{vc}(V_\\mathrm{h})$\nstable'),...
%     '',...
%     sprintf('$I_\\mathrm{vc}(V_\\mathrm{h})$\nunfiltered'),...
%     '',...
%     'Hopf bif.',...
%     'fold bif.'...
%      },'Location','eastoutside',ltx{:});%,'NumColumns',2);
%lg.Position([1,2])=[0.36,0.185];
%lg.FontSize=12;
ybd=get(gca,'YLim');
text(xbd(1)+diff(xbd)*0.01,ybd(2)-diff(ybd)*0.01,'(c)',...
    'VerticalAlignment','top','HorizontalAlignment','left',ltx{:},'Fontsize',18);
%%
fig.Position(3:4)=[400,600]; % fix size of figure for repeatable plotting
folder=[pwd(),'/../../figures/'];
exportgraphics(fig,[folder,'Figure1c.pdf'],'ContentType','vector');
%%
function [rg,i_adj]=adjacent_bif(ibifs,ibifcur,pm)
icur=find(ibifs==ibifcur);
i_adj=ibifs(icur+pm*1);
rg=ibifcur:pm:i_adj;
end