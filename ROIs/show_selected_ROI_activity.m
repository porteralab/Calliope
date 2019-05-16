cells_to_plot=[1 2 3 4 5];

act=[];

cnt=0;
for ind=cells_to_plot
    cnt=cnt+1;
    act(:,cnt)=(ROIs(ind).activity-min(ROIs(ind).activity))/(max(ROIs(ind).activity)-min(ROIs(ind).activity));
end

% [~,max_pos]=max(act);
% [~,sort_ind]=sort(max_pos);


figure;
imagesc(act')
