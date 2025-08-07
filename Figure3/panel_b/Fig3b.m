%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.3(b)
%--------------------------------------------------------------------

%%% accuracy of the discretisation of the ODE
options=odeset('RelTol',1e-08,'AbsTol',1e-08);

%%% simulation
tspan=[0 8000];
ini_cond2=[-100.0 0.9987 0.003559 -100.175 -100.0 0.9987 0.003559 -3.5];
[t,s2]=ode23s(@(t,s) VCCCb(t,s),tspan,ini_cond2,options);

%%% form Ivc
k=-20.0;
I2vc=k*(s2(:,1)-s2(:,4));

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
plot(s2(:,8),s2(:,5),'color',[1 0.6 0.4],'linewidth',1.5);hold on;
plot(I2vc(1:1549163,1),s2(1:1549163,4),'color',cm,'linewidth',1.5);hold on;
plot(I2vc(1549163:1551304,1),s2(1549163:1551304,4),'color',cneg,'linewidth',1.5);hold on;
plot(I2vc(1551304:1554080,1),s2(1551304:1554080,4),'color',cunst,'linewidth',1.5);hold on;
plot(I2vc(1554080:1554600,1),s2(1554080:1554600,4),'color',cm,'linewidth',1.5);hold on;
plot(I2vc(1549163,1),s2(1549163,4),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(I2vc(1551304,1),s2(1551304,4),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(I2vc(1554080,1),s2(1554080,4),sfold,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([-10 40 -100 40]);
set(gca,'XTick', -10:10:40);
set(gca,'YTick',-100:35:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');

