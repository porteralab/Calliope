function [frame_times]=get_frame_times(trig_ch)
% this function extracts from the analog frame galvo signal the frame onset
% times

pos=find(trig_ch>0.75*max(trig_ch));
frame_times=pos(find(diff(pos)>10));
if  numel(frame_times)==0
    disp('get_frame_times WARNING: no frames found')
    frame_times = 1;
    return
end
% find onset of first frame
first_frame=find(trig_ch<0.5*min(trig_ch), 1 );
if abs(first_frame-frame_times(1))>median(diff(frame_times))
    disp('get_frame_times WARNING: galvo signal not zero before 1st frame');
    first_frame=frame_times(1)-median(diff(frame_times));
end
   
% shift to correct for detecting frame offset
frame_times=frame_times+first_frame-frame_times(1);

% add last frame manually
frame_times(end+1)=frame_times(end)+median(diff(frame_times));
