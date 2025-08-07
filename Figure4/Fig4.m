%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.4
%--------------------------------------------------------------------

%%% accuracy of the discretisation of the ODE
options=odeset('RelTol',1e-08,'AbsTol',1e-08);

%%% simulation
tspan=[0 40000];
ini_cond=[-43.0 0.000103 -42.7 -43.0 0.000103 50.0];
[t,s]=ode45(@(t,s) VCCC(t,s),tspan,ini_cond,options);

%%% form Ivc
gc=-150.0;
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
plot(s(500:end,6),s(500:end,4),          'color',[1 0.6 0.4],'linewidth',1.5);hold on;
plot(Ivc(500:19500,1),s(500:19500,3),    'color',cm,         'linewidth',1.5);hold on;
plot(Ivc(19500:47150,1),s(19500:47150,3),'color',cunst,      'linewidth',1.5);
plot(Ivc(47150:50500,1),s(47150:50500,3),'color',cm,         'linewidth',1.5);hold on;
plot(Ivc(19500,1),s(19500,3),shopf,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(Ivc(47150,1),s(47150,3),shopf,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([50 450 -70 40]);
set(gca,'XTick',50:100:450);
set(gca,'YTick',-70:27.5:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');


