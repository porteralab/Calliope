function []=save_adata(adata_dir,ROIs,bv,np,template,dx,dy,aux_files,fnames,nbr_frames,mouse_id,userID,act_map,template_sec,act_map_sec)

% if ~strcmp(mouse_id(1:3),'GK_')
%     disp('mouse ID problem!')
%     return
% end

if ~isdir([adata_dir userID '\' mouse_id])
    mkdir([adata_dir userID], mouse_id);
end
temp = strsplit(fnames{1},'\');
fn = temp{end};
if strfind(fn,'wid')
    fn = fn(1:strfind(fn,'.')-1);
else
    fn = fn(1:strfind(fn,'_')-1);
end
path = [adata_dir userID '\' mouse_id '\Adata-' fn];
try
    if exist(path,'file') > 0
        option = '-append';
    else
        option = '';
    end
    save(path,'ROIs','bv','np','template','dx','dy','aux_files','fnames','mouse_id','nbr_frames','act_map','template_sec','act_map_sec',option);
catch
    disp('Saving in old file format')
    save(path,'ROIs','bv','np','template','dx','dy','aux_files','fnames','mouse_id','nbr_frames','act_map','template_sec','act_map_sec','-v7.3');
end
disp('Saved Adata');

