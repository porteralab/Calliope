function clean_backup(instr1,instr2)
% checks if there are files in RawData folders that are not listed in ExpLog
%
% e.g.
% check_backup()
% check_backup('leinmarc')
% check_backup('ML_131211_0')
% check_backup('','selX',1)
% check_backup('leinmarc','selX',1)


if nargin==0
    instr1=[];
end

if nargin==1
    instr2=[];
end

successfully_connected=connect_to_all_shares;

[~,paths_to_check,archive]=define_backup_paths;

paths_to_check=paths_to_check(:,1);
paths_to_check{end+1}=archive;

ExpLog = getExpLog;

stack_ids=cell2mat(ExpLog.stackid);
stack_ids_cell=cellfun(@num2str,mat2cell(stack_ids,ones(size(stack_ids,1),1),size(stack_ids,2)),'UniformOutput',0);
animal_ids=unique(ExpLog.animalid);
user_ids=unique(ExpLog.pi);

ignored_tags={'ExpID' '.DS_Store'};


uname=[];

if ~isempty(instr1)
    if isempty(regexp(instr1,'-'))
        uname=instr1;
        if ~isempty(instr2)
            paths_to_check=paths_to_check(find(cell2mat(regexpi(paths_to_check,instr2))));
        end
    else
        paths_to_check=paths_to_check(find(cell2mat(regexpi(paths_to_check,instr1))));
        if ~isempty(instr2)
            uname=instr2;
        end
    end
end

unmanaged_size=0;
num_unmanaged_files=0;
num_unmanaged_folders=0;

% check the mid-term and archive storage directories
for ind=1:length(paths_to_check)
    
    show_rig=1;
    
    cur_dirs=dir([paths_to_check{ind}]);
    cur_dirs=struct2cell(cur_dirs);
    cur_dirs=cur_dirs(1,3:end);
    
    unmanaged_user_folders=setdiff(cur_dirs,user_ids);
    unmanaged_user_folders=setdiff(unmanaged_user_folders,ignored_tags);
    
    
    if ~isempty(unmanaged_user_folders)
        show_rig=0;
        disp_rig_name(paths_to_check{ind});
        disp(' ')
        disp('The following folders are unmanaged:')
        disp(' ')
        for lnd=1:length(unmanaged_user_folders)
            disp(['     ' unmanaged_user_folders{lnd}])
        end
    end
    
    managed_user_folders=intersect(cur_dirs,user_ids);
    
    if ~isempty(uname)
        managed_user_folders=intersect(managed_user_folders,uname);
    end
    
    for knd=1:length(managed_user_folders)
        
        cur_dirs=dir([paths_to_check{ind} '\' managed_user_folders{knd}]);
        cur_dirs=struct2cell(cur_dirs);
        cur_dirs=cur_dirs(1,3:end);
        
        unmanaged_animal_folders=setdiff(cur_dirs,animal_ids);
        unmanaged_animal_folders=setdiff(unmanaged_animal_folders,ignored_tags);
        
        num_unmanaged_folders=num_unmanaged_folders+length(unmanaged_animal_folders);
        
        
        if ~isempty(unmanaged_animal_folders)
            if show_rig
                show_rig=0;
                disp_rig_name(paths_to_check{ind});
            end
            disp(' ')
            disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ')
            disp(['In ' [paths_to_check{ind} '\' managed_user_folders{knd}] ' the following folders are unmanaged:'])
            for jnd=1:length(unmanaged_animal_folders)
                disp(['     ' unmanaged_animal_folders{jnd}])
            end
            disp('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ')
            disp(' ')
        end
        
        managed_animal_folders=intersect(cur_dirs,animal_ids);
        
        
        for mnd=1:length(managed_animal_folders)
            
            curr_files=dir([paths_to_check{ind} '\' managed_user_folders{knd} '\' managed_animal_folders{mnd}]);
            curr_files=struct2cell(curr_files);
            curr_sizes=curr_files(3,3:end);
            curr_files=curr_files(1,3:end);
            
            
            
            is_managed=zeros(length(curr_files),1);
            
            for snd=1:length(curr_files)
                id_s=regexp(curr_files{snd},'S.-')+4;
                id_e=regexp(curr_files{snd},'_')-1;
                if isempty(id_e)
                    id_e=regexp(curr_files{snd},'\.')-1;
                end
                expID=str2num(curr_files{snd}(id_s:id_e));
                if ~isempty(expID)
                    is_managed(snd)=sum(expID==stack_ids)>0;
                end
            end
            
            unmanaged_files=curr_files(~is_managed);
            
            num_unmanaged_files=num_unmanaged_files+sum(~is_managed);
            unmanaged_size=unmanaged_size+sum(cell2mat(curr_sizes(~is_managed)));
            
            if ~isempty(unmanaged_files)
                if show_rig
                    show_rig=0;
                    disp_rig_name(paths_to_check{ind});
                end
                disp(' ')
                disp(['In ' [paths_to_check{ind} '\' managed_user_folders{knd} '\' managed_animal_folders{mnd}] ' the following files are unmanaged:'])
                for tnd=1:length(unmanaged_files)
                    disp(['     ' unmanaged_files{tnd}])
                end
            end
            
        end
        
    end
end

disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ')
disp(' ')
disp(['Total unmanaged size (files):      ' num2str(round(unmanaged_size/1e9)) ' GB']);
disp(['Total number of unmanaged files:   ' num2str(num_unmanaged_files)]);
disp(['Total number of unmanaged folders: ' num2str(num_unmanaged_folders)]);
disp(' ')
disp('Please fix this ASAP');
disp(' ')



function disp_rig_name(str)

disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ')
disp(['%%%%%%% Checking ' str ' %%%%%%%'])
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ')



