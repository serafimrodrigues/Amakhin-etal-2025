function dvs_norm=match_cc_slow(ccrun,wsize,ref)
if nargin<3
    ref=10;
end
vs_cc=ccrun.V;
tfine=meshfill(ccrun.t,ref);
vfine=interp1(ccrun.t,vs_cc,tfine,'linear');
for i=1:length(wsize)
    vs_cc=smoothdata(vfine,'gaussian',wsize(i),'SamplePoints',tfine);
end
F=interp1(tfine,vs_cc,'spline','pp');
Fp=dde_der(tfine,F);
vpfine=ppval(Fp,tfine);
for i=1:length(wsize)
    vpfine=smoothdata(vpfine,'gaussian',wsize(i),'SamplePoints',tfine);
end
Fps=interp1(tfine,vpfine,'spline','pp');
Fpp=dde_der(tfine,Fps);
tdmed=median(diff(ccrun.t));
dvs_cc=ppval(Fps,ccrun.t)*tdmed^0.5;
ddvs_cc=ppval(Fpp,ccrun.t)*tdmed;
dvs_norm=sqrt(dvs_cc.^2+ddvs_cc.^2);
end
function dp=dde_der(t,p)
t=t(:).';
td=meshfill(t,3);
xtd=ppval(p,td);
dp=interp1(t,dde_coll_eva(xtd,td,t,3,'diff',1),'spline','pp');
end

function newmesh=meshfill(tcoarse,degree)
%% fill coarse grid with uniform values from grid
grid=linspace(0,1,degree+1);
grid=grid(1:end-1);
append=tcoarse(end);
tcoarse=tcoarse(:)';
grid=grid(:);
dt=diff(tcoarse);
ndt=length(dt);
og=ones(length(grid),1);
ot=ones(ndt,1);
scal=dt;
addmesh=grid(:,ot).*scal(og,:);
repmesh=tcoarse(og,1:end-1)+addmesh;
newmesh=[repmesh(:)',append];
end
