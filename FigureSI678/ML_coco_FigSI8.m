%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to produce bifurcation diagram for Fig.SI8
%--------------------------------------------------------------------
%% check 1d bif diagram for Figure 4 with coco
base=[pwd(),'/../'];
startup_coco([pwd(),'/../coco_r3328']);
clear
format compact
[p.VK,  p.VL, p.VCa, p.gL, p.C, p.V1, p.V2, p.eps, p.gCa, p.V3, p.V4, p.gc, p.epsVvc, p.gK, p.epsVcc]=deal(...
-84.0, -60.0, 120.0, 2.0, 20.0, -1.2, 18.0, 0.04,   4.4,   2.0, 30.0,-150.0,  0.01,   12.0,  0.01);
%%% initial simulation
options=odeset('RelTol',1e-08,'AbsTol',1e-08);
tspan=[0 40000];
ini_cond=[-43.0 0.000103 -42.7 -43.0 0.000103 50.0];
[t,s]=ode45(@(t,s) VCCC(s,p),tspan,ini_cond,options);
s0=s(find(s(:,6)<100,1,'last'),:).';
x0=s0(4:end-1);
p0=s0(end);
%%
f=@(x,par)VCCC([x;par],p);
prob = coco_set(coco_prob, 'cont', 'PtMX',1000,'norm',inf);
coco(prob,'ep_run', 'ode', 'isol', 'ep', f,x0 , 'Ih', p0, 'Ih', [50,450]);
%%
HB = coco_bd_labs('ep_run', 'HB');
prob = coco_prob;
prob = coco_set(prob, 'coll', 'NTST',50,'NCOL',4,'MXCL',false);
prob = coco_set(prob, 'cont', 'PtMX',[0,500],'norm',inf,'h_max',1);
prob = ode_HB2po(prob, '', 'ep_run', HB(1));
prob = coco_add_event(prob,'UZ','Ih',250);
coco(prob, 'po_run', [], {'Ih','po.period'}, [50,450]);
%%
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
fig=figure(5);fig.Name='Figure SI8';clf;tl=tiledlayout(2,3,'TileSpacing','tight');
nexttile([2,2]);axbif=gca;
plot(axbif,s(:,6),s(:,4),'color',[1 0.6 0.4],'linewidth',1.5);hold on;
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
set(gca,'TickLabelInterpreter','latex',txt{:});
title(gca,'Firing periods',ltx{:})
% plot example solution
nexttile(6);
labex=coco_bd_labs('po_run','UZ');
po_ex=po_read_solution('po_run',labex(1));
plot([po_ex.tbp;po_ex.tbp+po_ex.T],[po_ex.xbp(:,1);po_ex.xbp(:,1)])
xlabel('time $t$',ltx{:});
ylabel('$V$',ltx{:})
set(gca,txt{:});
set(gca,'TickLabelInterpreter','latex',txt{:});
title(gca,sprintf('time profile at $I_h=$%5.2f',po_ex.p(1)),ltx{:})
fig.Position(3:4)=[900,400];
%
%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
%%% form Ivc
Ivc=p.gc*(s(:,1)-s(:,3));

%%% define colors
cm=clr(1,:);
cunst=[1,0.2,0.2];
cneg=cunst/2;
chopf=[1,1,1];
shopf='s';
cfold=[0,1,0];
sfold='s';
bg=cm*1/3+2/3;

%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
%%% plot the solution: (Vh~V) vs. (Ivc,Ih)
lw={'LineWidth',1.5};
mw={'MarkerSize',7,'MarkerEdgeColor','k'};
axis(axbif,[50 450 -70 40]);
plot(axbif,Ivc(500:19500,1),s(500:19500,3),    'color',cm,lw{:});hold(axbif,'on');
plot(axbif,Ivc(19500:47150,1),s(19500:47150,3),'color',cunst,lw{:});
plot(axbif,Ivc(47150:50500,1),s(47150:50500,3),'color',cm,lw{:});
plot(axbif,Ivc(19500,1),s(19500,3),shopf,'MarkerFaceColor',chopf,mw{:});
Idb=Ivc(47150,1);
plot(axbif,Idb,s(47150,3),shopf,'MarkerFaceColor',chopf,mw{:});
% add Idb
plot(axbif,Idb*[1,1],[axbif.YLim(1),s(47150,3)],'k:',lw{:});
axbif.XTick=sort([axbif.XLim(1):100:axbif.XLim(2),round(Idb)]);
axbif.XTickLabel{str2double(axbif.XTickLabel)==round(Idb)}='$I_\mathrm{db}$';
axbif.TickLabelInterpreter='latex';
% add legend entries
hbmark=findobj(axbif,'MarkerFaceColor',clr(2,:));
set(hbmark(1),'DisplayName','exact Hopf bif.');
psnmark=findobj(axbif,'MarkerFaceColor',clr(1,:));
set(psnmark(1),'DisplayName','exact SNLC');
legend(axbif,[hbmark(1),psnmark(1)],'Location','south',ltx{:});
%%% LAY-OUT
set(fig,'color','white');
ylabel(axbif,'$V_\mathrm{h}\approx V,\;V_\mathrm{cc}$ (mV)','Interpreter','latex');
xlabel(axbif,'$I_\mathrm{vc},\;I_\mathrm{h}$\,(pA)','Interpreter','latex');

