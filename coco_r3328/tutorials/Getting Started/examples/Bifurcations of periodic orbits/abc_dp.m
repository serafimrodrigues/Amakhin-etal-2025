function J = abc_dp(x,p)

al = p(1,:);
si = p(2,:);
D  = p(3,:);
B  = p(4,:);

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);

e3 = exp(x3);

J = zeros(3,5,numel(e3));
J(1,3,:) = (1-x1).*e3;
J(2,2,:) = -D.*x2.*e3;
J(2,3,:) = (1-x1-si.*x2).*e3;
J(3,1,:) = D.*B.*si.*x2.*e3;
J(3,2,:) = D.*B.*al.*x2.*e3;
J(3,3,:) = B.*(1-x1+al.*si.*x2).*e3;
J(3,4,:) = D.*(1-x1+al.*si.*x2).*e3;
J(3,5,:) = -x3;

end
