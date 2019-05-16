function [lick]=map_lick_to_frame_times(lick,frame_times,ltimes)
tmp_lick=zeros(1,length(frame_times));

for gnd=1:length(frame_times)
    [~,cur_lframe]=min(abs(ltimes-frame_times(gnd)));
    tmp_lick(gnd)=lick(cur_lframe);
end

lick=tmp_lick;
