function [run,i]=smooth_I_sg(run,wsize,num,deg)
Is=run.I;
for i=1:num
    Is=smoothdata(Is,'sgolay',wsize,'Degree',deg,'SamplePoints',run.t);
    if length(find(diff(sign(diff(Is)))))<=2
        break
    end
end
run.Is=Is;
end