function [latestfile, path, file_dir] = getlatestfile(directory)
%This function returns the latest fileoath from the directory passsed as 
%input argument, adapted from Mathworks Q&A site FW 2019

%Get the directory contents
dirc = dir(directory);

%Filter out all the folders.
dirc = dirc(find(~cellfun(@isdir,{dirc(:).name})));

%I contains the index to the biggest number which is the latest file
[A,I] = max([dirc(:).datenum]);

if ~isempty(I)
    latestfile =  dirc(I).name;
    path =  [dirc(I).folder filesep];
    file_dir = dirc(I);
end

end