function [data_path,ExpIDinfo]=get_data_path_all(ExpID,ExpIDinfo,ExpLog)
% [data_path]=GET_DATA_PATH(ExpID) returns one raw data location of the experiment ExpID
% finds the closest actual data location of an experiment - will always
% load from localhost if data are available
%
% (optional) Pass ExpIDinfo to prevent it from being rederived
%
% AA 29.05.2014
% FW 2018 mod   include archive and stackIDs in search

[~,backup_paths,arc_path]=define_backup_paths(1);

%% get the ExpLog
if ~exist('ExpIDinfo','var')  || isempty(ExpIDinfo)
    if ~exist('ExpLog','var')  || isempty(ExpLog)
        ExpLog=getExpLog;
    end
    % calliope sometimes converts these cell arrays already, if not do it
    if isa(ExpLog.expid,'cell')
        ExpLog.expid = cell2mat(ExpLog.expid);
    end
    if isa(ExpLog.stackid,'cell')
        ExpLog.stackid = cell2mat(ExpLog.stackid);
    end
    stacks_ind=find(ExpLog.stackid==ExpID);
    
    if ~isempty(stacks_ind)
        ExpIDs=ExpLog.stackid(stacks_ind);
    else
        warning('No matching entry in database found. Aborting');
        data_path=[];
        return
    end
    
    proj=unique(ExpLog.project(stacks_ind));
    ExpIDinfo.proj=proj{1};
    
    userID=unique(ExpLog.pi(stacks_ind));
    ExpIDinfo.userID=userID{1};
    
    mouse_id=unique(ExpLog.animalid(stacks_ind));
    ExpIDinfo.mouse_id=mouse_id{1};
    
    pdef=getProjDef(proj{1});
    ExpIDinfo.main_channel=pdef.main_channel;
    ExpIDinfo.secondary_channels = pdef.secondary_channels;
elseif nargin == 2
    eval(['pdef=ProjectDefaults_' ExpIDinfo.proj ';']);
end
%%
global hostname
if isempty(hostname)
    [~,hostname]=system('hostname');
    % "name" ends on a carriage return in Win7
    hostname=hostname(hostname~=10);
end
localname = ['\\' hostname '.fmi.ch\RawData'];



%% first check on local machine, then the anas, then the rest
searchlist = unique([localname;pdef.backup_destination(:); backup_paths(1,1);backup_paths(4,1);backup_paths(:,1);arc_path],'stable');

nLocations = size(searchlist,1);

fn_lvd = [ExpIDinfo.userID '\' ExpIDinfo.mouse_id  '\' 'S1-T' num2str(ExpID) '.lvd'];
fn_bin = [ExpIDinfo.userID '\' ExpIDinfo.mouse_id  '\' 'S1-T' num2str(ExpID) '_' ExpIDinfo.main_channel '.bin'];

for ii = 1:nLocations
    if ~isempty(dir([searchlist{ii} '\' fn_lvd]))
        %found the file on this machiene
        data_path=[searchlist{ii} '\'];
        return
    end
end
warning('no lvd files found for ExpID %d - will try bin',ExpID)

searchlist = unique([localname;pdef.backup_destination(:); backup_paths(1,1);backup_paths(4,1);backup_paths(:,1);arc_path],'stable');

for ii = 1:nLocations
    if ~isempty(dir([searchlist{ii} '\' fn_bin]))
        %found the file on this machiene
        data_path=[searchlist{ii} '\'];
        return
    end
end
warning('no bin files found for ExpID %d',ExpID)

data_path = [];
return;





