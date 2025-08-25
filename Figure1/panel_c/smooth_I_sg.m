function [Iout,i]=smooth_I_sg(Iin,wsize,num,deg)
Is=Iin;
for i=1:num
    Is=smoothdata(Is,'sgolay',wsize,'Degree',deg);
    if length(find(diff(sign(diff(Is)))))<=2
        break
    end
end
Iout=Is;
end