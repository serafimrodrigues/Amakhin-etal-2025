function f = VCCC(s,p)

% variables of the joint VC and CC model
% V, x1, Vh : VC protocol with slow variation in the feedback ref. sig.
is_sim=size(s,1)==6;
if is_sim
    [Vvc,x1vc,Vh,Vcc,x1cc,Ih]=deal(s(1),s(2),s(3),s(4),s(5),s(6));
else
    [Vcc,x1cc,Ih]=deal(s(1,:),s(2,:),s(3,:));
end
if is_sim
    dVvc=rhs(Vvc,x1vc,setfield(p,'epsh',p.epsVvc),p.gc*(Vvc-Vh));
    dVcc=rhs(Vcc,x1cc,setfield(p,'epsh',p.epsVcc),Ih);
    f=[dVvc;dVcc];
else
    f0=rhs(Vcc,x1cc,setfield(p,'epsh',p.epsVcc),Ih);
    f=f0(1:2,:);
end
% 
% % complete right-hand side of the model
% f = [fVvc;fx1vc;fVh;fVcc;fx1cc;fIh];
end
function dVx=rhs(V,x1,p,Iin)
[  V1,  V2,  V3,  V4,  gL,  VL,  gK,  VK,  gCa,  VCa,  C,  eps,  epsh]=deal(...
 p.V1,p.V2,p.V3,p.V4,p.gL,p.VL,p.gK,p.VK,p.gCa,p.VCa,p.C,p.eps,p.epsh);
% (in)activation functions
minfV  = 0.5*(1+tanh((V-V1)/V2));
x1infV = 0.5*(1+tanh((V-V3)/V4));
taux1V = 1./cosh((V-V3)/(2*V4));
% right-hand side of the system corresponding to the VC protocol
fV  = (-gL*(V-VL)-gK*x1.*(V-VK)-gCa.*minfV.*(V-VCa)+Iin)/C;
fx1 = eps*(x1infV-x1)./taux1V;
fh   = epsh+0*V;
dVx=[fV;fx1;fh];
end