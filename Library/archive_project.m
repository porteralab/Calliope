function results=archive_project(projID,hostname,varargin)
%% use this function to copy all data of one project to tape
%  results=archive_project(projID,hostname,varargin)
% GK 19.01.2016


if ~isstr(projID)
    disp('Input argument error!');
    disp('usage: archive_project(projID);');
    return
end


md5check = 1;
email = [];
messages = {'Tape backup script'};

if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin(1:end-1), 'char'));
    for ind = 1:length(numIndex)
        switch lower(varargin{numIndex(ind)})
            case 'email'
                email = varargin{numIndex(ind) + 1};
            case 'md5'
                md5check = varargin{numIndex(ind) + 1};
        end
    end
end

warnings = {};
ExpLog=getExpLog;
assignin('base','ExpLog', ExpLog);

source_dir = ['\\' hostname '\RawData\'];
[~,~,archive_path]=define_backup_paths(1);
backup_loc = [archive_path '\'];

% path md5.exe later on
path_mfile = fileparts(which(mfilename));


% exp_id_inds = find(ismember(cell2mat(ExpLog.expid),exp_ids));
exp_id_inds =find(strcmp(ExpLog.project,projID));

StackIDs = cell2mat(ExpLog.stackid(exp_id_inds));
animal_id = ExpLog.animalid(exp_id_inds);
user_id = ExpLog.pi(exp_id_inds);


% built file locations
sources_files = {};
backup_files = {};
total_size = 0;
fprintf('\n');
textprogressbar('Putting all file locations together:     ');
for ind = 1:length(StackIDs)
    textprogressbar(ind/length(StackIDs)*100);
    
    d = dir(fullfile(source_dir,user_id{ind},animal_id{ind},[ '*' num2str(StackIDs(ind)) '*']));
    if size(d,1) > 0
        total_size = total_size + sum([d.bytes]);
        for knd = 1:size(d,1)
            sources_files{end+1} = fullfile(source_dir,user_id{ind},animal_id{ind},d(knd).name);
            backup_files{end+1} = fullfile(backup_loc,user_id{ind},animal_id{ind},d(knd).name);
        end
    end
    
end

no_backup_files = size(backup_files,2);
textprogressbar(' done');

mdsum_c = zeros(1,no_backup_files);

textprogressbar('Copying files and calculating MD5 checksum:                       ');
fprintf('\n')
for ind = 1:no_backup_files
    % check whether directory exist
    if ~isdir(fileparts(backup_files{ind}))
        mkdir(fileparts(backup_files{ind}));
    end
    textprogressbar(ind/no_backup_files*100);
    if ~exist(backup_files{ind},'file')
        fprintf('\n')
        fprintf(['  -> ' regexprep(sources_files{ceil(ind)},'\\','\\\\') ' >> ' regexprep(backup_files{ind},'\\','\\\\')]);      
        [success(ind),mtext] = copyfile(sources_files{ind},backup_files{ind});
        if md5check
            [~,wd] = dos([path_mfile '\md5.exe ' backup_files{ind}]);
            wd = regexp(wd, ' ', 'split');
            [~,ws] = dos([path_mfile '\md5.exe ' sources_files{ind}]);
            ws = regexp(ws, ' ', 'split');
            
            if ~strcmp(ws,wd)
                disp(['CRITICAL WARNING - md5 checksum failed on ' backup_files{ind}]);
                warnings{end+1} = ([backup_files{ind} ' - !!!! ---- CRITICAL CHECKSUM FAILURE. ---- !!!!']);
            end
            
            mdsum_c(ind) = mdsum_c(ind) + strcmp(ws{1},wd{1});
        end
        
        
    else
        warnings{end+1} = ([backup_files{ind} ' - FILE ALREADY ARCHIVED - skipping.']);
        success(ind) = 1;
    end
    if ~success(ind)
        warnings{end+1} = strtrim([backup_files{ind} ' - Some problem with copying: ' mtext]);
        success(ind) = 0;
        ExpID=regexp(backup_files{1},'T\d*[._s]','match');
        ExpID=ExpID{1}(2:end-1);
        writeErrorLog(ExpID,'ARCHIVE MD5 checksum error')
    end
end
textprogressbar(' done');


% plot summary
messages{end+1} = ['Animal' char(9) char(9) '|StackID |' char(9) 'No.files |'...
    char(9) 'No.files copied |' char(9) 'MD5 OK'];
for ind = 1:length(StackIDs)
    inds = cellfun(@(x)(~isempty(x)),regexp(sources_files,num2str(StackIDs(ind))));
    inds = logical(inds(:)');
    messages{end+1} = [animal_id{ind} ' | ' num2str(StackIDs(ind)) char(9) ' |' ... 
        char(9) char(9) num2str(sum(inds)) ' |' char(9) char(9) char(9) char(9) ...
        num2str(sum(success(inds))) char(9) ' |' char(9) char(9) ...
        num2str(sum(mdsum_c(inds))) ];
end

messages{end+1} = [num2str(total_size/1024^3) 'GB of data was transferred to the archive.'];

if ~isempty(warnings)
    messages{end+1} = 'Warnings/ Errors: ';
    messages = [messages warnings];
end

for ind = 1:size(messages,2)
    fprintf([regexprep(messages{ind},'\\','\\\\') '\n'])
end

% send email notification
if ~isempty(email)
    setSMTPprefGmail;
    if isempty(regexp(email,'\@','once'))
        email = [email '@fmi.ch'];
    end
    sendmail(email,'archive backup script',messages);
end

results.sources_files = sources_files;
results.backup_files = backup_files;
results.copiedsuccess = success;
results.warnings = warnings;
