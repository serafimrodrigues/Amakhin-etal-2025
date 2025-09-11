function J = abc_dx(x,p)

al = p(1,:);
si = p(2,:);
D  = p(3,:);
B  = p(4,:);
be = p(5,:);

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);

e3 = exp(x3);

J = zeros(3,3,numel(e3));
J(1,1,:) = -1-D.*e3;
J(1,3,:) = D.*(1-x1).*e3;
J(2,1,:) = -D.*e3;
J(2,2,:) = -1-D.*si.*e3;
J(2,3,:) = D.*(1-x1-si.*x2).*e3;
J(3,1,:) = -D.*B.*e3;
J(3,2,:) = D.*B.*al.*si.*e3;
J(3,3,:) = -1-be+D.*B.*(1-x1+al.*si.*x2).*e3;

end
