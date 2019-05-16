function [ROIs]=ROI_activity(data,ROIs)
%vectorized update: runs 4-5x faster, 2018 FW
data=data(bsxfun(@plus,vertcat(ROIs.indices),(0:size(data,3)-1)*size(data,1)*size(data,2)));
rois_delim= arrayfun(@(x) size(x.indices,1),ROIs);
rois_delim = repelem(1:numel(rois_delim), rois_delim).';
data = num2cell(splitapply( @mean, data, rois_delim )',1);
[ROIs.activity]=deal(data{:});


% obsolete
%
% for cell_nr=1:length(ROIs)
%     %disp(['Processing cell nr. ' num2str(cell_nr) ' of ' num2str(length(ROIs))]);
%     cell_act=zeros(size(data,3),1);
%
%     for ind=1:size(data,3)
%         cell_act(ind)=mean(data(ROIs(cell_nr).indices+(ind-1)*size(data,1)*size(data,2)));
%     end
%
%     ROIs(cell_nr).activity=cell_act;
% end
%
% % np_act=zeros(size(data,3),1);
% % for ind=1:size(data,3)
% %     np_act(ind)=mean(data(np.indices+(ind-1)*size(data,1)*size(data,2)));
% % end
% % np.activity=np_act;