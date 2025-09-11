function y = bistable(x, p)

x1 = x(1,:);
x2 = x(2,:);
p1 = p(1,:);

y(1,:) = x2;
y(2,:) = -p1.*x2-x1-x1.^3;

end
