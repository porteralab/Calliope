
figure;
ft=get_frame_times(ad(2,:));

hold on
for ind=1:size(raw_traces,2)
    plot(ntzo(raw_traces(:,ind))+ind-1);
end

tmp=smooth(ad(6,:),20);
tmp=tmp>0.02;


plot((ind)*ntzo(tmp(ft(1:4:end))),'k')