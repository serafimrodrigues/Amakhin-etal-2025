function cceq=match_cc_stst(ccrun,wsize,nthresh)
filter={'gaussian',wsize};
vs_cc=smoothdata(ccrun.V,filter{:},'SamplePoints',ccrun.t);
dvs_cc=diff(vs_cc)./diff(ccrun.t);
dvs_cc=smooth_norm(dvs_cc,ccrun.t,filter);
ddvs_cc=diff(vs_cc,2)./diff(ccrun.t(2:end)).^2;
ddvs_cc=smooth_norm(ddvs_cc,ccrun.t,filter);
dvs_norm=sqrt(dvs_cc(2:end).^2+ddvs_cc.^2);
sel=[false;dvs_norm<nthresh;false];
fnames=fieldnames(ccrun);
for i=1:length(fnames)
    tmp=ccrun.(fnames{i});
    tmp(~sel)=NaN;
    cceq.(fnames{i})=tmp;
end
end
function vs=smooth_norm(v,t,args)
vs=smoothdata(v,args{:},'SamplePoints',t(1:length(v)));
vs=vs/norm(vs,'inf');
end


