function y = abc(x,p)
% p = [ al si D B be ]

al = p(1,:);
si = p(2,:);
D  = p(3,:);
B  = p(4,:);
be = p(5,:);

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);

E3 = exp(x3);
T1 = D.*(1-x1).*E3;
T2 = D.*si.*x2.*E3;
T3 = B.*T1;
T4 = B.*al.*T2;

y(1,:) = -x1 + T1;
y(2,:) = -x2 + T1 - T2;
y(3,:) = -x3 - be.*x3 + T3 + T4;

end
