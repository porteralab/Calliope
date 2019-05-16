function export_zstack_to_tiff(ExpID)
%export_zstack_to_tiff - export averaged zstack (mean_data found on M:) as
%tiff. One tiff generated per one frame of mean_data.
%
%ExpID = Exp ID of mean_data stack
%
% written by PZ 2015-08-04

adata_dir=set_lab_paths;
[adata_file,mouse_id,userID]=find_adata_file(ExpID,adata_dir);

load([adata_dir userID '\' mouse_id '\' adata_file]);

display('Specify output directory')
epath=uigetdir;
display(['Exporting to' epath])

if ~exist([epath '\Exp_' num2str(ExpID)],'dir')
    mkdir([epath '\Exp_' num2str(ExpID)])
end

zeros_file=repmat('0',1,numel(num2str(size(mean_data,3))));

for knd=1:size(mean_data,3)
    imwrite(uint16(mean_data(:,:,knd)), [epath '\Exp_' num2str(ExpID) '\Exp_' num2str(ExpID) '_' zeros_file(1:length(zeros_file)-numel(num2str(knd))) num2str(knd) '.tif'],'tif');
    if rem(knd,20)==0
        display(['Finished exporting ' num2str(knd) ' tiffs'])
    end
end