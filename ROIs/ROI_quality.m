function [ROIs]=ROI_quality(data,ROIs)
data=double(data(vertcat(ROIs.indices)+(0:size(data,3)-1)*size(data,1)*size(data,2)));
rois_delim=[1 cumsum(arrayfun(@(x) size(x.indices,1),ROIs))];
rois_delim=arrayfun(@(x,y) x:y,rois_delim(1:end-1),rois_delim(2:end),'uni',0);
data=cellfun(@(x) mean(corrcoef(data(x,:)),1),rois_delim,'uni',0);
[ROIs.quality]=deal(data{:});
end