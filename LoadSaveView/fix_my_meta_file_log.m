function fix_my_meta_file_log(userID)
% function used to populate the MetaDataFiles table in the ExpLog DB

[adata_dir]=set_lab_paths;
meta_save_dir=[adata_dir '_metaData\'];

meta_files=dir(meta_save_dir);
meta_files=meta_files(3:end);

ExpLogProjects=getExpLogProjects;

is_mine=zeros(length(meta_files),1);

for ind=1:length(meta_files)
    try
        tmp=regexp(meta_files(ind).name,'_');
        projID=meta_files(ind).name(1:tmp(1)-1);
        
        curr_users=ExpLogProjects.pis{find(strcmp(ExpLogProjects.projectid,projID))};
        
        if regexp(curr_users,userID)>0
            is_mine(ind)=1;
        end
    catch
        disp(['please fix ' meta_files(ind).name ' name does not follow naming convention or there is no user specified'])
    end
end


my_files=meta_files(find(is_mine));
ExpLogMetaDataFiles=getExpLogMetaDataFiles;
has_description=zeros(length(my_files),2);

for ind=1:length(my_files)
    
    if sum(strcmp(ExpLogMetaDataFiles.metadataname,my_files(ind).name))>0
        has_description(ind,2)=find(strcmp(ExpLogMetaDataFiles.metadataname,my_files(ind).name));
        if length(ExpLogMetaDataFiles.description{find(strcmp(ExpLogMetaDataFiles.metadataname,my_files(ind).name))})>10
            has_description(ind,1)=1;
        end
    end
end

disp([' ']);
disp([' ']);

disp(['--------------------------------------------------------']);
disp(['---- For these files you already have a description ----']);
disp(['--------------------------------------------------------']);
for ind=1:length(my_files)
    if has_description(ind,1)
        disp([ my_files(ind).name ' - ' ExpLogMetaDataFiles.description{has_description(ind,2)}])
    end
end

disp([' ']);
disp([' ']);

disp(['--------------------------------------------------------']);
disp(['----      These files will need a description       ----']);
disp(['--------------------------------------------------------']);
for ind=1:length(my_files)
    if ~has_description(ind,1)
        disp([ my_files(ind).name])
    end
end

disp([' ']);
disp([' ']);


for ind=1:length(my_files)
    if ~has_description(ind,1)
        
        go_on=1;
        skip=0;
        
        while go_on
            disp([' ']);
            disp(['--------------------------------------------------------']);
            disp([ my_files(ind).name ' does not have a description'])
            description=input(['What should it be (s: skip): '],'s');
            disp([' ']);
            if strcmp(description,'s')
                skip=1;
                go_on=0;
            else
                go_on=~input(['Is this correct (0: no,1: yes): "' description '" :']);
            end
        end
        
        if ~skip
            tmp=regexp(my_files(ind).name,'_');
            projID=my_files(ind).name(1:tmp(1)-1);
            
            DB=connectToExpLog;
            sql=['INSERT INTO MetaDataFiles (MetaDataName, ProjectID, Description) VALUES (''' my_files(ind).name ''', ''' projID ''', ''' description ''');'];
            ExpLog = adodb_query(DB, sql);
            DB.release;
        end
        
    end
end






