function [ExpIDinfo,data_dirOut]=read_info_from_ExpLog(ExpID,suppress_warning)
% read_info_from_ExpLog outputs information about a specific experiment in
% the database.
%
% ExpID: experiment ID as in ExpLog
% data_dir: the raw data directory
%
% ExpIDinfo: output structure containing project name, user name, mouse ID
% file names and aux file names.
%
% Use the specific experiment ID as input.
% e.g. read_info_from_ExpLog(24790,data_dir);
%
% documented by DM - 08.05.2014
% adapted by AA - 29.05.2014 will now look in all possible locations for
% the data and return absolut paths, also for the transition phase,
% data_dir is returned

if nargin<2
    suppress_warning=0;
end

ExpIDinfo = struct;

no_primary_data=0;

ExpLog=getExpLog;

stacks_ind=find(cell2mat(ExpLog.expid)==ExpID);

if ~isempty(stacks_ind)
    ExpIDs=cell2mat(ExpLog.stackid(stacks_ind));
else
    disp('No matching experiment ID in database found. Aborting');
    return
end

proj=unique(ExpLog.project(stacks_ind));
ExpIDinfo.proj=proj{1};
pdef=getProjDef(proj{1});

ExpIDinfo.main_channel=pdef.main_channel;
ExpIDinfo.secondary_channels = pdef.secondary_channels;

userID=unique(ExpLog.pi(stacks_ind));
ExpIDinfo.userID=userID{1};

mouse_id=unique(ExpLog.animalid(stacks_ind));
ExpIDinfo.mouse_id=mouse_id{1};

site_id=cell2mat(ExpLog.siteid(stacks_ind));
ExpIDinfo.site_id=site_id(1);


data_dir = get_data_path(ExpID,ExpIDinfo);
if isempty(data_dir)
    error('no bin files found')
end
fn = [data_dir ExpIDinfo.userID '\' ExpIDinfo.mouse_id  '\'];

if exist([fn 'S1-T' num2str(ExpIDs(1)) '_' ExpIDinfo.main_channel '.bin'],'file')
    for ind=1:length(ExpIDs)
        ExpIDinfo.fnames{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '_' ExpIDinfo.main_channel '.bin'];
    end
elseif exist([fn 'S1-T' num2str(ExpIDs(1)) '.wid'],'file')
    for ind=1:length(ExpIDs)
        ExpIDinfo.fnames{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '.wid'];
    end
else
    no_primary_data=1;
    if ~suppress_warning
        warning('failed to find bin file, maybe you need to update your pdef file to add main and secondary channels')
    end
end
% elseif exist([fn 'S1-T' num2str(ExpIDs(1)) '_ch610.bin'],'file')
%     for ind=1:length(ExpIDs)
%         ExpIDinfo.fnames{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '_ch610.bin'];
%     end
% end

if ~isempty(ExpIDinfo.secondary_channels)
    if exist([fn 'S1-T' num2str(ExpIDs(1)) '_' ExpIDinfo.secondary_channels{1} '.bin'],'file')
        for ind=1:length(ExpIDs)
            if no_primary_data==1
                ExpIDinfo.fnames{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '_' ExpIDinfo.secondary_channels{1} '.bin'];
                ExpIDinfo.sec_fnames={};
            else
                ExpIDinfo.sec_fnames{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '_' ExpIDinfo.secondary_channels{1} '.bin'];
            end
        end
    else
        if ~suppress_warning
            warning('failed to find secondary bin file')
        end
        ExpIDinfo.sec_fnames={};
    end
else
    ExpIDinfo.sec_fnames={};
end


for ind=1:length(ExpIDs)
    ExpIDinfo.aux_files{ind} = [fn 'S1-T' num2str(ExpIDs(ind)) '.lvd'];
end

if nargout==2
    data_dirOut = data_dir;
end