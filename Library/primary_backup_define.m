function [isok, backup_source_dir, backup_destination] = primary_backup_define(proj)

% Interface to confirm back up destinations for the user
%--------------------------------------------------------------------------
%(embedded in primary_backup.m)
% doc edited by AF, 08.05.2014

isok = 0;
[~,host] = dos('hostname');
host = lower(strtrim(host));
proj_def_file = ['ProjectDefaults_' proj];
if exist(proj_def_file,'file')~=2
    error(['Did not find your project definition file:' proj_def_file])
end

f=eval(proj_def_file);
backup_source_dir = f.backup_source_dir;
backup_destination = f.backup_destination;
%[~,backup_source_dir,backup_destination]=define_proj_paths(proj);

disp(['I''m ' deblank(host) '. Nice to see you! Let''s see whether everything is all right.']);

no_backup_loc = size(backup_destination,2);

for ind = 1:no_backup_loc
    fprintf('%s%s',backup_destination{ind},char(13))
end
answer = input('These ones are your backup locations. Correct [y/n]? ','s');
if strcmpi(deblank(answer),'y') || isempty(strtrim(answer))
    isok = 1;
else
    disp('Aborting ...')
    disp('Please define your project paths in ''define_proj_paths'' and try again')
    isok = 0;
    return
end
