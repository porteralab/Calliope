function repository_collisions(myproj,verbose,active_mode)
% checks for repository collisions between calliope and other folders in
% current path. Can remove duplicates from current path. Default only
% checks for collisions between folders 'calliope' and 'projectanalysis'.
%
% parameters:
% verbose       will only check 'projectanalysis' and 'calliope' folders conflicts
%               per default, unless specified here
% myproj        will check collisions with given regexp
% active_mode   asks to remove conflicting paths from current session
%
% examples:
% repository_collisions('XXX')      %checks all collisions for XXX with calliope
%                                    will automatically list all conflicts
% repository_collisions([],1)       %list all conflicts in path variable
% repository_collisions()           %list all conflicts with calliope and
%                                    projectanaylsis folders
% repository_collisions('XXX',[],1) %checks conflicts with XXX and calliope
%                                    asks to remove projectanalysisfolders
%                                    from current path
% repository_collisions('register') %checks conflicts with files/folders
%                                    containing 'register' (regular expression)
%
% 2018 FW

if ~exist('active_mode','var')|| isempty(active_mode),active_mode=0; end
if ~exist('verbose','var') || isempty(verbose),verbose=[]; end
if ~exist('myproj','var')|| isempty(myproj),myproj=[]; end

contains_regex=@(paths,regex) ~cellfun('isempty',regexpi(paths,regex)); %make compatible with matlab <2017

P=strsplit(path, pathsep());
P=cellfun(@(x) what(x),P,'UniformOutput',false);
P=vertcat(P{:});
m_files=arrayfun(@(x) x.m,P,'UniformOutput',false);
m_files=vertcat(m_files{:});
m_paths=arrayfun(@(x) repmat({x.path},size(x.m)),P,'UniformOutput',false);
m_paths=vertcat(m_paths{:});
[uniq_m_files,~,~]=unique(m_files);

collision_count=0;
colliding_folders={};

if isempty(verbose) %remove files/paths that don't contain projectanalysis or calliope keywords
    logi=contains_regex([m_paths],'\\projectanalysis|\\calliope') | contains_regex([m_files],'\\projectanalysis|\\calliope');
    [m_paths,m_files]=deal(m_paths(logi),m_files(logi));
end

for ind=1:numel(uniq_m_files)
    logi=strcmpi(uniq_m_files{ind},m_files);
    if sum(logi)>1 && any(contains_regex([m_paths(logi);m_files(logi)],'\\calliope')) && ( isempty(myproj) || any(contains_regex([m_paths(logi);m_files(logi)],myproj)) ) ...
            && (~isempty(verbose) || any(contains_regex([m_paths(logi);m_files(logi)],'\\projectanalysis')))
        fprintf('duplicate ')
        fprintf(2,'%s',uniq_m_files{ind});
        fprintf(' at paths\n\t');
        fprintf('%s\n\t',m_paths{logi});
        fprintf('\n');
        collision_count=collision_count+1;
        matched=m_paths(logi);
        colliding_folders=vertcat(colliding_folders,unique(matched(contains_regex(matched,'\\ProjectAnalysis'))));
    end
end
colliding_folders=unique(colliding_folders);

%remove paths from current Matlab session
if collision_count>0 && active_mode
    fprintf('\n\n\n');
    warning('calliope repository collisions (%ix) were detected.',collision_count)
    [~,colliding_projs,~]=regexpi(colliding_folders,'\\Analysis_([A-Z0-9]+)\\*','match','tokens','once');
    colliding_projs=unique(vertcat(colliding_projs{~cellfun('isempty',colliding_projs)}));
    fprintf('\n\n Following folders will be removed from PATH in this Matlab session:\n');
    fprintf(2,'%s\n',colliding_folders{:});
        rmpath(colliding_folders{:})
end

end
