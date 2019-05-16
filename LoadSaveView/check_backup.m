function check_backup(instr,varargin)
% checks if data is backed up
%
% checks location of all data associeated with stack IDs entered in the
% database (stacks.xls file).
%
% function can be called without input (check all) or with
% instr: username (FMI) or animal ID
%
% e.g.
% check_backup()
% check_backup('leinmarc')
% check_backup('ML_131211_0')
% check_backup('','selX',1)
% check_backup('leinmarc','selX',1)

if nargin==0 % no input str
    instr = [];
    selX = 0;
    showNonArchivedOnly = 0;
else
    p = inputParser;
    if verLessThan('matlab','8.2')
        p.addParamValue('selX',0,@isnumeric)
        p.addParamValue('showNonArchivedOnly',0,@isnumeric)
        p.parse(varargin{:})
    else
        addRequired(p,'instr',@ischar)
        addParameter(p,'selX',0,@isnumeric)
        addParameter(p,'showNonArchivedOnly',0,@isnumeric)
        parse(p,instr,varargin{:})
        instr = p.Results.instr;
        selX = p.Results.selX;
        showNonArchivedOnly = p.Results.showNonArchivedOnly;
    end
end

successfully_connected=connect_to_all_shares;

if ~successfully_connected
   Ido=input('Warning - you should not proceed without fixing the connection isssues first - only proceed if you know what you are doing: ','s');
   if ~strcmp(Ido,'I do')
       return
   end
end

[paths_to_check_tmp,paths_to_check,archive]=define_backup_paths;
adata_dir=set_lab_paths;

reload_adata_list=0;

if reload_adata_list
    [adata_list]=list_all_adata_files(adata_dir,1);
else
    load([adata_dir 'adata_list.mat'],'adata_list');
end

paths_to_check=paths_to_check(:,1);
paths_to_check{end+1}=archive;
paths_to_check_tmp=paths_to_check_tmp(1:4,1);

ExpLog = getExpLog;

ftypes={'bin' 'ini' 'lvd' 'eye' 'vid' 'vid2' 'run'};
ftype_value=[10 1 0.1 0.01 0.001 0.0001 0.00001];

stack_ids=cell2mat(ExpLog.stackid);
animal_ids=ExpLog.animalid;
user_ids=ExpLog.pi;
projects=ExpLog.project;
stack_dates=ExpLog.stackdate;

% find which s=ackIDs have associated Adata files
has_adata=ismember(cellfun(@num2str,ExpLog.expid,'UniformOutput',0),adata_list);

do_temp_only=0;

if ~isempty(instr)
    if length(instr)>3 && strcmp(instr(3),'_') %animal id is input str
        subset=strcmp(animal_ids,instr);
    elseif strcmp(instr,'temp')
        do_temp_only=1;
        subset=logical(ones(size(stack_ids)));
    elseif length(instr)<5 %project ID is input str
        subset=strcmp(projects,instr);
    else % user is input str
        subset=strcmp(user_ids,instr);
    end
    stack_ids=stack_ids(subset);
    animal_ids=animal_ids(subset);
    user_ids=user_ids(subset);
    projects=projects(subset);
    stack_dates=stack_dates(subset);
    has_adata=has_adata(subset);
end

found_it=cell(length(stack_ids),length(paths_to_check_tmp)+length(paths_to_check));
datenum_check=cell(length(stack_ids),length(paths_to_check_tmp)+length(paths_to_check));
fsizes=zeros(length(stack_ids),2);

