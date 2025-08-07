%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.SI4(a,b)
%--------------------------------------------------------------------

%%% First download the simulated data:
%%% https://www.dropbox.com/scl/fi/pftmg09vt7i0i824kegjm/CurrentSpikes.dat?rlkey=katu5vsksv22bcdcid0f1ip2t&dl=1
%%% (about 130MB)
%%% Then load the simulated data:
% vc=load('CurrentSpikes.dat');
%
%%% Relevant parameter value
gc=20.0;

%------------
% Panel (a)
%------------
figure(1);
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
xlabel('$I_\mathrm{vc}$\,(pA)','Interpreter','latex');

%----------
% Panel (b)
%----------
figure(2);
plot(vc(:,1),gc.*(vc(:,4)-vc(:,2)),'k','linewidth',2);hold on;

%%% LAY-OUT
set(gcf,'color','white');
set(gca,'FontName','Courier','FontSize',16,'FontWeight','bold');
axis([9400 10300 -40 60]);
set(gca,'XTick',9400:225:10300);
set(gca,'YTick',-40:25:60);
xlabel('$t$ (ms)','Interpreter','latex');
ylabel('$I_\mathrm{vc}$\,(pA)','Interpreter','latex');


