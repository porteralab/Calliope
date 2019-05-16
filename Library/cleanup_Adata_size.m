function cleanup_Adata_size(user)

% fixes Adata save issues (Matlab 2012)

ADataPath = set_lab_paths;

folders=dir;
folders={folders(3:end).name};

for jnd = 1:length(folders)
    temppath = fullfile(ADataPath,user,folders{jnd});
    files = dir([fullfile(temppath,'*.mat')]);
    for ind=1:length(files)       
        S=load(fullfile(temppath,files(ind).name));
        save(fullfile(temppath,files(ind).name),'-struct','S','-v7.3')
    end
end
disp('DONE')