% check the temp directories on the setup machines
for ind=1:length(paths_to_check_tmp)
    files=dir(paths_to_check_tmp{ind});
    files=files(3:end);
    
    curr_ids=[];
    curr_ftype={};
    cnt=0;
    for knd=1:length(files)
        if isempty(regexp(files(knd).name,'sec'))
            cnt=cnt+1;
            id_s=regexp(files(knd).name,'-')+2;
            id_e=regexp(files(knd).name,'_')-1;
            ftype_st=regexp(files(knd).name,'\.')+1;
            if  isempty(id_e)
                id_e=ftype_st-2;
            end
            if length(id_s)==1 && length(id_e)==1 && id_e>id_s
                curr_ids(cnt)=str2num(files(knd).name(id_s:id_e));
                curr_ftype{cnt}=files(knd).name(ftype_st:end);
                curr_datenum(cnt)=files(knd).datenum;
            end
        end
    end
    
    for knd=1:length(stack_ids)
        matches=find(curr_ids==stack_ids(knd));
        if matches
            %             curr_val=0;
            %             for lnd=1:length(matches)
            %                 curr_val=curr_val+ftype_value(strcmp(ftypes,curr_ftype{matches(lnd)}));
            %             end
            found_it{knd,ind}=length(matches);
            datenum_check{knd,ind}=curr_datenum(matches);
        end
    end
end

