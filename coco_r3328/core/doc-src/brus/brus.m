function y = brus(x,p)
% p = [ 'A' 'B' ]

A  = p(1,:);
B  = p(2,:);
x1 = x(1,:);
x2 = x(2,:);

BB = x1.*(B - x1.*x2);

y(1,:) = A - BB - x1;
y(2,:) = BB;

end
