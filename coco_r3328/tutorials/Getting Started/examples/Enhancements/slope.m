function y = slope(data, xbp, T0, T, ~, t)

m    = data.coll_seg.int.NCOL;
xdim = data.coll_seg.int.dim;
N    = data.coll_seg.maps.NTST;
tmi  = data.coll_seg.mesh.tmi;
tbp  = data.coll_seg.mesh.tbp;

% find interval
trs    = (t-T0)/T;
J = min(N, find(N*trs>=tmi, 1, 'last'));
xbpint = xbp((J-1)*xdim*(m+1)+(1:xdim*(m+1)));
tint   = tbp((J-1)*(m+1)+(1:m+1));
ts     = linspace(-1, 1, m+1)';

% interpolated point
s  = repmat(2*(trs-tint(1))/(tint(end)-tint(1))-1, [1 m+1 m+1]);
sj = repmat(reshape(ts, [1 m+1 1]), [1 1 m+1]);
sk = repmat(reshape(ts, [1 1 m+1]), [1 m+1 1]);

t1 = s-sk;
t2 = sj-sk;
idx = find(abs(t2)<=eps);
t1(idx) = 1;
t2(idx) = 1;

x = kron(prod(t1./t2, 3), eye(xdim))*xbpint;

% interpolated derivative
s  = repmat(2*(trs-tint(1))/(tint(end)-tint(1))-1, [1 m+1 m+1 m+1]);
sj = repmat(reshape(ts, [1 m+1 1 1]), [1 1 m+1 m+1]);
sk = repmat(reshape(ts, [1 1 m+1 1]), [1 m+1 1 m+1]);
sl = repmat(reshape(ts, [1 1 1 m+1]), [1 m+1 m+1 1]);

t3 = sj(:,:,:,1)-sk(:,:,:,1);
t4 = s-sl;
t5 = sj-sl;
idx1 = find(abs(t5)<=eps);
idx2 = find(abs(t3)<=eps);
idx3 = find(abs(sk-sl)<=eps);
t5(union(idx1, idx3)) = 1;
t4(union(idx1, idx3)) = 1;
t3(idx2) = 1;
t3       = 1.0./t3;
t3(idx2) = 0;

xt = kron(sum(t3.*prod(t4./t5, 4), 3), eye(xdim))*xbpint;

y = [t; x(data.idx); xt(data.idx)];

end
