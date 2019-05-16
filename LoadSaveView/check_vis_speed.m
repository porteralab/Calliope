function vis_speed=check_vis_speed(pd_data)
%This functions creates a histogram for the spatial frequency of e.g.
%moving gratings.
%
%check_vis_speed(pd_data) used photodiode data as input und calculates
%a histogram of spatial frequency from this vector;
%
%
%documented by DM - 08.05.2014

pd_data=smooth2(pd_data,50);

thrsh=prctile(pd_data,2)+0.85*(prctile(pd_data,98)-prctile(pd_data,2));
crossings=[1 find(diff(pd_data>thrsh)) length(pd_data)];
for ind=1:length(crossings)-1
    vis_speed(crossings(ind):crossings(ind+1))=1000*0.5/(crossings(ind+1)-crossings(ind));
%     if 1000*0.5/(crossings(ind+1)-crossings(ind))>10
%         
%     end
end
vis_speed(vis_speed>10)=10;

% figure;
% hist(vis_speed,[0:0.2:10])