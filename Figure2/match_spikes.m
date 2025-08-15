function [i_cc_hopf, i_vc_hopf,i_vc_unst,vs_cc]=match_spikes(cc,vc,wmedsize,thresholds)
vdt=median(diff(vc.t));
vs_cc=smoothdata(cc.V,'movmedian',ceil(wmedsize/vdt));
l_cc_spike=abs(cc.V-cc.Vs)>thresholds.spike;
i_cc_spike=find(l_cc_spike);
encl_i_cc_spike=find([true;l_cc_spike;true])-1;
i_cc_isi=NaN(length(l_cc_spike),3);
ict=0;
for i=2:length(encl_i_cc_spike)
    [is,ie]=deal(encl_i_cc_spike(i-1)+1,encl_i_cc_spike(i)-1);
    if cc.t(ie)-cc.t(is)>=thresholds.isi
        ict=ict+1;
        i_cc_isi(ict,:)=[is,ie,cc.t(ie)-cc.t(is)];
    end
end
i_cc_isi=i_cc_isi(~isnan(i_cc_isi(:,1)),:);
i_cc_isi=i_cc_isi(i_cc_isi(:,3)>thresholds.isi,:);
i_cc_hopf=[i_cc_isi(1:end-1,2),i_cc_isi(2:end,1)];
spike_intlen=cc.t(i_cc_hopf(:,2))-cc.t(i_cc_hopf(:,1)); % interval length of spikes trains
i_cc_hopf=i_cc_hopf(spike_intlen>thresholds.si,:);
i_vc_hopf=arrayfun(@(i)get_closest(vc.Is,cc.I(i)),i_cc_hopf);
i_vc_unst=i_vc_hopf(1):i_vc_hopf(end);
end
%%
function ind=get_closest(vec,val)
[~,ind]=min(abs(vec-val));
end