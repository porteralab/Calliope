function [pupil_diam,pupil_pos,blink] = map_eye_data_to_frame_times(pupil_diam,pupil_pos,blink,frame_times,iframe_times)
tmp_pupil_diam=zeros(1,length(frame_times));
tmp_pupil_pos=zeros(2,length(frame_times));
tmp_blink=zeros(1,length(frame_times));
for gnd=1:length(frame_times)
    [~,cur_iframe]=min(abs(iframe_times-frame_times(gnd)));
    tmp_pupil_diam(gnd)=pupil_diam(cur_iframe);
    tmp_pupil_pos(:,gnd)=pupil_pos(:,cur_iframe);
    tmp_blink(gnd)=blink(cur_iframe);
end
pupil_diam=tmp_pupil_diam;
pupil_pos=tmp_pupil_pos;
blink=tmp_blink;