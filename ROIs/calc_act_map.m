function [act_map]=calc_act_map(data,step_size)
% calculates the activity map by taking the maxium over the entire stack
% "smoothed" over 'step_size'-frames
% BW 04.03.14


if nargin==1
    step_size=10;
end

act_map=zeros(size(data,1),size(data,2),round(size(data,3)/step_size)-1);
cnt=0;

for ind=1:step_size:size(data,3)-step_size
    cnt=cnt+1;
    act_map(:,:,cnt)=mean(data(:,:,ind:ind+step_size-1),3);
end
act_map=act_map-min(act_map(:));
act_map=max(act_map,[],3)./(mean(act_map,3)+200);

