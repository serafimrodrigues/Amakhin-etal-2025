function f = brus(x,p)

A  = p(1,:);
B  = p(2,:);
x1 = x(1,:);
x2 = x(2,:);

BB = x1.*(B - x1.*x2);

f(1,:) = A - BB - x1;
f(2,:) = BB;

end
