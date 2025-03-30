%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.3a of the manuscript
%--------------------------------------------------------------------

%%% accuracy of the discretisation of the ODE
options=odeset('RelTol',1e-08,'AbsTol',1e-08);

%%% simulation
tspan=[0 30000];
ini_cond=[-69.0 0.000103 -69.75 -69.9 1000.0 -30.0];
[t,s]=ode45(@(t,s) VCCCa(t,s),tspan,ini_cond,options);

%%% form Ivc
gc=-40.0;
Ivc=gc*(s(:,1)-s(:,3));

%%% define colors
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;

%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
plot(s(:,6),s(:,4),'color',[1 0.6 0.4],                'linewidth',1.5);hold on;
plot(Ivc(1:13160,1),s(1:13160,3),'color',cm,           'linewidth',1.5);hold on;
plot(Ivc(13160:18624,1),s(13160:18624,3),'color',cneg, 'linewidth',1.5);hold on;
plot(Ivc(18624:29600,1),s(18624:29600,3),'color',cunst,'linewidth',1.5);
plot(Ivc(29600:31500,1),s(29600:31500,3),'color',cm,   'linewidth',1.5);hold on;
plot(Ivc(13160,1),s(13160,3),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(Ivc(18624,1),s(18624,3),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(Ivc(29600,1),s(29600,3),sfold,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([-20 250 -70 40]);
set(gca,'XTick',-20:67.5:250);
set(gca,'YTick',-70:27.5:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');
exportgraphics(figure(1),'ML_VC_CC.pdf','ContentType','vector','BackgroundColor','none');

