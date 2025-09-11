function f = abc(x,p)

al = p(1,:);
si = p(2,:);
D  = p(3,:);
B  = p(4,:);
be = p(5,:);

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);

e3 = exp(x3);

f(1,:) = D.*(1-x1).*e3-x1;
f(2,:) = D.*(1-x1-si.*x2).*e3-x2;
f(3,:) = D.*B.*(1-x1+al.*si.*x2).*e3-x3.*(1+be);

end
