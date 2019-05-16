function [adata_file,mouse_id,userID,projID]=get_adata_filename(ExpID,adata_dir,ExpLog)
% finds the adata file corresponding to ExpID in the folder adata_dir
%
%Input to this function is a user specified ExpID. The function will output
%the name of the adata_file, die mouse_id and the userID.
%
%-------Example-------
%
%get_adata_filename(24790,adata_dir,ExpLog)
%
%documented by DM - 08.05.2014

if nargin == 1
    ExpLog = getExpLog;
    adata_dir=set_lab_paths;
end
exp_ind=find(cell2mat(ExpLog.expid)==ExpID);

userID=ExpLog.pi{exp_ind};
projID=ExpLog.project{exp_ind};
mouse_id=ExpLog.animalid{exp_ind};

curr_files=dir([adata_dir userID '\' mouse_id '\*']);
for mnd=1:length(curr_files)
    if strcmp(curr_files(mnd).name(findstr(curr_files(mnd).name,'T')+1:end-4),num2str(ExpID))
        adata_file=curr_files(mnd).name;
        break;
    end
end


if ~exist('adata_file','var');
    adata_file='';
    mouse_id='';
    userID='';
end
