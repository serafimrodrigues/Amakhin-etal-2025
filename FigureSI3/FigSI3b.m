%---------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.SI3(b)
% note: Fig.SI3(a) is a copy of Fig.1(b), see the corresponding m-file
%---------------------------------------------------------------------

%%% First unzip the data file 
%%% Then load VC for cell #5
% c5vc=load('cell5VC.txt');

%%% First unzip the data file 
%%% Then load CC for cell #5
% c5cc=load('cell5CC.txt');

%%% define colors
clr=lines();
cm=clr(1,:)*0.9+[1,1,1]*0.1;
cneg=[0,0,0];
bg=cm*1/3+2/3;
or=[1 0.6 0.4];

%%% PLOT VC AFTER SMOOTHING
wsize=(20000);
for k=1:length(wsize)
smoothv5=smoothdata(c5vc(:,2),'movmean',wsize(k));
end

[ax,h1,h2]=plotyy(c5cc(:,1),c5cc(:,2),[c5vc(:,1),c5vc(:,1)],...
    [c5vc(:,2),smoothv5]);

%%% LAY-OUT
set(gcf,'color','white');
set(ax,'FontName','Courier','FontSize',16,'FontWeight','bold');
set(ax(1),'XLim',[24 25]);
set(ax(2),'XLim',[24 25]);
set(ax(1),'XTick',24:0.5:25);
set(ax(2),'XTick',24:0.5:25);
set(ax(1),'YLim',[-40 40]);
set(ax(2),'YLim',[-300 100]);
set(ax(1),'YTick',-40:40:40);
set(ax(2),'YTick',-300:200:100);
set(ax(2),'YColor',bg);
set(ax(1),'YColor',[1 0.6 0.4]);
set(h1,'color',or,'linewidth',2);
set(h2,'color',bg,'linewidth',2.5);



