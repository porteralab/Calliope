function save_adata2(adata_dir,ROIs,bv,np,template,dx,dy,aux_files,fnames,nbr_frames,mouse_id,userID,act_map)

% save Adata (e.g. from ROI-ing) to Adata file

if ~isdir([adata_dir userID '\' 'v7.3_temp'])
    mkdir([adata_dir userID],'v7.3_temp');
end

if ~isdir([adata_dir userID '\' 'v7.3_temp' '\' mouse_id])
    mkdir([adata_dir userID '\' 'v7.3_temp'], mouse_id);
end

try
    save([adata_dir userID '\' 'v7.3_temp' '\' mouse_id '\Adata-' fnames{1}(1:strfind(fnames{1},'_')-1)],'ROIs','ROItrans','bv','np','template','dx','dy','aux_files','fnames','mouse_id','nbr_frames','act_map','-append','-v7.3');
catch
    save([adata_dir userID '\' 'v7.3_temp' '\' mouse_id '\Adata-' fnames{1}(1:strfind(fnames{1},'_')-1)],'ROIs','ROItrans','bv','np','template','dx','dy','aux_files','fnames','mouse_id','nbr_frames','act_map','-v7.3');
end
disp('Saved Adata');