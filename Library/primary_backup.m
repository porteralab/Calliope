function results=primary_backup(proj, exp_ids, varargin)

% primary data backup function
% input:
%       proj - the project you want to back up data for
%       exp_ids  - experimental IDs
% optional inputs
%       'md5',option          - check MD5 sum for file integrity (default: 1)
%       'email','emailadress' - notification per email with summary 
%
% e.g. primary_backup('OMM',10000:10005);
%      primary_backup('OMM',[10000, 10020],'email','marcus.leinweber'); 
%
% for a new setup, add file locations in primary_backup_define.m
% ML

if ~isstr(proj)
    disp('Input argument error!');
    disp('usage: primary_backup(projID,ExpIDs);');
    return
end

persistent strCR % for textprogressbar
textprogressbar('inittextprogressbar')

md5check = 0;
email = [];
messages = {'Backup Script'};

if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin(1:end-1), 'char'));
    for ind = 1:length(numIndex)
        switch lower(varargin{numIndex(ind)})
            case 'md5'
                md5check = varargin{numIndex(ind) + 1};
            case 'email'
                email = varargin{numIndex(ind) + 1};
        end
    end
end

warnings = {};
disp('clearing ExpLog in ''base'' workspace'); 
evalin('base','clear ExpLog');
ExpLog=getExpLog;
assignin('base','ExpLog', ExpLog);

% proj=ExpLog.project{find(cell2mat(ExpLog.expid)==exp_ids(1),1,'first')};

[isok, source_dir, backup_loc] = primary_backup_define(proj);
if ~isok
    
    return
end
no_backup_loc = size(backup_loc,2);

% path md5.exe later on
path_mfile = fileparts(which(mfilename));


exp_id_inds = find(ismember(cell2mat(ExpLog.expid),exp_ids));

% ignore ExpIDs from different projects
projs = ExpLog.project(exp_id_inds);
exp_id_inds = exp_id_inds(strcmp(proj,projs));

StackIDs = cell2mat(ExpLog.stackid(exp_id_inds));
fprintf(['Following stacks were found in DB: ' num2str(cell2mat(ExpLog.stackid(exp_id_inds))') '\n'])
animal_id = ExpLog.animalid(exp_id_inds);
user_id = ExpLog.pi(exp_id_inds);




% built file locations
sources_files = {};
backup_files = {};
total_size = 0;
fprintf('\n');
textprogressbar('Put all file locations together:     ');
for ind = 1:length(StackIDs)
    textprogressbar(ind/length(StackIDs)*100);
    for jnd = 1:size(source_dir,2)
        d = dir(fullfile(source_dir{jnd},[ '*' num2str(StackIDs(ind)) '*']));
        if size(d,1) > 0
            total_size = total_size + sum([d.bytes]);
            for knd = 1:size(d,1)
                sources_files{end+1} = fullfile(source_dir{jnd},d(knd).name);
                for lnd = 1:no_backup_loc
                    backup_files{end+1} = fullfile(backup_loc{lnd},user_id{ind},animal_id{ind},d(knd).name);
                end
            end
        end
    end
end
no_source_files = size(sources_files,2);
no_backup_files = size(backup_files,2);
textprogressbar(' done');

if no_source_files == 0
    disp('ERROR !!! - could not find any data to copy. did you export your labnotes?');
    disp('Or you are not using ExpIDs...');
    return;
end

textprogressbar('Check space on backup locations:     ');
for ind = 1:no_backup_loc
    if disk_free(backup_loc{ind}) < total_size
        textprogressbar(' error');
        error(['Not enough disk space on backup location: ' backup_loc{ind}]);
    else
        messages{end+1} = ['Backup location ' num2str(ind) ': ' backup_loc{ind}];
    end
    textprogressbar(ind/no_backup_loc*100);
end
textprogressbar(' done');

textprogressbar('Copying files:                       ');
for ind = 1:no_backup_files
    % check whether directory exist
    if ~isdir(fileparts(backup_files{ind}))
        mkdir(fileparts(backup_files{ind}));
    end
    textprogressbar(ind/no_backup_files*100);
    if ~exist(backup_files{ind},'file')
%         disp(['-> ' sources_files{ceil(ind/no_backup_loc)} ' >> ' backup_files{ind}]);
        [success(ind),mtext] = copyfile(sources_files{ceil(ind/no_backup_loc)},backup_files{ind});
    else
        warnings{end+1} = ([backup_files{ind} ' - FILE ALREADY EXISTS - skipping.']);
        success(ind) = 1;
    end
    if ~success(ind)
        warnings{end+1} = strtrim([backup_files{ind} ' - Some problem with copying: ' mtext]);
        success(ind) = 0;
    end
end
textprogressbar(' done');

mdsum_s = {};
mdsum_c = zeros(1,no_backup_files);
mdsum_b = {};
if md5check
    textprogressbar('Calculating MD5 for source files:    ');
    for ind = 1:no_source_files
        textprogressbar(ind/no_source_files*100);
        [s,w] = dos([path_mfile '\md5.exe ' sources_files{ind}]);
        if s == 0
            w = regexp(w, ' ', 'split');
            mdsum_s{ind} = w{1};
        else
            mdsum_s{ind} = {-1};
        end
    end
    textprogressbar(' done');
    
    textprogressbar('Calculating MD5 for backup files:    ');
    for ind = 1:no_backup_files
        textprogressbar(ind/no_backup_files*100);        
        [s,w] = dos([path_mfile '\md5.exe ' backup_files{ind}]);
        if s == 0
            w = regexp(w, ' ', 'split');
            mdsum_b{ind} = w{1};
        else
            mdsum_b{ind} = {0};
        end
    end
    textprogressbar(' done');
    
    textprogressbar('Comparing MD5 sums:                  ');
    for ind = 1:no_backup_files
        mdsum_c(ceil(ind/no_backup_loc)) = mdsum_c(ceil(ind/no_backup_loc)) + ...
            strcmp(mdsum_b{ind},mdsum_s{ceil(ind/no_backup_loc)});
        textprogressbar(ind/no_backup_files*100);
    end
    textprogressbar(' done');
end

% plot summary
messages{end+1} = ['Animal' char(9) char(9) '|StackID |' char(9) 'No.files |'...
    char(9) 'No.files copied |' char(9) 'MD5 OK'];
for ind = 1:length(StackIDs)
    inds = cellfun(@(x)(~isempty(x)),regexp(sources_files,num2str(StackIDs(ind))));
    inds2 = repmat(inds,[no_backup_loc 1]);
    inds2 = logical(inds2(:)');
    messages{end+1} = [animal_id{ind} ' | ' num2str(StackIDs(ind)) char(9) ' |' ... 
        char(9) char(9) num2str(sum(inds)) ' |' char(9) char(9) char(9) char(9) ...
        num2str(sum(success(inds2))) char(9) ' |' char(9) char(9) ...
        num2str(sum(mdsum_c(inds))) ];
end
if sum(success) == no_backup_loc
    messages{end+1} = [num2str(total_size/1024^3) 'GB of data was transferred to ' num2str(no_backup_loc) ' locations.'];
end
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
    sendmail(email,'backup script',messages);
end

results.sources_files = sources_files;
results.backup_files = backup_files;
results.copiedsuccess = success;
results.mdsum_s = mdsum_s;
results.mdsum_b = mdsum_b;
results.warnings = warnings;


