function [imax,smax]=get_max(s,wsize)
if nargin<2
    wsize=10;
end
sm=smoothdata(s,'gauss',wsize);
smid=mean([max(sm),min(sm)]);
imax=find(diff(sign(diff(sm)))<0&sm(2:end-1)>smid);
smax=sm(imax+1);
end