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