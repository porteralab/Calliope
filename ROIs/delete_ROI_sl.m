function []=delete_ROI_sl(del_ind,adata_dir,ExpGroup)

warning('off','MATLAB:load:variableNotFound')

cnt=0;
for knd=ExpGroup'
    cnt=cnt+1;
    [curr_adata_file,curr_mouse_id,userID]=find_adata_file(knd,adata_dir);
    fname=[adata_dir userID '\' curr_mouse_id '\' curr_adata_file];
    curr=load(fname,'ROIs');
    if cnt==1
        nbr_main_ROIs=length(curr.ROIs);
    end
    if length(curr.ROIs)==nbr_main_ROIs
        curr.ROIs=curr.ROIs(setdiff([1:length(curr.ROIs)],del_ind));
        disp(['Now saving ' fname])
        ROIs=curr.ROIs;
        save(fname,'ROIs','-append');
    else
        disp(['Exp ' num2str(knd) ' has probably not been analyzed yet']);
    end
end

disp(['--- Done deleting ROI ' num2str(del_ind) ' ---']);
disp('--- RELOAD CURRENT ROIS ---');