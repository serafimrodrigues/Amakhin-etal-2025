%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.2
%--------------------------------------------------------------------
clear
matfiles=[pwd(),'/../mat_files/'];
vcl_t2=load([matfiles,'vcruntype2.mat']);
ccl_t2=load([matfiles,'ccruntype2.mat']);
in=load('fig2a.mat');
x=vcl_t2.t;
x=x/1000;
wsize=200;
dsize=20; %% use this to adjust range of dI/dV<0
spike_threshold=25; % threshold for spike detection
vcl_t2.Is=smoothdata(vcl_t2.I,'movmedian',wsize);
ccl_t2.Vs=smoothdata(ccl_t2.V,'movmedian',wsize);
i_cc_t2_spike=find(abs(ccl_t2.V-ccl_t2.Vs)>spike_threshold);
i_cc_t2_hopf=i_cc_t2_spike([1,end]);
i_vc_t2_hopf=arrayfun(@(i)get_closest(vcl_t2.Is,ccl_t2.I(i)),i_cc_t2_hopf);
i_vc_t2_unst=i_vc_t2_hopf(1):i_vc_t2_hopf(end);
cc={[in.cc.x;in.cc.y]',[ccl_t2.I,ccl_t2.V]};
vcraw={[in.vcraw.x;in.vcraw.y]',[vcl_t2.I,vcl_t2.V]};
vcsmooth={[in.vcsmooth.x;in.vcsmooth.y]',[vcl_t2.Is,vcl_t2.V]};
vcunst={[in.vc_unst.x;in.vc_unst.y]',[vcl_t2.Is(i_vc_t2_unst),vcl_t2.V(i_vc_t2_unst)]};
%%
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
c_cc=in.cc.color;
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;
chopf=[1,1,1];
shopf='s';
%
%
figure(1);clf;set(gcf,'color','white');
tl=tiledlayout(1,2);
for k=1:2
    ax(k)=nexttile(k);
    hold(ax(k),'on');
    plot(ax(k),cc{k}(:,1),cc{k}(:,2),'color',c_cc,'linewidth',1);
    plot(ax(k),vcraw{k}(:,1),vcraw{k}(:,2),'color',bg,'linewidth',1.5);
    plot(ax(k),vcsmooth{k}(:,1),vcsmooth{k}(:,2),'color',cm,'linewidth',1.5);
    %plot(ax(k),Is{1}(1:2419),vcl_t2.V(1:2419),'.','color',cm,'MarkerSize',6);
    %plot(ax(k),Is{1}(2419:3082),vcl_t2.V(2419:3082),'.','color',cneg,'MarkerSize',6);
    %plot(ax(k),Is{1}(3082:end),vcl_t2.V(3082:end),'.','color',cm,'MarkerSize',6);
    %plot(ax(k),Is{1}(2419),vcl_t2.V(2417),shopf,'MarkerFaceColor',...
    %    chopf,'MarkerSize',5,'MarkerEdgeColor','k');
    %plot(ax(k),Is{1}(3082),vcl_t2.V(3082),shopf,'MarkerFaceColor',...
    %    chopf,'MarkerSize',5,'MarkerEdgeColor','k');
    % axis layout
    set(ax(k),'FontName','Courier','FontSize',16,'FontWeight','bold');
    ylabel(ax(k),'$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
    xlabel(ax(k),'$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');
    grid(ax(k),'on');
    axis(ax(k),'tight');
    axis(ax(k),[-100 400 -80 40]);
    set(ax(k),'XTick',-100:125:400);
    set(ax(k),'YTick',-80:40:40);
end

%%
function ind=get_closest(vec,val)
[~,ind]=min(abs(vec-val));
end