function f = VCCCa(t,s)

% variables of the joint VC and CC model
% V, x1, Vh : VC protocol with slow variation in the feedback ref. sig.
Vvc  = s(1);
x1vc = s(2);
Vh   = s(3);
Vcc  = s(4);
x1cc = s(5);
Ih   = s(6);

% parameters 
VK=-84.0;VL=-60.0;VCa=120.0;gL=2.0;C=20.0;V1=-1.2;V2=18.0;
eps=0.067;gCa=4.0;V3=12.0;V4=17.4;gc=-40.0;epsVvc=0.01;gK=12.0;epsVcc=0.01;

% (in)activation functions
minfVvc  = 0.5*(1+tanh((Vvc-V1)/V2));
x1infVvc = 0.5*(1+tanh((Vvc-V3)/V4));
taux1Vvc = 1/cosh((Vvc-V3)/(2*V4));
minfVcc  = 0.5*(1+tanh((Vcc-V1)/V2));
x1infVcc = 0.5*(1+tanh((Vcc-V3)/V4));
taux1Vcc = 1/cosh((Vcc-V3)/(2*V4));

% right-hand side of the system corresponding to the VC protocol
fVvc  = (-gL*(Vvc-VL)-gK*x1vc*(Vvc-VK)-gCa*minfVvc*(Vvc-VCa)+gc*(Vvc-Vh))/C;
fx1vc = eps*(x1infVvc-x1vc)/taux1Vvc;
fVh   = epsVvc;
% right-hand side of the system corresponding to the CC protocol
fVcc  = (-gL*(Vcc-VL)-gK*x1cc*(Vcc-VK)-gCa*minfVcc*(Vcc-VCa)+Ih)/C;
fx1cc = eps*(x1infVcc-x1cc)/taux1Vcc;
fIh   = epsVcc;

% complete right-hand side of the model
f = [fVvc;fx1vc;fVh;fVcc;fx1cc;fIh];
