%--------------------------------------------------------------------
% "Observing hidden neuronal states in experiments" by Amakhin et al.
%  m-file to prepare structures for Fig.2
%--------------------------------------------------------------------
clear
[doplot,docheck]=deal(true,false);
addpath([pwd(),'/../m_files/']);
ic=struct('in',1,'t2',2);
matfiles=[pwd(),'/../mat_files/'];
if docheck
    vcs(ic.t2)=load([matfiles,'vcruntype2.mat']);
    ccs(ic.t2)=load([matfiles,'ccruntype2.mat']);
    [vcs(ic.t2).t,ccs(ic.t2).t]=deal(vcs(ic.t2).t/1000,ccs(ic.t2).t/1000);
end
vars_in=load([matfiles,'fig2a_231215_IN_raw.mat']);
ccrun(ic.in)=vars_in.runs.cc;
vcrun(ic.in)=vars_in.runs.vc;
Vfac=1e2;
vcrun(ic.in).V=vcrun(ic.in).V*Vfac;
ccrun(ic.in).V=ccrun(ic.in).V*Vfac;
vars_t2=load([matfiles,'fig2b_240502_T2_raw.mat']);
ccrun(ic.t2)=vars_t2.runs.cc;
vcrun(ic.t2)=vars_t2.runs.vc;
fn=fieldnames(ccrun(ic.in));
%% cut down to 60 s of recording
bd.I=[-Inf,450];
bd.t=[0,60];
bd.V=[-Inf,Inf];
for k=1:length(ccrun)
    csel=true(length(ccrun(k).t),1);
    vsel=true(length(vcrun(k).t),1);
    for i=1:length(fn)
        csel=csel & ccrun(k).(fn{i})>=bd.(fn{i})(1) & ccrun(k).(fn{i})<=bd.(fn{i})(2);
        vsel=vsel & vcrun(k).(fn{i})>=bd.(fn{i})(1) & vcrun(k).(fn{i})<=bd.(fn{i})(2);
    end
    for i=1:length(fn)
        ccrun(k).(fn{i})=ccrun(k).(fn{i})(csel);
        vcrun(k).(fn{i})=vcrun(k).(fn{i})(vsel);
    end
end
%%
wsize=0.1; % window size for smoothing for Is of ccrun and Vs of vcrun
wsize_vcIs0=0.005; % window size for minimal smoothing of I for vcl (called Is0)
thresholds=[... % quantities used for spike counting
    struct('spike',10,'isi',0.2,'trainlen',30,'wsize',[0.1,0.025]),...
    struct('spike',10,'isi',0.5,'trainlen',30,'wsize',[0.1,0.025])];
wsize_smooth=struct('movmean',ones(1,5),'gaussian',[0.5,0.01]); % window sizes for strong smoothing for Is of VCrun
[weqsize,eqthresh]=deal([0.01,0.01],10); % window size and threshold for determining slow parts of ccrun
if doplot
    step=100;
    figure(2);clf;hold on;
end
for i=1:2
    vcrun(i).Is0=smoothdata(vcrun(i).I,'movmean',wsize_vcIs0,'SamplePoints',vcrun(i).t);
    vcout=smooth_I_mth(vcrun(i),wsize_smooth);
    vcrun(i).Is=vcout.Is;
    vcrun(i).Vs=smoothdata(vcrun(i).V,'gaussian',wsize,'SamplePoints',vcrun(i).t);
    ifold=find(diff(sign(diff(vcrun(i).Is))));
    isel=[true;diff(ifold)~=1];
    vcrun(i).i_fold=ifold(isel(1:length(ifold)));
    ccrun(i).Is=smoothdata(ccrun(i).I,'gaussian',wsize,'SamplePoints',ccrun(i).t);
    [ccrun(i).i_hopf,vcrun(i).i_hopf,vcrun(i).i_unst,ccrun(i).Vs]=match_cc_spikes(ccrun(i),vcrun(i),thresholds(i));
    ccrun(i).dv_norm=match_cc_slow(ccrun(i),weqsize,5);
    ccrun(i).lslow=ccrun(i).dv_norm<eqthresh;
    ccrun(i).Veq=ccrun(i).V;
    ccrun(i).Ieq=ccrun(i).Is;
    ccrun(i).Veq(~ccrun(i).lslow)=NaN;
    vcrun(i).i_bif=sort([vcrun(i).i_fold(:);vcrun(i).i_hopf(:)]);
    rc=ccrun(i);
    rv=vcrun(i);
    disp(rc.Is(rc.i_hopf));
    if doplot
        plot(rc.Is,rc.V+i*step);
        plot(rc.Is,rc.Veq+i*step,'k','LineWidth',2);
        plot(rv.Is(rv.i_hopf),rv.Vs(rv.i_hopf)+i*step,'co','LineWidth',2);
        plot(rv.Is,rv.Vs+i*step,'b-','LineWidth',2);
        grid on
        drawnow
    end
end
%%
save('../mat_files/processed_fig2runs.mat');