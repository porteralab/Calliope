function [adata_file,mouse_id,userID]=find_adata_file(ExpID,adata_dir)
% finds the adata file corresponding to ExpID in the folder adata_dir
% returns adata_file as a string

s = filesep;
ExpInfo = read_info_from_ExpLog(ExpID,1);

if exist([adata_dir ExpInfo.userID s ExpInfo.mouse_id s 'Adata-S1-T' num2str(ExpID) '.mat' ],'file')
    adata_file = ['Adata-S1-T' num2str(ExpID) '.mat'];
    userID = ExpInfo.userID;
    mouse_id = ExpInfo.mouse_id;
else
    tempfiles = dirrec([adata_dir ExpInfo.userID s ExpInfo.mouse_id]);
    for knd = 1:length(tempfiles)
        if ~isempty(regexp(cell2mat(tempfiles(knd)),num2str(ExpID), 'once'))
            temp2 = regexp(cell2mat(tempfiles(knd)),'\','split');
            adata_file = temp2{end};
            userID = ExpInfo.userID;
            mouse_id = ExpInfo.mouse_id;
            break;
        end
    end
end

if ~exist('adata_file','var');
    adata_file='';
    mouse_id='';
    userID='';
end
