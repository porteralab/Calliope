function [adata_list]=list_all_adata_files(adata_dir,savefile)
% [adata_list]=list_all_adata_files(adata_dir)
% lists all adata files
% GK - a long time ago...

cnt=0;
adata_list={};
users = dir(adata_dir);

for ind=3:length(users)
    if ~strcmp(users(ind).name(1),'_')
        curr_animals=dir([adata_dir '\' users(ind).name]);
        for knd=3:length(curr_animals)
            curr_files=dir([adata_dir '\' users(ind).name '\' curr_animals(knd).name '\*Adata*']);
            for mnd=1:length(curr_files)
                cnt=cnt+1;
                adata_list{cnt}=curr_files(mnd).name(max(regexp(curr_files(mnd).name,'\d+')):end-4);
            end
        end
    end
end

if exist('savefile','var')  
    if savefile
        save([adata_dir 'adata_list.mat'],'adata_list');
    end
end