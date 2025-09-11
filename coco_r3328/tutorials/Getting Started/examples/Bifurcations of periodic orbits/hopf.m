function f = hopf(x,p)

x1 = x(1,:);
x2 = x(2,:);
p1 = p(1,:);
p2 = p(2,:);

r2 = x1.^2+x2.^2;

f(1,:) = x1.*(p1+p2.*r2-r2.^2)-x2;
f(2,:) = x2.*(p1+p2.*r2-r2.^2)+x1;

end
