function [i_cc_hopf, i_vc_hopf,i_vc_unst,vs_cc]=match_cc_spikes(cc,vc,thresholds)
vs_cc=smoothdata(cc.V,'movmedian',thresholds.wsize(end),'SamplePoints',cc.t);
l_cc_spike=cc.V-vs_cc>thresholds.spike; % where is V >movmedian of V (sharp spike)
i_cc_spike_start=[find(diff(l_cc_spike)==1);length(cc.t)]; % start of sharp part of each spike, incl end
i_cc_spike_end=[1;find(diff(l_cc_spike)==-1)]; % end of sharp part of each spike, incl start
t_isi=cc.t(i_cc_spike_start)-cc.t(i_cc_spike_end); % interspike time intervals
l_gap=t_isi>thresholds.isi; % which ISIs are larger than permitted ISI
spike_intlen=diff(find(l_gap)); % interval length of spikes trains
i_gap_hopf=find(spike_intlen>thresholds.trainlen); % which continuous spike trains have minimal length
i_start_isi=i_cc_spike_start(l_gap); % after which spike is a long pause (incl start & end)
i_end_isi=i_cc_spike_end(l_gap); % after which spike is a long pause (incl start & end)
i_cc_hopf=[i_start_isi(i_gap_hopf);i_end_isi(i_gap_hopf+1)];
i_vc_hopf=arrayfun(@(i)get_last_crossing(vc.Is,cc.Is(i)),i_cc_hopf);
i_vc_unst=i_vc_hopf(1):i_vc_hopf(end);
end
%%
function ind=get_last_crossing(vec,val)
ind=find(diff(sign(vec-val)),1,'last');
if isempty(ind)
    ind=NaN;
end
end