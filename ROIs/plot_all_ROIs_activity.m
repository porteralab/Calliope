function [act]=plot_all_ROIs_activity(ROIs)
% this function plots the activity of all ROIs

nbr_cells=length(ROIs);

hf=figure;
set(hf,'menubar','none');
%axes('position',[0 0 1 1])
subplot(3,1,1);
hold on
cum_shift=0;
act=zeros(length(ROIs(1).activity),nbr_cells);
for ind=1:nbr_cells
    plot(ROIs(ind).activity+cum_shift,'k');
    cum_shift=cum_shift+max(ROIs(ind).activity);
    act(:,ind)=ROIs(ind).activity-min(ROIs(ind).activity);
end
axis tight

subplot(3,1,2);
%axes('position',[0 0 1 1])
imagesc(act')

subplot(3,1,3);
%axes('position',[0 0 1 1])
plot(median(act'))
hold on
plot(mean(act'),'r')
plot(act)
axis tight