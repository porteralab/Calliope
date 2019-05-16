function set_paths

restoredefaultpath;

trunk_dirs={'C:\Code\Calliope' 'C:\Code\ProjectAnalysis'};

for knd=1:length(trunk_dirs)
    folder_list=strsplit(genpath(trunk_dirs{knd}),pathsep);
    
    for ind=1:length(folder_list);
        if isempty(findstr(folder_list{ind},'.svn'))
            addpath(folder_list{ind})
        end
    end
end

savepath;




