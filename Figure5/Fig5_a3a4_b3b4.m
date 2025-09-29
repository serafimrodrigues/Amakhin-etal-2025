%-----------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to reproduce Fig.5(a3-a4-b3-b4)
% notes: Fig.5(a1) is a zoom of Fig.1(b), see the corresponding m-file
%        Fig.5(a2) is a zoom of Fig.SI1(a), see the corresponding m-file
%-----------------------------------------------------------------------
clear
%% Load data
% depolarization runs for cells 5,1
c51=importdata('cells_5-1_step_depol.xlsx');
%c5slow=load('../Figure1/panel_b/cell5.txt');
%c1slow=load('../FigureSI1/panel_a/cell1.txt');
%% ramped runs
s=load('../mat_files/vcruns.mat','vcruns','ip','xnames');
[vcloadruns,ip,xnames]=deal(s.vcruns,s.ip,s.xnames);
s=load('../mat_files/ccruns.mat','ccruns');
ccloadruns=s.ccruns;
runsel=[4,5];% icellorder =[  5     1     3     2     4]; sel=icellorder([5,1]);
ccloadruns=ccloadruns(runsel);
vcloadruns=vcloadruns(runsel);
%% process ramped runs
% smoothing, curring off
bd.I=[-Inf,450];
bd.t=[0,60];
bd.V=[-Inf,Inf];
geti=@(x,i)x(i);
checkbd=@(x,s)x(:,ip.(s))>geti(bd.(s),1)&x(:,ip.(s))<geti(bd.(s),2);
xchecktI=@(x)x(checkbd(x,'I')&checkbd(x,'t'),:);
nruns=length(vcloadruns);
%%% filter VC runs with various window lengths
wsize_vc=[5000,15000,16000];
isnames={'I0';1};
for k=1:length(wsize_vc)
    for i=nruns:-1:1
        tmp=vcloadruns(i).data;
        vr{i}=xchecktI(tmp);
        Ivc{i,k}=smoothdata(vr{i}(:,ip.I),'movmedian',wsize_vc(k));
    end
    isnames=[isnames,{['I',num2str(k)];k+1}];
end
wsize_cc=1500;
cslow=arrayfun(@(r){xchecktI(r.data)},ccloadruns);
[vcruns,ccruns]=deal(cell(nruns,1));
for i=length(cslow):-1:1
    Icc{i}=smoothdata(cslow{i}(:,ip.I),'movmean',wsize_cc);
    ccruns{i}=[Icc{i},cslow{i}(:,ip.V)];
    vcruns{i}=[vr{i}(:,ip.I),Ivc{i,:},vr{i}(:,ip.V)];
end
ircc=struct('I',1,'V',2);
irvc=struct(isnames{:},'V',size(isnames,2)+1);
%% extract the stimulation part
c1=c51(:,3:4);
c5=c51(:,1:2);
ist=struct('t',1,'V',2,'dVdt',3);
cstep_all={c5,c1};
clear chigh
for k=nruns:-1:1
    rg_high{k}=find(cstep_all{k}(:,ist.t)>100&cstep_all{k}(:,ist.t)<1600);
    rx{k,1}=find(cstep_all{k}(:,ist.t)<=100);
    rx{k,2}=find(cstep_all{k}(:,ist.t)>=1600);
    setdiff(1:size(cstep_all{k},1),rg_high{k});
    chigh{k}=cstep_all{k}(rg_high{k},:);
    % form the approx derivative V'
    %chVs=smoothdata(chigh{k}(:,ist.V),'gaussian',5);
    chVs=chigh{k}(:,ist.V);
    chigh{k}(:,ist.dVdt)=[diff(chVs)./diff(chigh{k}(:,ist.t));NaN];
    osc_rg{k}=[min(chigh{k}(ceil(end/2):end,2)),max(chigh{k}(ceil(end/2):end,2))];
    ind2{k}=ceil(length(chigh{k})/3):length(chigh{k});
    ind1{k}=1:ceil(length(chigh{k})/3);
