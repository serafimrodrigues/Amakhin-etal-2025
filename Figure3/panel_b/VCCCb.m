function f = VCCCb(t,s)

% variables of the joint VC and CC model
V2vc  = s(1);
h2vc  = s(2);
n2vc  = s(3);
V2h   = s(4);
V2cc  = s(5);
h2cc  = s(6);
n2cc  = s(7);
I2h   = s(8);

% parameters 
gK=9.0;gNa=35.0;gL=0.1;Cm=1;
VK=-90.0;VNa=55.0;VL=-65.0;
k=-20.0;deltaV=0.01;deltaI=0.01;
phi=5.0;

% (in)activation functions
alphamV2vc=0.1*(V2vc+35)./(1-exp(-0.1*(V2vc+35)));
betamV2vc=4.0*exp(-0.0556*(V2vc+60));
alphahV2vc=0.07*exp(-0.05*(V2vc+58));
betahV2vc=1./(1+exp(-0.1*(V2vc+28)));
alphanV2vc=0.01*(V2vc+34)./(1-exp(-0.1*(V2vc+34)));
betanV2vc=0.125*exp(-0.0125*(V2vc+44));
minfV2vc=alphamV2vc./(alphamV2vc+betamV2vc);
hinfV2vc=alphahV2vc./(alphahV2vc+betahV2vc);
ninfV2vc=alphanV2vc./(alphanV2vc+betanV2vc);
tauhV2vc=1./(alphahV2vc+betahV2vc);
taunV2vc=1./(alphanV2vc+betanV2vc);
%
alphamV2cc=0.1*(V2cc+35)./(1-exp(-0.1*(V2cc+35)));
betamV2cc=4.0*exp(-0.0556*(V2cc+60));
alphahV2cc=0.07*exp(-0.05*(V2cc+58));
betahV2cc=1./(1+exp(-0.1*(V2cc+28)));
alphanV2cc=0.01*(V2cc+34)./(1-exp(-0.1*(V2cc+34)));
betanV2cc=0.125*exp(-0.0125*(V2cc+44));
minfV2cc=alphamV2cc./(alphamV2cc+betamV2cc);
hinfV2cc=alphahV2cc./(alphahV2cc+betahV2cc);
ninfV2cc=alphanV2cc./(alphanV2cc+betanV2cc);
tauhV2cc=1./(alphahV2cc+betahV2cc);
taunV2cc=1./(alphanV2cc+betanV2cc);
%

% Ionic currents for Vclamp eqns
IKV2vc=gK*n2vc.^4.*(V2vc-VK);
INaV2vc=gNa*minfV2vc.^3.*h2vc.*(V2vc-VNa);
ILV2vc=gL*(V2vc-VL);
% Ionic currents for Iclamp eqns
IKiV2cc=gK*n2cc.^4.*(V2cc-VK);
INaiV2cc=gNa*minfV2cc.^3.*h2cc.*(V2cc-VNa);
ILiV2cc=gL*(V2cc-VL);

% right-hand side of the system corresponding to the VC protocol
fV2vc = (-IKV2vc-INaV2vc-ILV2vc+k*(V2vc-V2h))/Cm;
fh2vc = phi*(hinfV2vc-h2vc)/tauhV2vc;
fn2vc = phi*(ninfV2vc-n2vc)/taunV2vc;
fV2h  = deltaV;
% right-hand side of the system corresponding to the CC protocol
fV2cc = (-IKiV2cc-INaiV2cc-ILiV2cc+I2h)/Cm;
fh2cc = phi*(hinfV2cc-h2cc)/tauhV2cc;
fn2cc = phi*(ninfV2cc-n2cc)/taunV2cc;
fI2h  = deltaI;

% complete right-hand side of the model
f = [fV2vc;fh2vc;fn2vc;fV2h;fV2cc;fh2cc;fn2cc;fI2h];
