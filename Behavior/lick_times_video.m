function lick=lick_times_video(ldata)
% detects licks from video data
% this function assumes that the the tongue extends to the lower 30 pixels
% of the image and is brighter than the background
% GK - 20.12.2013


lick=squeeze(mean(mean(ldata(end-30:end,:,:),1),2));