if do_temp_only
    subset=find(sum(~cellfun(@isempty,found_it)')~=0);
    
    found_it=found_it(subset,:);
    datenum_check=datenum_check(subset,:);
    stack_ids=stack_ids(subset);
    animal_ids=animal_ids(subset);
    user_ids=user_ids(subset);
    projects=projects(subset);
    stack_dates=stack_dates(subset);
    has_adata=has_adata(subset);
end



% check the mid-term and archive storage directories
for ind=1:length(paths_to_check)
    
    curr_ids=[];
    curr_size=[];
    curr_ftype={};
    curr_datenum=[];
    cnt=0;
    
    curr_users=unique(user_ids); %fix this - should only loop over actual users
    for jnd=1:length(curr_users)
        curr_animals=unique(animal_ids); %fix this - should only loop over animals of user
        for lnd=1:length(curr_animals)
            curr_files=dir([paths_to_check{ind} '\' curr_users{jnd} '\' curr_animals{lnd} '\']);
            curr_files=curr_files(3:end);
            for knd=1:length(curr_files)
                if isempty(regexp(curr_files(knd).name,'sec'))
                    cnt=cnt+1;
                    id_s=regexp(curr_files(knd).name,'S.-')+4;
                    id_e=regexp(curr_files(knd).name,'_')-1;
                    ftype_st=regexp(curr_files(knd).name,'\.')+1;
                    if ~isempty(id_s)
                        if  isempty(id_e)
                            id_e=ftype_st-2;
                        end
                        curr_ids(cnt)=str2num(curr_files(knd).name(id_s:id_e));
                        curr_ftype{cnt}=curr_files(knd).name(ftype_st:end);
                        curr_datenum(cnt)=curr_files(knd).datenum;
                        if strcmp(curr_ftype{cnt},'lvd')
                            curr_size(cnt)=curr_files(knd).bytes/1e+5;
                        elseif strcmp(curr_ftype{cnt},'bin')
                            curr_size(cnt)=curr_files(knd).bytes/1e+5;
                        else
                            curr_size(cnt)=0;
                        end
                    end
                end
            end
        end
    end
    
    for knd=1:length(stack_ids)
        matches=find(curr_ids==stack_ids(knd));
        if matches
            %             curr_val=0;
            %             for lnd=1:length(matches)
            %                 curr_val=curr_val+ftype_value(strcmp(ftypes,curr_ftype{matches(lnd)}));
            %             end
            found_it{knd,ind+length(paths_to_check_tmp)}=length(matches);
            datenum_check{knd,ind+length(paths_to_check_tmp)}=curr_datenum(matches);
            try
                fsizes(knd,1)=round(curr_size(matches(strcmp(curr_ftype(matches),'lvd'))))/10;
            catch
                fsizes(knd,1)=0;
            end
            try
                % if 2 bin files - this selects the first one
                tmp=round(curr_size(matches(strcmp(curr_ftype(matches),'bin')))/curr_size(matches(strcmp(curr_ftype(matches),'lvd'))));
                fsizes(knd,2)=tmp(1);
            catch
                fsizes(knd,2)=0;
            end
            
        end
    end
end




num_dirs=length(paths_to_check_tmp)+length(paths_to_check);
selection =[];
for knd=1:length(stack_ids)
    names{knd}=num2str(stack_ids(knd));
    dates{knd}=stack_dates{knd};
    if length(unique(cell2mat(found_it(knd,5:num_dirs))))==1 && (length(cell2mat(found_it(knd,5:num_dirs)))>1 || length(cell2mat(found_it(knd,num_dirs)))==1)
        found_it{knd,num_dirs+1}='';
    elseif length(cell2mat(found_it(knd,5:num_dirs-1)))>2
        found_it{knd,num_dirs+1}='X';
        selection = [selection knd];
    else
        found_it{knd,num_dirs+1}='X';
        selection = [selection knd];
    end
    cnt=0;
    tmp_datenum=[];
    
    if ~strcmp(found_it{knd,num_dirs+1},'X')
        for ind=length(paths_to_check_tmp)+1:size(datenum_check,2)
            if ~isempty(datenum_check{knd,ind})
                cnt=cnt+1;
                tmp_datenum(cnt,:)=datenum_check{knd,ind};
            end
        end
        if size(tmp_datenum,1)>1
            if sum(sum(abs(diff(tmp_datenum))))~=0
                found_it{knd,num_dirs+1}='C';
                selection = [selection knd];
            end
        end
    end
    
    found_it{knd,num_dirs+2}=animal_ids{knd};
    found_it{knd,num_dirs+3}=user_ids{knd};
    found_it{knd,num_dirs+4}=projects{knd};
end


label_str=['AD' '\t|\t' 'Stack' '\t|\t' 'Date' '\t\t|\t' 't1I' '\t' 't1X' '\t' 't2I' '\t' 't2X' '\t|\t' 'r1A' '\t' 'r1I' '\t' 'r1X' '\t'  'r1S' '\t' 'r2A' '\t'...
    'r2I' '\t' 'r2X' '\t' 'r2B' '\t' 'r3A' '\t' 'r4A' '\t' 'tun' '\t|\t' 'Arc' '\t|\t' 'con' '\t|\t' 'animal' '\t\t\t' 'user' '\t\t' 'proj' '\t'...
    'lvd[MB]' '\t' 'bin/lvd'];

if nargin==0
    fid=fopen([adata_dir '_ErrorLog\check_backup.txt.'],'wt');
    fprintf(fid,[label_str ' \n']);
end


if ~selX
    selection_all = 1:size(found_it,1);
    disp('_________________________________________________________________________________________________________________________________________________________________')
    disp(sprintf(label_str))
    disp('_________________________________________________________________________________________________________________________________________________________________')
    

    for ind=1:length(selection_all)
        if showNonArchivedOnly && sum([found_it{selection_all(ind),5:14}]) == 0 && found_it{selection_all(ind),15} > 0
            % do not display fully archived files if option is set
        else
            prntstr=[num2str(has_adata(selection_all(ind))) '\t|\t' names{selection_all(ind)} '\t|\t' dates{selection_all(ind)} '\t|\t' num2str(found_it{selection_all(ind),1}) '\t' num2str(found_it{selection_all(ind),2}) '\t' ...
                num2str(found_it{selection_all(ind),3}) '\t' num2str(found_it{selection_all(ind),4}) '\t|\t' num2str(found_it{selection_all(ind),5}) '\t' ...
                num2str(found_it{selection_all(ind),6}) '\t' num2str(found_it{selection_all(ind),7}) '\t' num2str(found_it{selection_all(ind),8}) '\t'  num2str(found_it{selection_all(ind),9}) '\t'...
                num2str(found_it{selection_all(ind),10}) '\t' num2str(found_it{selection_all(ind),11}) '\t' num2str(found_it{selection_all(ind),12}) '\t' num2str(found_it{selection_all(ind),13}) '\t'...
                num2str(found_it{selection_all(ind),14}) '\t' num2str(found_it{selection_all(ind),15}) '\t|\t' num2str(found_it{selection_all(ind),16}) '\t|\t' found_it{selection_all(ind),17} '\t|\t' ...
                found_it{selection_all(ind),18} '  \t' found_it{selection_all(ind),19} '  \t' found_it{selection_all(ind),20} '  \t' ...
                num2str(fsizes(selection_all(ind),1)) '  \t' num2str(fsizes(selection_all(ind),2)) '\n'];
            fprintf(prntstr);
            if nargin==0
                fprintf(fid,[prntstr]);
            end
        end
    end
    
    disp('_________________________________________________________________________________________________________________________________________________________________')
    disp(sprintf(label_str))
end

if ~isempty(selection)
    disp(' ')
    disp(' ')
    disp('******************************************** WARNING BACKUP PROBLEMS FOUND - FIX THESE IMMEDIATELY! *************************************************************')
    disp('_________________________________________________________________________________________________________________________________________________________________')
    disp(sprintf(label_str))
    disp('_________________________________________________________________________________________________________________________________________________________________')
    for ind=1:length(selection)
        prntstr=[num2str(has_adata(selection(ind))) '\t|\t' names{selection(ind)} '\t|\t' dates{selection(ind)} '\t|\t' num2str(found_it{selection(ind),1}) '\t' num2str(found_it{selection(ind),2}) '\t' ...
            num2str(found_it{selection(ind),3}) '\t' num2str(found_it{selection(ind),4}) '\t|\t' num2str(found_it{selection(ind),5}) '\t' ...
            num2str(found_it{selection(ind),6}) '\t' num2str(found_it{selection(ind),7}) '\t' num2str(found_it{selection(ind),8}) '\t' num2str(found_it{selection(ind),9}) '\t' ...
            num2str(found_it{selection(ind),10}) '\t' num2str(found_it{selection(ind),11}) '\t' num2str(found_it{selection(ind),12}) '\t' num2str(found_it{selection(ind),13}) '\t'...
            num2str(found_it{selection(ind),14}) '\t' num2str(found_it{selection(ind),15}) '\t|\t' num2str(found_it{selection(ind),16}) '\t|\t' found_it{selection(ind),17} '\t|\t' ...
            found_it{selection(ind),18} '  \t' found_it{selection(ind),19} '  \t' found_it{selection(ind),20} '  \t' ...
            num2str(fsizes(selection(ind),1)) '  \t' num2str(fsizes(selection(ind),2)) '\n'];
        fprintf(prntstr);
        if nargin==0
            fprintf(fid,[prntstr]);
        end
    end
    disp('_________________________________________________________________________________________________________________________________________________________________')
    disp(sprintf(label_str))
    disp('******************************************** WARNING BACKUP PROBLEMS FOUND - FIX THESE IMMEDIATELY! *************************************************************')
end


if nargin==0
    fprintf(fid,[label_str ' \n']);
    fclose(fid);
end

if successfully_connected
    setSMTPprefGmail;
    
    Xinds=[find(strcmp(found_it(:,num_dirs+1),'X'))' find(strcmp(found_it(:,num_dirs+1),'C'))'];
    
    users_to_remind=unique(user_ids(Xinds));
    
    projects_to_remind=projects(Xinds);
    
    for ind=1:length(users_to_remind)
        projects_of_curr_user=unique(projects_to_remind(strcmp(users_to_remind{ind},user_ids(Xinds))));
        email=[uname2email(users_to_remind{ind}) '@fmi.ch'];
        sendmail(email,'URGENT - data backup ERROR', ...
            ['Please check your backup by running check_backup(''username'') and correct all X''s and C''s. ' 10 ...
            'X means inconsistent number of files in different backup locations' 10 ...
            'C means inconsistent time stamp on the files in different locations' 10 ...
            'The following projects are affected: ' 10 ...
            strjoin(projects_of_curr_user,' - ')]);
    end
    
    % write to check_backup_Xlog.txt
    fn=[adata_dir '_ErrorLog\check_backup_Xlog.txt'];
    fid=fopen(fn,'a');
    for ind=1:length(Xinds)
        fprintf(fid,'\r\n %s',[num2str(stack_ids(Xinds(ind))) ' - ' user_ids{Xinds(ind)} ' - ' projects{Xinds(ind)} ' - ' datestr(now) ]);
    end
    fclose(fid);
else
    disp('Did not successfully connect to all shares and will not send reminder emails or save to error log');
end







