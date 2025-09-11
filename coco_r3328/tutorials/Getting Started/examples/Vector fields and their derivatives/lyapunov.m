function y = lyapunov(data, x, p, v, k)

n = numel(x);
om = sqrt(k);
A = data.dfdxhan(x, p); va = v-1i*A*v/om;
va = va/norm(va);
vb = conj(va);
w = ([A-1i*om*eye(n) va; va' 0]\[eye(n); zeros(1,n)])'*[zeros(n,1); 1];

B = @(dx1, dx2) data.Dfdxdxhan(x, p, dx1, dx2);
C = @(dx1, dx2, dx3) data.Dfdxdxdxhan(x, p, dx1, dx2, dx3);
y = real(w'*(B(vb,(2*1i*om*eye(n)-A)\B(va,va))...
  -2*B(va,A\B(va,vb))+C(va,va,vb)))/2/om;

end
