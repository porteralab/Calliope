function [avg]=event_triggerd_average(data,trig_frames,win)
%Function calculates average values for event triggered situations in the
%dataset.
%
%Input to this function is a specified data set (string input "data"), the
%frame number for the onset of the event and a window around this event.
%The output is saved in a new variable called avg.
%
%
%documented by DM - 08.05.2014
%
%
if nargin<3
    win=10;
end

for ind=1:4
avg_tmp{ind}=zeros(size(data{1},1),size(data{1},2),length(trig_frames));
end

for ind=1:length(trig_frames)
    ind
    for knd=1:4
        avg_tmp{knd}(:,:,ind)=mean(data{knd}(:,:,trig_frames(ind):min(trig_frames(ind)+win,size(data{1},3))),3)-mean(data{knd}(:,:,max(trig_frames(ind)-win,1):trig_frames(ind)),3);
    end
end

for ind=1:4
    avg{ind}=mean(avg_tmp{ind},3);
end
