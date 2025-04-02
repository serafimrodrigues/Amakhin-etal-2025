%---------------------------
% VC and CC in a type-2 case
% Sept '24
%---------------------------

% vcl=load('../../mat_files/vcruntype2.mat');ccl=load('../../mat_files/ccruntype2.mat');
x=vcl.t;
x=x/1000;
wsize=[200,300,400];
dsize=20; %% use this to adjust range of dI/dV<0
clear dIs Is
%
for k=1:length(wsize)
Is{k}=smoothdata(vcl.I,'movmedian',wsize(k));
dIs{k}=smoothdata(diff(Is{k}),'movmedian',dsize);
end
%
figure(1);clf;ax=gca;
hold(ax,'on');
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;
chopf=[1,1,1];
shopf='s';
%
plot(ccl.I,ccl.V,'color',[0.93 0.66 0.55]);hold on;
plot(ax,vcl.I,vcl.V,'-','color',bg,'linewidth',1.5);hold on;
plot(ax,Is{1}(1:2419),vcl.V(1:2419),'.','color',cm,'MarkerSize',6);hold on;
plot(ax,Is{1}(2419:3082),vcl.V(2419:3082),'.','color',cneg,'MarkerSize',6);hold on;
plot(ax,Is{1}(3082:end),vcl.V(3082:end),'.','color',cm,'MarkerSize',6);hold on;
plot(ax,Is{1}(2419),vcl.V(2417),sfold,'MarkerFaceColor',...
     cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(ax,Is{1}(3082),vcl.V(3082),sfold,'MarkerFaceColor',...
     cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
%
%%% lay-out
% axis([0 500 -80 20]);
hold off
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');
set(gcf,'color','white');
grid on
axis tight
axis([-100 400 -80 30]);
set(gca,'XTick',-100:125:400);
set(gca,'YTick',-80:27.5:30);
% 
%%%
% exportgraphics(figure(1),'type2.pdf','ContentType','vector','BackgroundColor','none');   


