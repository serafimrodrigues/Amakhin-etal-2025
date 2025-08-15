%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.2
%--------------------------------------------------------------------
clear
ic=struct('in',1,'t2',2);
matfiles=[pwd(),'/../mat_files/'];
vcl{ic.t2}=load([matfiles,'vcruntype2.mat']);
ccl{ic.t2}=load([matfiles,'ccruntype2.mat']);
vcvars_in=load('vcruns.mat');
ccvars_in=load('ccruns.mat');
vcvars=load([matfiles,'vcruns.mat']);
ccvars=load([matfiles,'ccruns.mat']);
cell_ind=3;
[vc_in,cc_in,ip]=deal(vcvars_in.vcruns(cell_ind).data,ccvars_in.ccruns(cell_ind).data,vcvars_in.ip);
ccl{ic.in}=struct('I',cc_in(:,ip.I),'V',cc_in(:,ip.V),'t',cc_in(:,ip.t));
vcl{ic.in}=struct('I',vc_in(:,ip.I),'V',vc_in(:,ip.V),'t',vc_in(:,ip.t));
%in=load('fig2a.mat');
%x=vcl_t2.t;
%x=x/1000;
wsize=200; % window size for smoothing
dsize=20; %% use this to adjust range of dI/dV<0
% thresholding: 
% 'spike' detect spike (deviation of I from Is in pA)
% 'isi' length of ISI (in ms) to count for break in spike train
% 'si' length (in ms) of spike train interval to count as persistent spike train
% (for Hopf detection)
thresholds=struct('spike',25,'isi',100,'si',300);
for i=1:2
    vcl{i}.Is=smoothdata(vcl{i}.I,'gaussian',wsize);
    vcl{i}.Is=smoothdata(vcl{i}.Is,'gaussian',wsize);
    ccl{i}.Vs=smoothdata(ccl{i}.V,'movmedian',wsize);
    [ind_cc_hopf{i},ind_vc_hopf{i},ind_vc_sp_unst{i}]=match_spikes(ccl{i},vcl{i},wsize/4,thresholds);
    ind_vc_fold{i}=find(diff(sign(diff(vcl{i}.Is))))'+1;
    ind_vc_bif{i}=sort([ind_vc_fold{i},ind_vc_hopf{i}]);
end
%%
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
cund=[1,0.9,0];
chopf=[1,1,1];
c_cc=[1 0.6 0.4];%in.cc.color;
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;
chopf=[1,1,1];
shopf='s';
txt={'FontSize',16};
ltx={'interpreter','latex','FontSize',18};
%
%
fig=figure(1);clf;set(gcf,'color','white');
tl=tiledlayout(1,2,'TileSpacing','tight','Padding','tight');
for k=1:2
    ax(k)=nexttile(k);
    hold(ax(k),'on');
    pcc=plot(ax(k),ccl{k}.I,ccl{k}.V,'color',c_cc,'linewidth',1,...
        'DisplayName','CC');
    pvraw=plot(ax(k),vcl{k}.I,vcl{k}.V,'color',bg,'linewidth',1.5,'DisplayName','VC unfiltered');
    pvstab=plot(ax(k),vcl{k}.Is,vcl{k}.V,'color',cm,'linewidth',1.5,...
        'DisplayName',sprintf('VC smoothed,\nstable'));
    pvhu=plot(ax(k),vcl{k}.Is(ind_vc_sp_unst{k}),vcl{k}.V(ind_vc_sp_unst{k}),...
        'color',cunst,'linewidth',1.5,'DisplayName',sprintf('VC smoothed,\nunst by Hopf'));
    for j=1:2:length(ind_vc_fold{k})-1
        rg=ind_vc_bif{k}(j):ind_vc_bif{k}(j+1)-1;
        pvtop=plot(ax(k),vcl{k}.Is(rg),vcl{k}.V(rg),'-',...
        'color',cneg,'linewidth',2.5,'DisplayName',sprintf('VC smoothed,\nunst by fold'));
    end
    for j=2:2:length(ind_vc_bif{k})-2
        rg=ind_vc_bif{k}(j):ind_vc_bif{k}(j+1)-1;
        pvund=plot(ax(k),vcl{k}.Is(rg),vcl{k}.V(rg),...
        'color',cund,'linewidth',2.5,'DisplayName',sprintf('VC smoothed,\nstab. undet.'));
    end
    %plot(ax(k),Is{1}(1:2419),vcl_t2.V(1:2419),'.','color',cm,'MarkerSize',6);
    %plot(ax(k),Is{1}(2419:3082),vcl_t2.V(2419:308-100,402),'.','color',cneg,'MarkerSize',6);
    %plot(ax(k),Is{1}(3082:end),vcl_t2.V(3082:end),'.','color',cm,'MarkerSize',6);
    %plot(ax(k),ccl{k}.I(ind_cc_hopf{k}),ccl{k}.Vs(ind_cc_hopf{k}),shopf,'MarkerFaceColor',...
    %    chopf,'MarkerSize',5,'MarkerEdgeColor','k');
    if ~isempty(ind_vc_fold{k})
        pfold=plot(ax(k),vcl{k}.Is(ind_vc_fold{k}),vcl{k}.V(ind_vc_fold{k}),sfold,'MarkerFaceColor',...
            cfold,'MarkerSize',5,'MarkerEdgeColor','k','DisplayName','fold');
    end
    if ~isempty(ind_vc_hopf{k})
        phopf=plot(ax(k),vcl{k}.Is(ind_vc_hopf{k}),vcl{k}.V(ind_vc_hopf{k}),shopf,'MarkerFaceColor',...
            chopf,'MarkerSize',5,'MarkerEdgeColor','k','DisplayName','Hopf');
    end
    %plot(ax(k),Is{1}(3082),vcl_t2.V(3082),shopf,'MarkerFaceColor',...
    %    chopf,'MarkerSize',5,'MarkerEdgeColor','k');
    % axis layout
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
lg=legend(ax(2),[pcc,pvraw,pvstab,pvhu,pvtop,pvund,pfold,phopf],'Location','layout');
lg.Layout.Tile='east';
%set(lg,'Position',[ax(2).Position(1)+ax(2).Position(3),lg.Position(2:4)]);
%%
fig.Position(3:4)=[982,325]; % fix size of figure for repeatable plotting
folder=[pwd(),'/../../PLoS-amakhin/PLoS revision/'];
exportgraphics(fig,[folder,'Figure2.pdf'],'ContentType','vector');
%%
function ind=get_closest(vec,val)
[~,ind]=min(abs(vec-val));
end