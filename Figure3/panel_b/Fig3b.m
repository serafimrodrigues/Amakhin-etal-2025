%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.3(b)
%--------------------------------------------------------------------
clear
% parameters 
[p.gK,p.gNa,p.gL,p.Cm, p.VK, p.VNa,  p.VL,   p.k, p.deltaV,p.deltaI,p.phi]=deal(...
 9.0,  35.0, 0.1,   1,-90.0,  55.0, -65.0, -20.0,    0.01,    0.01,  5.0);

%%% accuracy of the discretisation of the ODE
options=odeset('RelTol',1e-05,'AbsTol',1e-05,'Vectorized','on');

%%% simulation
tspan=[0 8000];
ini_cond2=[-100.0 0.9987 0.003559 -100.175 -100.0 0.9987 0.003559 -3.5];
sol=ode15s(@(t,s) VCCCb(s,p),tspan,ini_cond2,options);
t=linspace(tspan(1),tspan(2),tspan(2)*10+1);
s2=deval(sol,t)';
%% form Ivc
I2vc=p.k*(s2(:,1)-s2(:,4));
indfold=find(diff(sign(diff(I2vc))));
geti=@(x,i)x(i,:);
dVdt=geti(VCCCb(s2',p),5);
dVdts=smoothdata(dVdt','movmedian',1,'SamplePoints',t)';
indcchopf=find(abs(dVdt-dVdts)>1e-1,1,'last');
Icchopf=s2(indcchopf,8);
indvchopf=find(I2vc<Icchopf,1,'last');
% define colors
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;
figure(1);clf;
%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
plot(s2(:,8),s2(:,5),'color',[1 0.6 0.4],'linewidth',1.5);hold on;
rg1=1:indfold(1);
plot(I2vc(rg1,1),s2(rg1,4),'color',cm,'linewidth',1.5);hold on;
rg2=indvchopf:size(s2,1);
plot(I2vc(rg2,1),s2(rg2,4),'color',cm,'linewidth',1.5);hold on;
rg3=indfold(1):indfold(2);
plot(I2vc(rg3,1),s2(rg3,4),'color',cneg,'linewidth',1.5);hold on;
rg4=indfold(2):indvchopf;
plot(I2vc(rg4,1),s2(rg4,4),'color',cunst,'linewidth',1.5);hold on;
plot(I2vc(indfold,1),s2(indfold,4),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
plot(I2vc(indvchopf,1),s2(indvchopf,4),sfold,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
%plot(I2vc(1:1549163,1),s2(1:1549163,4),'color',cm,'linewidth',1.5);hold on;
%plot(I2vc(1549163:1551304,1),s2(1549163:1551304,4),'color',cneg,'linewidth',1.5);hold on;
%plot(I2vc(1551304:1554080,1),s2(1551304:1554080,4),'color',cunst,'linewidth',1.5);hold on;
%plot(I2vc(1554080:1554600,1),s2(1554080:1554600,4),'color',cm,'linewidth',1.5);hold on;
%plot(I2vc(1549163,1),s2(1549163,4),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
%plot(I2vc(1551304,1),s2(1551304,4),sfold,'MarkerFaceColor',cfold,'MarkerSize',5,'MarkerEdgeColor','k');hold on;
%plot(I2vc(1554080,1),s2(1554080,4),sfold,'MarkerFaceColor',chopf,'MarkerSize',5,'MarkerEdgeColor','k');hold on;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([-10 40 -100 40]);
set(gca,'XTick', -10:10:40);
set(gca,'YTick',-100:35:40);
ylabel('$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');

