%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.S4(c) of the supplemental material
%--------------------------------------------------------------------

%%% First download the simulated data:
%%% https://www.dropbox.com/scl/fi/cp7m5eh9sp4yxi63kp7hm/LossOfContact.dat?rlkey=u6o91qj4d9jjujcmty247o5xe&dl=1
%%% (about 140MB)
%%% Then load the simulated data
% vc=load('LossOfContact.dat');
% 
%%% form gc(t)
t=vc(:,1);gc0=20.0; gc1=5.5; coeff1=0.45; coeff2=0.01; tlossin=9500.0; 
tlossout=10500.0;k=0.1;
gc=gc0+(gc1-gc0)*(1+coeff1*sin(coeff2*t)).*(1.0./(1.0+exp(k*(tlossin-t)))).*...
    (1.0./(1.0+exp(k*(t-tlossout))));
%%% Plot data
plot(gc.*(vc(:,4)-vc(:,2)),vc(:,4),'k','linewidth',2);hold on;

%%% Colors
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([-10 150 -70 30]);
set(gca,'XTick',0:50:150);
set(gca,'YTick',-70:25:30);
ylabel('$V_\mathrm{h}$ (mV)','Interpreter','latex');
xlabel('$I_\mathrm{vc}$ (pA)','Interpreter','latex');

