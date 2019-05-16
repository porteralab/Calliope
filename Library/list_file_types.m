function ftypes=list_file_types(ExpID,data_dir,userID,animalID)
% lists file types of ExpID in data_dir
% GK 12.11.2015

all_files=dir([data_dir userID '\' animalID]);
all_files=struct2cell(all_files);

found_match=regexp(all_files(1,:),num2str(ExpID));
curr_files=all_files(1,~cellfun(@isempty,found_match));

for ind=1:length(curr_files)
    ftypes{ind}=curr_files{ind}(end-2:end);
end

ftypes=unique(ftypes);