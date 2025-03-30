%-----------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.S5 (a3-a4-b3-b4) of the supplemental material
%-----------------------------------------------------------------------

% load data
% c51=importdata('cells 5-1 step depol.xlsx');

%--------
% cell 5
%--------
c5=c51(:,1:2);
%%% panel (a3): plot the time series
figure(1);
plot(c5(:,1),c5(:,2),'k');
set(gcf,'color','white');
set(gca,'FontName','courier','FontSize',16,'FontWeight','bold');
axis([0 3000 -80 60]);
set(gca,'XTick',0:1000:3000);
set(gca,'YTick',-80:70:60);
xlabel('$t$ (ms)','interpreter','latex');
ylabel('$V_{\mathrm{cc}}$ (mV)','interpreter','latex');
% extract the stimulation part
s5=c5(4557:53422,:);
% form the approx derivative V'
s5d=zeros(length(s5)-1,1);
for i=1:length(s5d)
    s5d(i,1)=(s5(i+1,2)-s5(i,2))/(s5(i+1,1)-s5(i,1));
end
%%% panel (a4): plot (V,V')
figure(2);
plot(s5(1:end-1,2),s5d(:,1),'k');
set(gcf,'color','white');
set(gca,'FontName','courier','FontSize',16,'FontWeight','bold');
axis([-50 50 -100 300]);
set(gca,'XTick',-50:50:50);
set(gca,'YTick',-100:200:300);
xlabel('$V_{\mathrm{cc}}$ (mV)','interpreter','latex');
ylabel('$V^{\prime}_{\mathrm{cc}}$ (mV/ms)','interpreter','latex');

%--------
% cell 1
%--------
c1=c51(:,3:4);
%%% panel (b3): plot the time series
figure(3);
plot(c1(:,1),c1(:,2),'k');
set(gcf,'color','white');
set(gca,'FontName','courier','FontSize',16,'FontWeight','bold');
axis([0 3000 -80 60]);
set(gca,'XTick',0:1000:3000);
set(gca,'YTick',-80:70:60);
xlabel('$t$ (ms)','interpreter','latex');
ylabel('$V_{\mathrm{cc}}$ (mV)','interpreter','latex');
% extract the stimulation part
s1=c1(3761:53424,:);
% form the approx derivative V'
s1d=zeros(length(s1)-1,1);
for i=1:length(s5d)
    s1d(i,1)=(s1(i+1,2)-s1(i,2))/(s1(i+1,1)-s1(i,1));
end
%%% panel (b4): plot (V,V')
figure(4);
plot(s1(1:end-1,2),s1d(:,1),'k');
set(gcf,'color','white');
set(gca,'FontName','courier','FontSize',16,'FontWeight','bold');
axis([-50 50 -100 300]);
set(gca,'XTick',-50:50:50);
set(gca,'YTick',-100:200:300);
xlabel('$V_{\mathrm{cc}}$ (mV)','interpreter','latex');
ylabel('$V^{\prime}_{\mathrm{cc}}$ (mV/ms)','interpreter','latex');