end
%rx1=setdiff(1:size(c1,1),rg1);
%s1=c1(rg1,:);
% form the approx derivative V'
%s1d=zeros(length(s1)-1,1);
%for i=1:length(s5d)
%    s1d(i,1)=(s1(i+1,2)-s1(i,2))/(s1(i+1,1)-s1(i,1));
%end
%vrg1=[min(s1(ceil(end/2):end,2)),max(s1(ceil(end/2):end,2))];
%% % Plot CC after smoothing
%%
fig=figure(1);clf;
fig.Position(3:4)=[920,625]; % fix size of figure for repeatable plotting
set(gcf,'color','white');
[nrows,ncols]=deal(3,2);
[lab,cell_nr]=deal({'a','b'},{'cell 5','cell 1'});
tl=tiledlayout(nrows,ncols,"TileSpacing","tight","Padding","tight");
ltx={'fontsize',18,'interpreter','latex'};
txt={'FontName','courier','FontSize',16,'FontWeight','bold','linewidth',1};
ccrcol={'color',[1 0.6 0.4]};
clr=lines();
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
[chopf,shopf,cfold,sfold]=deal([1,1,1],'s',[0,1,0],'s');
bg=cm*1/3+2/3;
ini_cl={'-','Color',bg,'linewidth',2};
tr_cl={'Color',cm,'linewidth',1};
osc_cl={'Color',0*[1,1,1],'linewidth',1};
ttick=1000*(0:2);
[vccdtick,vccd_bd]=deal(-80:70:60,[-80,70]);
[vccxtick,vccytick]=deal(50*(-1:1),100*[-1,0,1,3]);
[xbifbd,ybifbd,xbiftick,ybiftick,ybifzoomtick]=deal([-20,450],[-80,40],200*(0:2),40*(-2:1),40*(-1:1));
[zoomc,zoomwh]=deal(200,5);
%zbd=[min(cat(1,Vall{:}))-5,max(cat(1,Vall{:}))+3];
bddeco={':','color',(clr(2,:)+1)/2,'linewidth',2};
pa=@(tk,s)tk(1)+diff(tk([1,end]))*s;
pa1=@(tk)pa(tk,0.01);
pe=@(tk,s)tk(end)-diff(tk([1,end]))*s;
pe1=@(tk)pe(tk,0.01);
plabels=char(reshape('a'+(0:5),2,3)');
labpostv=[pa1(ttick),pe1(vccd_bd)];
labposvvp=[pa1(vccxtick),pe1(vccytick)];
labposbif=[pa1(xbifbd),pe1(ybifbd)];
txtpostv=[pe1(ttick),pe1(vccdtick)];
txtposvvp=[pe1(vccxtick),pe1(vccytick)];
txtposbif=[pe1(xbifbd),pe1(ybifbd)];
ihtxt=' $I_\mathrm{h}=200$\,pA';
zshift=@(obj,val)set(obj,'ZData',val+0*obj.XData);
%--------
% cell 5
%--------
for k=1:nruns
    %%% panel (a/b1): plot the time series
    ax(1,k)=nexttile(k);
    pl_tr=plot(ax(1,k),chigh{k}(ind1{k},ist.t),chigh{k}(ind1{k},ist.V),tr_cl{:},...
        'DisplayName','$0.1$--$0.6$\,s');
    hold(ax(1,k),'on');
    pl_osc=plot(ax(1,k),chigh{k}(ind2{k},ist.t),chigh{k}(ind2{k},ist.V),osc_cl{:},...
        'DisplayName','$0.6$--$1.6$\,s');
    pl_ini=plot(ax(1,k),cstep_all{k}(rx{k,1},ist.t),cstep_all{k}(rx{k,1},ist.V),...
        ini_cl{:},'DisplayName','$I_\mathrm{h}$ off');
    plot(ax(1,k),cstep_all{k}(rx{k,2},ist.t),cstep_all{k}(rx{k,2},ist.V),ini_cl{:});
    set(ax(1,k),'XTick',ttick,'YTick',vccdtick,txt{:},...
        'xlim',ttick([1,end]),'ylim',vccd_bd);
    xlabel(ax(1,k),'$t$ (ms)',ltx{:});%,'Position',[1.5e3,pa(vccdtick,-0.02),0],...
    %'HorizontalAlignment','center','VerticalAlignment','top');
    yticklab(k,ax(1,:),'$V_{\mathrm{cc}}$ (mV)');
    text(ax(1,k),labpostv(1),labpostv(2),['(',plabels(1,k),')',ihtxt],'VerticalAlignment','top',ltx{:});
    text(ax(1,k),txtpostv(1),txtpostv(2),cell_nr{k},'VerticalAlignment','top','HorizontalAlignment','right',ltx{:});
    %%%  plot (V,V')
    ax(2,k)=nexttile(ncols+k);
    plot(ax(2,k),chigh{k}(ind1{k},ist.V),chigh{k}(ind1{k},ist.dVdt),'-',tr_cl{:},'LineWidth',1);
    hold(ax(2,k),'on');
    plot(ax(2,k),chigh{k}(ind2{k},ist.V),chigh{k}(ind2{k},ist.dVdt),'-',osc_cl{:},'LineWidth',1);
    set(ax(2,k),'XTick',vccxtick,'YTick',vccytick,txt{:},'xlim',vccxtick([1,end]),'ylim',vccytick([1,end]));
    yline(ax(2,k),0,'k--');
    xline(ax(2,k),0,'k--');
    xlabel(ax(2,k),'$V_{\mathrm{cc}}$ (mV)','interpreter','latex');
    yticklab(k,ax(2,:),'$V^{\prime}_{\mathrm{cc}}$ (mV/ms)');
    text(ax(2,k),labposvvp(1),labposvvp(2),['(',plabels(2,k),')',ihtxt],'VerticalAlignment','top',ltx{:});
    text(ax(2,k),txtposvvp(1),txtposvvp(2),cell_nr{k},'VerticalAlignment','top','HorizontalAlignment','right',ltx{:});
    hold(ax(2,k),'on');
    %%% repeat bifurcation diagram (VC and CC protocols)
    ax(3,k)=nexttile(2*ncols+k);
    pcc=plot(ax(3,k),ccruns{k}(:,ircc.I),ccruns{k}(:,ircc.V),ccrcol{:},'DisplayName','CC');
    hold(ax(3,k),'on');
    xline(ax(3,k),zoomc+zoomwh*[-1,1],'k-');
    pvc0=plot(ax(3,k),vcruns{k}(:,irvc.I0),vcruns{k}(:,irvc.V),'Color',bg,'DisplayName','VC (unfiltered)');
    pvc1=plot(ax(3,k),vcruns{k}(:,irvc.I1),vcruns{k}(:,irvc.V),'Color',bg/2,'linewidth',2,'DisplayName','VC (smoothed)');
    plot(ax(3,k),zoomc*[1,1],osc_rg{k},'k+:','LineWidth',1)
    text(ax(3,k),labposbif(1),labposbif(2),['(',plabels(3,k),')'],'VerticalAlignment','top',ltx{:});
    tcell=text(ax(3,k),txtposbif(1),txtposbif(2),cell_nr{k},'VerticalAlignment','top','HorizontalAlignment','right',ltx{:});
    xlabel(ax(3,k),'$I_{\mathrm{vc}}$, $I_\mathrm{h}$ (pA)','interpreter','latex');
    yticklab(k,ax(3,:),'$V_\mathrm{h}\approx V$, $V_\mathrm{cc}$ (mV)');
    set(ax(3,k),'XLim',xbifbd,'YLim',ybifbd,'XTick',xbiftick(1:end-1),'YTick',ybiftick,txt{:});
    if k==1
        ax3p=ax(3,1).Position;
        lg3=legend(ax(3,1),[pcc,pvc0,pvc1],'FontSize',10);
        lg3.Position([1,2])=[ax3p(1)+ax3p(3)*0.97-lg3.Position(3),ax3p(2)+ax3p(4)*0.9];
        tcell.Position(2)=pe(ybifbd,0.1);
    end
end
%% determine maxima of voltage spikes and insert markers for half-decay time
hvo={'HandleVisibility','off'};
lprop={'r-','linewidth',1,hvo{:}};
lprop2={'-','Color',[1,0.5,0.5],'linewidth',2.5,hvo{:}};
itau=2;
for k=nruns:-1:1
    [imx{k},ymx{k}]=get_max(chigh{k}(:,ist.V));
    xmx{k}=chigh{k}(imx{k},ist.t);
    [xtargvec{k},xhalfvec{k},ytargvec{k},yhalfvec{k},yeq(k),ieq(k)]=halfdecays(xmx{k},ymx{k});
    [xtarg(k),xhalf(k),ytarg(k),yhalf(k)]=deal(xtargvec{k}(itau),xhalfvec{k}(itau),ytargvec{k}(itau),yhalfvec{k}(itau));
end
for k=1:nruns
    pyt(k)=plot(ax(1,k),[0,xtarg(k)],ytarg(k)*[1,1],lprop{:});
    zshift(pyt(k),-1);
    pyt2(k)=plot(ax(1,k),xtarg(k)*[1,1],[ytarg(k),vccdtick(1)],lprop2{:});
    zshift(pyt2(k),-1);
    pyh(k)=plot(ax(1,k),[0,xhalf(k)],yhalf(k)*[1,1],lprop{:});
    zshift(pyh(k),-1);
    pyh2(k)=plot(ax(1,k),xhalf(k)*[1,1],[yhalf(k),vccdtick(1)],lprop2{:});
    zshift(pyh2(k),-1);
    pyeq(k)=plot(ax(1,k),[0,xmx{k}(ieq(k))],yhalf(k)*2-ytarg(k)*[1,1],lprop{:});
    zshift(pyeq(k),-1);
    plevel(k)=plot(ax(1,k),[xtarg(k),xhalf(k)],pa(vccdtick,0.02)*[1,1],lprop{:},'Clipping','off');
    zshift(plevel(k),1);
    text(ax(1,k),0.5*(xtarg(k)+xhalf(k)),pa(vccdtick,-0.01),'$\tau_{1/2}$',...
        'HorizontalAlignment','center','VerticalAlignment','top',ltx{:},'Color','r');
    text(ax(1,k),0.5*(xtarg(k)+xhalf(k)),plevel(k).YData(1),'$\leftrightarrow$',...
        'HorizontalAlignment','center','VerticalAlignment','middle',ltx{:},'Color','r');
    text(ax(1,k),0,yhalf(k),'$\rightarrow$','HorizontalAlignment','right','VerticalAlignment','middle',ltx{:},'Color','r');
end
%% add zoom-in's 
for k=nruns:-1:1
    ax3p=ax(3,k).Position;
    ax(4,k)=axes('Parent',figure(1),'Box','on',...
        'Position',[ax3p(1)+ax3p(3)*0.59,ax3p(2)-ax3p(4)*0.04,ax3p(3)*0.42,ax3p(4)*0.4]);
    selcc=ccruns{k}(:,ircc.I)>zoomc-zoomwh&ccruns{k}(:,ircc.I)<zoomc+zoomwh;
    plot(ax(4,k),ccruns{k}(selcc,ircc.I),ccruns{k}(selcc,ircc.V),ccrcol{:},'linewidth',1.5);
    hold(ax(4,k),'on');
    selvc0=vcruns{k}(:,irvc.I0)>zoomc-zoomwh&vcruns{k}(:,irvc.I0)<zoomc+zoomwh;
    selvc1=vcruns{k}(:,irvc.I1)>zoomc-zoomwh&vcruns{k}(:,irvc.I1)<zoomc+zoomwh;
    plot(ax(4,k),vcruns{k}(selvc0,irvc.I0),vcruns{k}(selvc0,irvc.V),'Color',bg,'Linewidth',1.5);
    plot(ax(4,k),vcruns{k}(selvc1,irvc.I1),vcruns{k}(selvc1,irvc.V),'Color',bg/2,'Linewidth',2);
    set(ax(4,k),'XTick',zoomc+zoomwh*(-1:1),'YTick',40*(-1:1),txt{:},...
        'ylim',ybifzoomtick([1,end]),'linewidth',1,'FontSize',10,'XColor',cm,'YColor',cm)
end
%% add legends
ax1p=ax(1,1).Position;
lg1=legend(ax(1,1),[pl_tr,pl_osc,pl_ini],ltx{:},'FontSize',13,'Location','South','NumColumns',2);
%%
folder=[pwd(),'/../../PLoS-amakhin/PLoS revision/'];
exportgraphics(fig,[folder,'Figure5.pdf'],'ContentType','vector');
%%
function yticklab(k,ax,txt)
if k==1
    ylabel(ax(k),txt,'interpreter','latex');
else
    ax(k).YTickLabel={};
end
end
%%
function [imax,smax]=get_max(s,wsize)
if nargin<2
    wsize=10;
end
sm=smoothdata(s,'gauss',wsize);
smid=mean([max(sm),min(sm)]);
imax=find(diff(sign(diff(sm)))<0&sm(2:end-1)>smid);
smax=sm(imax+1);
end
%%
function [xtarg,xhalf,ytarg,yhalf,yeq,ieq1]=halfdecays(x,y,stdfac)
if nargin<3
    stdfac=4;
end
nx=length(x);
wsize=ceil(nx/4);
ys=smoothdata(y,'rloess',wsize);
ieq=ceil(nx/2):nx;
yeq=mean(ys(ieq));
ystd=std(y(ieq));
ieq1=ieq(1);
itran=find(ys>yeq+ystd*stdfac);
itarg=find((y(itran).'-yeq)/2>ystd*stdfac);
ytarg=y(itarg);
xtarg=x(itarg);
xhalf=interp1(ys(itran)-yeq,x(itran),(ytarg-yeq)/2,'nearest','extrap');
yhalf=interp1(x(itran),y(itran),xhalf,'nearest','extrap');
end