%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to produce bifurcation diagram for Fig. SI7
%--------------------------------------------------------------------
%% check 1d bif diagram for Figure 3b with coco
startup_coco([pwd(),'/../coco_r3328']);
clear
format compact
%% Parameters (when setting eps=0.005 the Hopf bifurcation becomes more singular)
[p.gK,p.gNa,p.gL,p.Cm, p.VK, p.VNa,  p.VL,   p.k, p.deltaV,p.deltaI,p.phi]=deal(...
 9.0,  35.0, 0.1,   1,-90.0,  55.0, -65.0, -20.0,    0.01,    0.01,  5.0);
%% initial simulation
%sim=load('Fig3b.mat','s2','t'); 
%[t,s2]=deal(sim.t,sim.s2);
options=odeset('RelTol',1e-05,'AbsTol',1e-05,'Vectorized','on');
tspan=[0 8000];
ini_cond2=[-100.0 0.9987 0.003559 -100.175 -100.0 0.9987 0.003559 -3.5];
sol=ode15s(@(t,s) VCCCb(s,p),tspan,ini_cond2,options);
t=linspace(tspan(1),tspan(2),tspan(2)*10+1);
s2=deval(sol,t)';
%% select initial equilibrium near Ih=40 and continue equilibria
s0=s2(find(s2(:,8)<39,1,'last'),:).';
x0=s0(5:end-1);
p0=s0(end);
f=@(x,par)VCCCb([x;par],p);
prob = coco_set(coco_prob, 'cont', 'PtMX',1000,'norm',inf);
coco(prob,'ep_run', 'ode', 'isol', 'ep', f,x0 , 'Ih', p0, 'Ih', [-10,40]);
%% track periodic orbits
HB = coco_bd_labs('ep_run', 'HB');
prob = coco_prob;
prob = coco_set(prob, 'coll', 'NTST',200,'NCOL',4,'TOL',1e0);%'MXCL',false);
prob = coco_set(prob, 'cont', 'PtMX',[0,1000],'norm',inf,'h_max',10);
prob = ode_HB2po(prob, '', 'ep_run', HB);
prob = coco_add_event(prob,'UZ','Ih',10);
coco(prob, 'po_run', [], {'Ih','po.period'}, {[-20,250],[0,30]});
%% Plot: overlay simulation and bifurcation diagram
clr=lines();
txt={'Fontsize',16};
ltx=[txt,{'Interpreter','latex'}];
theme_ep = struct();
theme_ep.special = {'HB','SN'};
theme_ep.SN={'ks','MarkerFaceColor',clr(1,:),'MarkerSize',8,'DisplayName','EP Fold'};
theme_ep.HB={'ko','MarkerFaceColor',clr(2,:),'MarkerSize',8,'DisplayName','Hopf'};
theme_po = struct();
theme_po.lspec = {{'k-', 'LineWidth', 1}, {'k--', 'LineWidth', 1}};
theme_po.special = {'SN'};
theme_po.SN={'ko','MarkerFaceColor',clr(1,:),'MarkerSize',8,'DisplayName','P5 Fold'};
fig=figure(4);fig.Name='Figure SI7';clf;tl=tiledlayout(2,3,'TileSpacing','tight');
nexttile([2,2]);axbif=gca;
plot(axbif,s2(:,8),s2(:,5),'color',[1 0.6 0.4],'linewidth',1.5);hold on;
coco_plot_bd(theme_po, 'po_run', 'Ih','MIN(x)');
coco_plot_bd(theme_po, 'po_run', 'Ih','MAX(x)');
coco_plot_bd(theme_ep, 'ep_run', 'Ih','x');
xlabel('$I_h$',ltx{:})
ylabel('$\min$ \& $\max V_\mathrm{cc}$',ltx{:})
set(axbif,txt{:});
title(axbif,'Bifurcation diagram',ltx{:})
% plot period as function of parameter
nexttile(3);
coco_plot_bd(theme_po, 'po_run', 'Ih','po.period');
xlabel('$I_h$',ltx{:})
ylabel('period $T$',ltx{:})
set(gca,txt{:});
set(gca,'TickLabelInterpreter','latex',txt{:});
title(gca,'Firing periods',ltx{:})
% plot example solution
nexttile(6);
labex=coco_bd_labs('po_run','UZ');
po_ex=po_read_solution('po_run',labex);
plot([po_ex.tbp;po_ex.tbp+po_ex.T],[po_ex.xbp(:,1);po_ex.xbp(:,1)])
xlabel('time $t$',ltx{:});
ylabel('$V_\mathrm{cc}$',ltx{:})
set(gca,txt{:});
set(gca,'TickLabelInterpreter','latex',txt{:});
title(gca,sprintf('time profile at $I_h=$%5.2f',po_ex.p(1)),ltx{:})
fig.Position(3:4)=[900,400];
%
%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
% form Ivc
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
lw={'LineWidth',1.5};
mw={'MarkerSize',7,'MarkerEdgeColor','k'};

%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
axis(axbif,[-10 40 -100 40]);
set(axbif,'XTick', -10:10:40);
set(axbif,'YTick',-100:35:40);
rg1=1:indfold(1);
plot(axbif,I2vc(rg1,1),s2(rg1,4),'color',cm,lw{:});hold(axbif,'on');
rg2=indvchopf:size(s2,1);
plot(axbif,I2vc(rg2,1),s2(rg2,4),'color',cm,lw{:});
rg3=indfold(1):indfold(2);
plot(axbif,I2vc(rg3,1),s2(rg3,4),'color',cneg,lw{:});
rg4=indfold(2):indvchopf;
plot(axbif,I2vc(rg4,1),s2(rg4,4),'color',cunst,lw{:});
plot(axbif,I2vc(indfold,1),s2(indfold,4),sfold,'MarkerFaceColor',cfold,mw{:});
plot(axbif,I2vc(indvchopf,1),s2(indvchopf,4),sfold,'MarkerFaceColor',chopf,mw{:});
% add Idb
Idb=I2vc(indvchopf,1);
plot(axbif,Idb*[1,1],[axbif.YLim(1),s2(indvchopf,4)],'k:',lw{:});
axbif.XTick=sort([linspace(axbif.XLim(1),axbif.XLim(2),6),round(Idb)]);
axbif.XTickLabel{str2double(axbif.XTickLabel)==round(Idb)}='$I_\mathrm{db}$';
axbif.TickLabelInterpreter='latex';
% add legend entries
fpmark=findobj(axbif,'MarkerFaceColor',[0,1,0]);
set(fpmark(1),'DisplayName','fold est. from VC');
hbmark=findobj(axbif,'MarkerFaceColor',clr(2,:));
set(hbmark(1),'DisplayName','exact Hopf bif.');
%psnmark=findobj(axbif,'MarkerFaceColor',clr(1,:));
%set(psnmark(1),'DisplayName','exact SNLC');
legend(axbif,[hbmark(1),fpmark(1)],'Location','south',ltx{:});
%%% LAY-OUT
set(gcf,'color','white');
set(axbif,'FontName','Courier','FontSize',16,'FontWeight','bold');
ylabel(axbif,'$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel(axbif,'$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');

