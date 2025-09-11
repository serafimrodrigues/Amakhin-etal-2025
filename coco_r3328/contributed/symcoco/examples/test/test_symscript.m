%% test sco_sym2funcs & sco_gen generated functions on symbolic expressions
clear 
if sco_isoctave()
    pkg load symbolic   % if octave is used load package symbolic
end
%% Hopf normal form
syms x1 x2 mu cre cim om
r2=x1^2+x2^2;
fhopf=[mu,-om;om,mu]*[x1;x2]+[cre,-cim;cim,cre]*[x1;x2]*r2
p=[mu;om;cre;cim];
x=[x1;x2];
hopfargs={fhopf,{x,p},{'x','p'},true(1,2)};
[fmt,err,fhandle,pairs]=sco_compare(hopfargs{:},{'x*v','p*q','x'},...
    'newf','dhopf','maxorder',3,'nvec',3)
[fmt2,err2,~,pairs2]=sco_compare(hopfargs{:},{'x'},...
    'newf',fhandle)
%% bistable demo
syms t x v gam a T 
fbistable=[v; -gam*v-x-x^3+a*cos(2*pi*t/T)];
bistable_args={fbistable,{t,[x;v],[T;a;gam]},{'t','x','p'},[0,1,1]};
[fmt3,err3,fhandle3,pairs3]=sco_compare(bistable_args{:},{'x','x','p'},...
    'newf','bistable','maxorder',5,'nvec',3)
[fmt4,err4,~,pairs4]=sco_compare(bistable_args{:},{'x'},...
    'newf',fhandle3,'nvec',4)
[fmt5,err5,~,pairs5]=sco_compare(bistable_args{:},{'t','x','p','p'},...
    'newf',fhandle3,'nvec',2)
%% Bratu
syms x xp p 
brat=[xp; -p*exp(x)];
bratuargs={brat,{[x;xp],p},{'x','p'},[1,1]};
[fmt6,err6,fhandle6,pairs6]=sco_compare(bratuargs{:},{'x'},...
    'newf','bratu','maxorder',5,'nvec',3)
[fmt7,err7,~,pairs7]=sco_compare(bratuargs{:},{'x','x','x','p'},...
    'newf',fhandle6,'nvec',2)

