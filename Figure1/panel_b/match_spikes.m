function [i_cc_hopf, i_vc_hopf,i_vc_unst,vs_cc]=match_spikes(cc,vc,wmedsize,thresholds)
vdt=median(diff(vc.t));
vs_cc=smoothdata(cc.V,'movmedian',ceil(wmedsize/vdt));
l_cc_spike=abs(cc.V-vs_cc)>thresholds.spike;
encl_i_cc_spike=find(diff(l_cc_spike)==1);
i_cc_isi=NaN(length(l_cc_spike),3);
ict=0;
is=1;
for i=1:length(encl_i_cc_spike)
    ie=encl_i_cc_spike(i);
    if cc.t(ie)-cc.t(is)>=thresholds.isi
        ict=ict+1;
        i_cc_isi(ict,:)=[is,ie,cc.t(ie)-cc.t(is)];
    end
    is=ie+1;
end
i_cc_isi(ict+1,:)=[is,length(cc.t),cc.t(end)-cc.t(is)];
i_cc_isi=i_cc_isi(~isnan(i_cc_isi(:,1)),:);
i_cc_isi=i_cc_isi(i_cc_isi(:,3)>thresholds.isi,:);
spike_intlen=cc.t(i_cc_isi(:,2))-cc.t(i_cc_isi(:,1)); % interval length of spikes trains
i_cc_hopf=reshape(i_cc_isi(spike_intlen>thresholds.si,1:2),[],1);
i_cc_hopf=setdiff(i_cc_hopf,[1,length(cc.t)]);
i_vc_hopf=arrayfun(@(i)get_closest(vc.Is,cc.I(i)),i_cc_hopf);
i_vc_unst=i_vc_hopf(1):i_vc_hopf(end);
end
%%
function ind=get_closest(vec,val)
[~,ind]=min(abs(vec-val));
end