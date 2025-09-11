function f = VCCCb(s,p)

% variables of the joint VC and CC model
is_sim=size(s,1)>4;
svc=s(1:4,:);
if is_sim
    scc=s(5:8,:);
    [V2h,I2h]=deal(svc(end,:),scc(end,:));
else
    scc=svc;
    I2h=scc(end,:);
end
[V2vc,h2vc,n2vc,V2cc,h2cc,n2cc]=deal(svc(1,:),svc(2,:),svc(3,:),scc(1,:),scc(2,:),scc(3,:));
if is_sim
    fvc = rhs(V2vc,h2vc,n2vc,setfield(p,'deltah',p.deltaV),p.k*(V2vc-V2h));
    fcc = rhs(V2cc,h2cc,n2cc,setfield(p,'deltah',p.deltaI),I2h);
    f = [fvc;fcc];
else
    fcc = rhs(V2cc,h2cc,n2cc,setfield(p,'deltah',p.deltaI),I2h);
    f=fcc(1:3,:);
end    
% %
% % CC (in)activation functions
% alphamV2cc=0.1*(V2cc+35)./(1-exp(-0.1*(V2cc+35)));
% betamV2cc=4.0*exp(-0.0556*(V2cc+60));
% alphahV2cc=0.07*exp(-0.05*(V2cc+58));
% betahV2cc=1./(1+exp(-0.1*(V2cc+28)));
% alphanV2cc=0.01*(V2cc+34)./(1-exp(-0.1*(V2cc+34)));
% betanV2cc=0.125*exp(-0.0125*(V2cc+44));
% minfV2cc=alphamV2cc./(alphamV2cc+betamV2cc);
% hinfV2cc=alphahV2cc./(alphahV2cc+betahV2cc);
% ninfV2cc=alphanV2cc./(alphanV2cc+betanV2cc);
% tauhV2cc=1./(alphahV2cc+betahV2cc);
% taunV2cc=1./(alphanV2cc+betanV2cc);
% %
% % Ionic currents for Iclamp eqns
% IKiV2cc=gK*n2cc.^4.*(V2cc-VK);
% INaiV2cc=gNa*minfV2cc.^3.*h2cc.*(V2cc-VNa);
% ILiV2cc=gL*(V2cc-VL);
% 
% % right-hand side of the system corresponding to the CC protocol
% fV2cc = (-IKiV2cc-INaiV2cc-ILiV2cc+I2h)/Cm;
% fh2cc = phi*(hinfV2cc-h2cc)/tauhV2cc;
% fn2cc = phi*(ninfV2cc-n2cc)/taunV2cc;
% fI2h  = deltaI;

% complete right-hand side of the model
%f = [fvc;fcc];
end

function res = rhs(V,h2,n2,p,Iin)
% VC (in)activation functions
alpham=0.1*(V+35)./(1-exp(-0.1*(V+35)));
betam=4.0*exp(-0.0556*(V+60));
alphah=0.07*exp(-0.05*(V+58));
betah=1./(1+exp(-0.1*(V+28)));
alphan=0.01*(V+34)./(1-exp(-0.1*(V+34)));
betan=0.125*exp(-0.0125*(V+44));
minf=alpham./(alpham+betam);
hinf=alphah./(alphah+betah);
ninf=alphan./(alphan+betan);
tauh=1./(alphah+betah);
taun=1./(alphan+betan);
% Ionic currents for Vclamp eqns
IK=p.gK*n2.^4.*(V-p.VK);
INa=p.gNa*minf.^3.*h2.*(V-p.VNa);
IL=p.gL*(V-p.VL);
%
% right-hand side of the system corresponding to the VC protocol
fV = (-IK-INa-IL+Iin)/p.Cm;
fh = p.phi*(hinf-h2)./tauh;
fn = p.phi*(ninf-n2)./taun;
fd  = p.deltah+0*V;
res=[fV;fh;fn;fd];
end