function [run,i]=smooth_I_mth(run,mth)
Is=run.I;
fn=fieldnames(mth);
for i=1:length(fn)
    mt=mth.(fn{i});
    for k=1:length(mt)
        Is=smoothdata(Is,fn{i},mt(k),'SamplePoints',run.t);
    end
end
run.Is=Is;
end