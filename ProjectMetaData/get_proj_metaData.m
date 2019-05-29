function proj_meta=get_proj_metaData(projID,Acode,varargin)
%PROJ_META=GET_PROJ_METADATA(projID,Acode,varargin) generates project meta (proj_meta) file on M: based on analysis code (Acode) in ExpLog
%
% e.g. Acode = '1' means all files with code '1' will be included in analysis
%
% .lvd files are loaded automatically. To load other auxiliary data use the following
% conventions:
%
%   'load_eye' for .eye files
%   'load_eyeR' for .eyeR files
%   'load_vid' for .vid2 files
%   'load_ton' for .ton files
%   'behave' to create a behavioural meta file
%   'filename' 'NameOfMetaFile' to name your meta file differently from projID
%   'licktraceraw' include raw trace of licking data (1) or subsampled data (0) 
% e.g. get_proj_metaData('ACC','3','load_eye','load_vid');
%
% parse comment file for session id (fb,pb,dark,ori):
% e.g. get_proj_metaData('ACC','3','sess',1);
%
% alternative filename:
% e.g. get_proj_metaData('ACC','3','filename','ACC_L5');
%
% written by PZ & GK 2013-03-11
% modified ML 2013-09-05
% modified PZ 2013-09-25
% modified PZ 2014-02-07 alternative filename
% modified PZ 2014-04-05 load vid
% modified PZ 2014-05-09 incorporated getProjDef and cleaned up code
% modified AF 2014-08-07 incorporated patch in the event that some ExpID's are missing the full number of aux channels
% modified PZ 2015-04-26 included a unique statement for project ACX for aux channel 'aud trig'
% modified PZ 2015-12-06 addition of condition for missing channel assignement
% modified FW 2018-02-28 switch for parallel processing, 
% modified FW 2018-04-11 added loading channels from .ach file
% modified FW 2019-01-30 added switch to load all columns of metainfo file automatically (independent of projectDefinitions file)

if nargin == 0
    error('You need to provide at least the projID');
end

if nargin < 2
    Acode = '1';
    warning('assuming ''1'' as Acode, since not provided.');
end
if isfloat(Acode)
    Acode = num2str(Acode);
end

assignin('base','tmpAcode',str2double(Acode));
load_ftypes={};
load_ftypes{1}='.ini';
load_ftypes{2}='.lvd';
just_behave=0;
licktraceraw = 0;
use_ach_flag=0;
par=0;
minfo_auto=0;

determine_session = 0;
if isempty(Acode)
    filename = [projID '_meta'];
else
    filename = [projID '_' num2str(Acode) '_meta'];
end

cnt = size(load_ftypes,2)+1;
if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin, 'char'));
    for ind = 1:length(numIndex)
        switch varargin{numIndex(ind)}
            case 'load_eye'
                load_ftypes{cnt}='.eye';
                cnt=cnt+1;
            case 'load_eyeR'
                load_ftypes{cnt}='.eyeR';
                cnt=cnt+1;
            case 'load_vid'
                load_ftypes{cnt}='.vid2';
                cnt=cnt+1;
            case 'load_ton'
                load_ftypes{cnt}='.ton';
                cnt=cnt+1;
            case {'behave','behave_only','beh','beh_only'}
                fprintf('only loading behavioral data\n');
                just_behave=1;
                nbr_piezo_layers=1;
                load_ftypes={};
                load_ftypes{1}='.lvd';
            case 'licktraceraw'
                licktraceraw = varargin{numIndex(ind) + 1};
            case 'sess'
                determine_session = varargin{numIndex(ind) + 1};
            case 'filename'
                filename = varargin{numIndex(ind) + 1};
            case {'parallel','par'}
                par = varargin{numIndex(ind) + 1};
                ispar=ver; ispar={ispar.Name}; ispar=cell2mat(regexpi(ispar,'Parallel Computing Toolbox'));
                if isempty(ispar)
                    warning('''Parallel Computing Toolbox'' not installed but *parallel processing enforced*. Use at your own risk!');
                end
            case {'minfo','minfoauto','metainfoauto','minfo_auto'}
                minfo_auto=1;
                fprintf('including all metaInfo columns automatically\n');
            case {'use_ach','parse_ach','ach'}
                use_ach_flag=1;
        end
    end
end

ExpLog=getExpLog;
pdef=getProjDef(projID);
adata_dir=set_lab_paths;
meta_save_dir=[adata_dir '_metaData\'];

if isfield(pdef,'meta_info_columns')
    try
        mi_fn=[adata_dir '_metaInfo\MetaInfo-' projID '.xlsx'];
        [~,~,meta_info]=xlsread(mi_fn);
    catch
        disp('No metaInfo file found. Please use generateMetaInfo(projID) to create one.')
        return
    end
end

if ~isempty(Acode)
    indices = strcmp(ExpLog.project,projID) & strcmp(ExpLog.analysiscode,Acode);
else
    indices = strcmp(ExpLog.project,projID);
end
all_proj_stackIDs = [cell2mat(ExpLog.siteid(indices)), cell2mat(ExpLog.expid(indices)), cell2mat(ExpLog.stackid(indices))];
[~,uniqueStacks]=unique(all_proj_stackIDs(:,2));
all_proj_expIDs = all_proj_stackIDs(uniqueStacks,1:2);
all_proj_siteIDs = unique(all_proj_expIDs(:,1));
all_proj_comments = ExpLog.comment(indices);

animals={};
locations={};
for lnd=1:length(all_proj_siteIDs)
    animals{lnd} = cell2mat(ExpLog.animalid(find(cell2mat(ExpLog.stackid)==all_proj_siteIDs(lnd),1,'first')));
    locations{lnd} = cell2mat(ExpLog.location(find(cell2mat(ExpLog.stackid)==all_proj_siteIDs(lnd),1,'first')));
end

animalIDs = uniquecell(animals);
siteOrder=zeros(length(all_proj_siteIDs),1);
for hnd=1:length(animalIDs)
    cur_inds=ismember(animals,animalIDs(hnd));
    order=1:sum(cur_inds);
    siteOrder(cur_inds)=order;
end

load_eye = [];
load_eyeR = [];
load_vid = [];
load_ton = [];
frame_times = [];

proj_meta=struct;
meta_cnt=1;
for knd=1:length(all_proj_siteIDs)
    cur_site=all_proj_siteIDs(knd);
    cur_exps=all_proj_expIDs(all_proj_expIDs(:,1)==cur_site,2);
    display(['************ Adding site ' num2str(all_proj_siteIDs(knd)) ' to meta file ************'])
    tic
    for tp_cnt=1:length(cur_exps)
        if use_ach_flag
            pdef=parse_ach(pdef,cur_exps(tp_cnt));
        end
        if strcmp(projID,'SCR')
            if cur_exps(tp_cnt)<=26875
                pdef.aux_chans{2,2}='VRy';
                pdef.aux_chans{3,2}='RewardTrig';
                pdef.aux_chans{4,2}='Lick';
            else
                pdef.aux_chans{2,2}='RewardTrig';
                pdef.aux_chans{3,2}='Lick';
                pdef.aux_chans{4,2}='VRy';
            end
        end
        idata=[];
        idataR=[];
        v2data=[];
        ldata=[];
        data_dir=get_data_path(cur_exps(tp_cnt));
        if just_behave
            load_exp(cur_exps(tp_cnt),adata_dir,load_ftypes,ExpLog,'caller',1)
        else
            load_exp(cur_exps(tp_cnt),adata_dir,load_ftypes,ExpLog,'caller')
        end
        load_eye = ~isempty(idata);
        load_eyeR = ~isempty(idataR);
        load_vid = ~isempty(v2data);
        load_ton = ~isempty(ldata);
        
        if just_behave==0
            [adata_file,mouse_id,userID]=get_adata_filename(cur_exps(tp_cnt),adata_dir,ExpLog);
            if isempty(adata_file), continue; end
            orig=load([adata_dir userID '\' mouse_id '\' adata_file],'ROIs','nbr_frames','aux_files','template','act_map','fnames','dx','dy');
            if ~isempty(pdef.secondary_channels)
                
                sec_channel=load([adata_dir userID '\' mouse_id '\' adata_file],'template_sec');
                
            else
                sec_channel = struct();
            end
            if tp_cnt==1
                try
                    %old path naming convention
                    nbr_piezo_layers=readini([data_dir userID '\' mouse_id '\S1-T' num2str(cur_exps(tp_cnt)) '_ch525.ini'],'piezo.nbrlayers');
                    if isempty(nbr_piezo_layers)
                        nbr_piezo_layers=1;
                    end
                catch err
                    if strcmp(err.identifier,'MATLAB:FileIO:InvalidFid')
                        %error probably caused by new file naming convetion
                        nbr_piezo_layers=readini([orig.fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
                    else
                        
                        nbr_piezo_layers=1;
                        disp('ATTENTION - could not read nbr of piezo layers from ini file')
                    end
                end
            end
            noROIs=zeros(nbr_piezo_layers,1);
            if iscell(orig.template)
                for ynd=1:length(orig.ROIs)
                    nROIs(ynd)=size(orig.ROIs{ynd},2);
                end
                if sum(nROIs==1)==length(nROIs)
                    display('No ROIs selected')
                    noROIs(:)=1;
                else
                    for znd=1:nbr_piezo_layers
                        try
                            if ~isfield(orig.ROIs{znd}(1),'activity')
                                display(['Activity has not been calculated for layer ' num2str(znd)])
                                noROIs(znd)=1;
                            end
                        catch
                            display(['There is a problem with layer ' num2str(znd)])
                            noROIs(znd)=1;
                        end
                    end
                end
            else
                if size(orig.ROIs,2)==1
                    display('No ROIs selected')
                    noROIs=1;
                elseif ~isfield(orig.ROIs(1,1),'activity')
                    display('Activity has not been calculated')
                    noROIs=1;
                end
            end
        end
        
        
        if load_eye
            % eye data correction
            if strcmp(projID,'LFM')
                [xls_num,xls_txt]=xlsread('\\argon.fmi.ch\keller.g\ProjectData\LFM\LFM_infoI.xlsx','eye vid');
                if strcmp(xls_txt(find(xls_num(:,3)==cur_exps(tp_cnt))+1,6),'bad')
                    for rnd=1:size(idata,3)
                        idata(:,:,rnd)=ntzo(idata(:,:,rnd));
                    end
                end
            end
            [~, pupil_diam, pupil_pos, blink] = find_saccades(idata);
            [pupil_diam,pupil_pos,blink] = map_eye_data_to_frame_times(pupil_diam,pupil_pos,blink,frame_times,iframe_times);
        end
        if load_eyeR
            % eye data correction
            if strcmp(projID,'LFM')
                [xls_num,xls_txt]=xlsread('\\argon.fmi.ch\keller.g\ProjectData\LFM\LFM_infoI.xlsx','eye vid');
                if strcmp(xls_txt(find(xls_num(:,3)==cur_exps(tp_cnt))+1,6),'bad')
                    for rnd=1:size(idataR,3)
                        idataR(:,:,rnd)=ntzo(idataR(:,:,rnd));
                    end
                end
            end
            [~, pupil_diamR, pupil_posR, blinkR] = find_saccades(idataR);
            [pupil_diamR,pupil_posR,blinkR] = map_eye_data_to_frame_times(pupil_diamR,pupil_posR,blinkR,frame_times,iframe_timesR);
        end
        if load_vid
            if strcmp(projID,'ACX')
                [vid_vel] = vel_from_vid(v2data);
                tmp_vid_vel = zeros(1,length(frame_times));
                for gnd=1:length(frame_times)
                    [~,cur_vframe] = min(abs(v2frame_times-frame_times(gnd)));
                    tmp_vid_vel(gnd) = vid_vel(cur_vframe);
                end
                vid_vel = tmp_vid_vel;
            end
        end
        if load_ton
            [ltimes] = get_lick_times(lmeta_data,aux_data);
            [licktmp2] = lick_times_video(ldata);
            [licks] = map_lick_to_frame_times(licktmp2,frame_times,ltimes);
        end
        if determine_session
            session = parse_comment(all_proj_comments(find(all_proj_stackIDs(:,2)==cur_exps(tp_cnt))));
            if strcmp(projID,'M1')
                session = all_proj_comments(find(all_proj_stackIDs(:,2)==cur_exps(tp_cnt)));
            end
        end
        analysed_aux_data={};
        aux_cnt=1;
        
        if strcmp(projID,'LLI')
            [aux_data(pdef.aux_chans{strcmp(pdef.aux_chans(:,2),'vr_out'),1},:), aux_data(pdef.aux_chans{strcmp(pdef.aux_chans(:,2),'ps_id'),1},:)] = ...
                lli_edit_data(cur_exps(tp_cnt),aux_data(pdef.aux_chans{strcmp(pdef.aux_chans(:,2),'vr_out'),1},:),...
                aux_data(pdef.aux_chans{strcmp(pdef.aux_chans(:,2),'ps_id'),1},:));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% Parse aux data channels %%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if exist('aux_data','var')
            for wnd=1:size(pdef.aux_chans,1)
                if any(strcmp(pdef.aux_chans{wnd,2},{'screenPD','Screenphotodiode','ScreenphotoDiode','ScreenhotoDiode'}))
                    try
                        vis_speed=check_vis_speed(aux_data(pdef.aux_chans{wnd,1},:));
                    catch
                        vis_speed=zeros(1,length(aux_data));
                    end
                    analysed_aux_data{aux_cnt,1}='vis_speed';
                    analysed_aux_data{aux_cnt,2}=vis_speed;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'ps_id')
                    ps_id=aux_data(pdef.aux_chans{wnd,1},:);
                    
                    if max(mean(ps_id),1) > 1   % perturb signal are just trigger (shorter than a frame)
                        tmp =((ps_id > 3) + ((ps_id < 1) * -1));
                        ps_id = filter(ones(1,120),1,tmp);
                    end
                    analysed_aux_data{aux_cnt,1}='ps_id';
                    analysed_aux_data{aux_cnt,2}=ps_id;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'opto') && ismember(projID,{'VMM'})
                    opto=aux_data(pdef.aux_chans{wnd,1},:);
                    opto = filter(ones(1,200),1,opto);
                    analysed_aux_data{aux_cnt,1}='opto';
                    analysed_aux_data{aux_cnt,2}=opto;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'aud_trig')
                    aud_trig=aux_data(pdef.aux_chans{wnd,1},:);
                    if strcmp(projID,'ACX')
                        aud_trig=round(aud_trig);
                        ons=find(diff(aud_trig)>0)+1;
                        for pnd=1:length(ons)
                            aud_trig(ons(pnd):ons(pnd)+250)=5;
                        end
                        
                        %                     [aud_trig,~]=ACX_get_aud_trig_id(aud_trig,cur_exps(tp_cnt));
                    end
                    analysed_aux_data{aux_cnt,1}='aud_trig';
                    analysed_aux_data{aux_cnt,2}=aud_trig;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'VRrew')
                    % signal too short to be picked at each layer
                    VRrew = aux_data(pdef.aux_chans{find(strcmp('VRrew',pdef.aux_chans(:,2))),1},:);
                    
                    VRrew = filter(ones(1,120),1,VRrew > 1);
                    VRrew(VRrew > 1) = 5;
                    
                    analysed_aux_data{aux_cnt,1}='VRrew';
                    analysed_aux_data{aux_cnt,2}=VRrew;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'Lick')
                    %                 licktimes=getLickTimes(aux_data(pdef.aux_chans{wnd,1},:));
                    %                 analysed_aux_data{aux_cnt,1}='lickTimes';
                    %                 analysed_aux_data{aux_cnt,2}=licktimes;
                    %                 aux_cnt=aux_cnt+1;
                    licktimes=get_lick_times_thrsh(aux_data(pdef.aux_chans{wnd,1},:));
                    analysed_aux_data{aux_cnt,1}='lickTimes';
                    analysed_aux_data{aux_cnt,2}=licktimes;
                    aux_cnt=aux_cnt+1;
                    analysed_aux_data{aux_cnt,1}='LickTrace';
                    analysed_aux_data{aux_cnt,2}=aux_data(pdef.aux_chans{wnd,1},:);
                    aux_cnt=aux_cnt+1;
                elseif sum(strcmp(pdef.aux_chans{wnd,2},{'RewardTrig' 'AirPuffS' 'RewardTrigManual'}))
                    rewardTimes = getRewardTimes(aux_data(pdef.aux_chans{wnd,1},:));
                    rtvec = zeros(size(aux_data(1,:)));
                    % remove triggers in the last 200 ms
                    rewardTimes(rewardTimes>length(rtvec)-200)=[];
                    % expand all triggers to 200 ms
                    rtvec(bsxfun(@plus,rewardTimes,[0:199]'))=1;
                    %                 rtf = filter(ones(1,120),1,rtvec);
                    %                 rtf = rtf>0;
                    analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                    analysed_aux_data{aux_cnt,2}=rtvec;
                    aux_cnt=aux_cnt+1;
                elseif sum(strcmp(pdef.aux_chans{wnd,2},...
                        {'velM';'velP';'velR';'VRx';'VRy';'VRangle';'pb_X';'pb_Y';'pb_angle';'pb_velR';'pb_velM';'Running';'VisualFlow'}))
                    if sum(strcmp(pdef.aux_chans{wnd,2},{'VRangle';'pb_angle'}))
                        aux_data(pdef.aux_chans{wnd,1},:) = aux_data(pdef.aux_chans{wnd,1},:)-2.5;
                    end

                    if just_behave==0 && ...
                            sum(strcmp(pdef.aux_chans{wnd,2},{'VRx';'VRy';'VRangle';'pb_X';'pb_Y';'pb_angle'}))
                        tdata = diff(aux_data(pdef.aux_chans{wnd,1},:));
                        tdata(find(tdata<-2)) = 0;
                        tdata(find(tdata>2)) = 0;
                        vel=ftfil(tdata,1000,0,10);
                        vel_smoothed=smooth2(vel,1000);
                        analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                        analysed_aux_data{aux_cnt,2}=aux_data(pdef.aux_chans{wnd,1},:);
                        aux_cnt=aux_cnt+1;
                        analysed_aux_data{aux_cnt,1}=[pdef.aux_chans{wnd,2} '_vel'];
                        analysed_aux_data{aux_cnt,2}=vel;
                        aux_cnt=aux_cnt+1;
                        analysed_aux_data{aux_cnt,1}=[pdef.aux_chans{wnd,2} '_vel_smoothed'];
                        analysed_aux_data{aux_cnt,2}=vel_smoothed;
                        aux_cnt=aux_cnt+1;
                    elseif just_behave==1 && ...
                            sum(strcmp(pdef.aux_chans{wnd,2},{'VRx';'VRy';'VRangle';'pb_X';'pb_Y';'pb_angle'}))
                        tdata = diff(aux_data(pdef.aux_chans{wnd,1},:));
                        tdata(tdata<-2) = 0;
                        tdata(tdata>2) = 0;
                        vel=ftfil(tdata,1000,0,10);
                        vel_smoothed=smooth2(vel,1000);
                        analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                        analysed_aux_data{aux_cnt,2}=aux_data(pdef.aux_chans{wnd,1},:);
                        aux_cnt=aux_cnt+1;
                        analysed_aux_data{aux_cnt,1}=[pdef.aux_chans{wnd,2} '_vel'];
                        analysed_aux_data{aux_cnt,2}=[vel 0];
                        aux_cnt=aux_cnt+1;
                        analysed_aux_data{aux_cnt,1}=[pdef.aux_chans{wnd,2} '_vel_smoothed'];
                        analysed_aux_data{aux_cnt,2}=[vel_smoothed 0];
                    elseif just_behave==0
                        [vel,~,vel_smoothed,~]=get_vel_ind_from_adata(aux_data(pdef.aux_chans{wnd,1},:));
                        analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                        analysed_aux_data{aux_cnt,2}=vel;
                        aux_cnt=aux_cnt+1;
                        analysed_aux_data{aux_cnt,1}=[pdef.aux_chans{wnd,2} '_smoothed'];
                        analysed_aux_data{aux_cnt,2}=vel_smoothed;
                        aux_cnt=aux_cnt+1;
                    else
                        [vel,~,~,~]=get_vel_ind_from_adata(aux_data(pdef.aux_chans{wnd,1},:));
                        analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                        analysed_aux_data{aux_cnt,2}=[vel 0];
                        aux_cnt=aux_cnt+1;
                    end

                elseif strcmp(pdef.aux_chans{wnd,2},'aud_trig_upsample')
                    aud_trig=aux_data(pdef.aux_chans{wnd,1},:);
                    aud_trig=round(aud_trig);
                    aud_ids=find(diff(aud_trig)>0)+1;
                    for qnd=1:length(aud_ids)
                        for fnd=1:4
                            aud_trig(aud_ids(qnd)+(500*(fnd-1)):(aud_ids(qnd)+(500*(fnd-1)))+250)=1;
                        end
                    end
                    analysed_aux_data{aux_cnt,1}='aud_trig';
                    analysed_aux_data{aux_cnt,2}=aud_trig;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'VR_data')
                    vr_data=aux_data(pdef.aux_chans{wnd,1},:);
                    if strcmp(projID,'LFM')
                        shutter=aux_data(1,:);
                        vr_data=LFM_assign_sensory_id(vr_data,shutter,cur_exps(tp_cnt));
                    end
                    analysed_aux_data{aux_cnt,1}='vr_data';
                    analysed_aux_data{aux_cnt,2}=vr_data;
                    aux_cnt=aux_cnt+1;
                
                elseif strcmp(pdef.aux_chans{wnd,2},'AirPuff') && ismember(projID,{'HTM'})
                    airpuff_trig=aux_data(pdef.aux_chans{wnd,1},:);
                    airpuff_trig = airpuff_trig+[zeros(1,90) airpuff_trig(1:end-90)];
                    airpuff_trig(airpuff_trig > 4) = 5;
                    analysed_aux_data{aux_cnt,1}='AirPuff';
                    analysed_aux_data{aux_cnt,2}=airpuff_trig;
                    aux_cnt=aux_cnt+1;
                elseif strcmp(pdef.aux_chans{wnd,2},'AirPuff') && ismember(projID,{'AxA','NKO','PSI','PSN'})
                    airpuff_trig=aux_data(pdef.aux_chans{wnd,1},:);
                    airpuff_longer=zeros(size(airpuff_trig));
                    airpuff_trig = strfind(airpuff_trig>1,[0 1])+1;
                    airpuff_trig(airpuff_trig>length(airpuff_longer)-1000)=[];
                    for iPuff=airpuff_trig
                        airpuff_longer(iPuff:iPuff+1000)=1;
                    end
                    analysed_aux_data{aux_cnt,1}='AirPuff';
                    analysed_aux_data{aux_cnt,2}=airpuff_longer;
                    aux_cnt=aux_cnt+1;    
                    
                    
                else
                    
                    try
                        analysed_aux_data{aux_cnt,1}=pdef.aux_chans{wnd,2};
                        analysed_aux_data{aux_cnt,2}=aux_data(pdef.aux_chans{wnd,1},:);
                    catch
                        analysed_aux_data{aux_cnt,1}= 'missing';
                        analysed_aux_data{aux_cnt,2}= [];
                        display('Warning - this experiment does not contain the full number of aux channels defined in define_proj_channels');
                        display('Missing channels replaced with empty matrix')
                    end
                    
                    aux_cnt=aux_cnt+1;
                
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% Parse aux data channels END %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if just_behave==1
            mouse_id=animals{meta_cnt};
        end
        
        for zl_cnt=1:nbr_piezo_layers
            if tp_cnt==1
                proj_meta(meta_cnt).projID=projID;
                proj_meta(meta_cnt).Acode=num2str(Acode);
                proj_meta(meta_cnt).nbr_piezo_layers=nbr_piezo_layers;
                proj_meta(meta_cnt).animal=mouse_id;
                proj_meta(meta_cnt).animalID=find(ismember(animalIDs,mouse_id));
                proj_meta(meta_cnt).siteID=siteOrder(knd);
                proj_meta(meta_cnt).cortical_layer=locations{knd};
                proj_meta(meta_cnt).ExpGroup=cur_exps';
            end
            
            % add the meta info data
            if isfield(pdef,'meta_info_columns')
                if ~minfo_auto
                    for lnd=1:length(pdef.meta_info_columns)
                        mi_row=find(cell2mat(meta_info(2:end,1))==cur_exps(tp_cnt))+1;
                        mi_col=find(strcmp(meta_info(1,:),pdef.meta_info_columns(lnd)));
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' pdef.meta_info_columns{lnd} '=meta_info{mi_row,mi_col};']);
                    end
                else
                    %automatically include everything in meta info beyond 4th column if explicitly specified
                    for lnd=5:size(meta_info,2)
                        mi_row=find(cell2mat(meta_info(2:end,1))==cur_exps(tp_cnt))+1;
                        mi_col=find(strcmp(meta_info(1,:),meta_info{1,lnd}));
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' meta_info{1,lnd} '=meta_info{mi_row,mi_col};']);
                    end
                end
            else
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).timepoint=tp_cnt;
            end
            
            proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).piezo_layer=zl_cnt;
            if just_behave==0
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).fnames=orig.fnames;
                if iscell(orig.template)
                    if noROIs(zl_cnt)==0
                        [proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).act,proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).ROIinfo]=get_smoothed_ROIs(orig.ROIs{zl_cnt},par);
                    end
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).template=orig.template{zl_cnt};
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).act_map=orig.act_map{zl_cnt};
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).dx=orig.dx{zl_cnt};
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).dy=orig.dy{zl_cnt};
                    
                    ft_index=zl_cnt:nbr_piezo_layers:length(frame_times);
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).frame_times=frame_times(ft_index);
                else
                    if noROIs(zl_cnt)==0
                        [proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).act,proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).ROIinfo]=get_smoothed_ROIs(orig.ROIs,par);
                    end
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).template=orig.template;
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).act_map=orig.act_map;
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).dx=orig.dx;
                    proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).dy=orig.dy;
                    ft_index=1:length(frame_times);
                end
                if isfield(sec_channel,'template_sec') && ~isempty(sec_channel.template_sec)
                    if iscell(sec_channel.template_sec)
                        
                        proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).template_sec=sec_channel.template_sec{zl_cnt};
                        
                    else
                        
                        proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).template_sec=sec_channel.template_sec;
                        
                        
                    end
                end
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).nbr_frames=orig.nbr_frames/nbr_piezo_layers;
                for znd=1:size(analysed_aux_data,1)
                    if strcmp(analysed_aux_data{znd,1},'LickTrace') && licktraceraw
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' analysed_aux_data{znd,1} '=analysed_aux_data{' num2str(znd) ',2};']);
                    elseif strcmp(analysed_aux_data{znd,1},'lickTimes')
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' analysed_aux_data{znd,1} '=analysed_aux_data{' num2str(znd) ',2};']);
                    elseif ~isempty(analysed_aux_data{znd,2})
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' analysed_aux_data{znd,1} '=analysed_aux_data{' num2str(znd) ',2}(frame_times(ft_index));']);
                    else
                        eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' analysed_aux_data{znd,1} '=analysed_aux_data{' num2str(znd) ',2};']);
                    end
                end
            else
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).nbr_frames=nbr_frames;
                for znd=1:size(analysed_aux_data,1)
                    eval(['proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).' analysed_aux_data{znd,1} '=analysed_aux_data{' num2str(znd) ',2};']);
                end
            end
            
            if load_eye
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).pupil_diam=pupil_diam(ft_index);
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).pupil_pos=pupil_pos(:,ft_index);
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).blink=blink(ft_index);
            end
            if load_eyeR
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).pupil_diamR=pupil_diamR(ft_index);
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).pupil_posR=pupil_posR(:,ft_index);
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).blinkR=blinkR(ft_index);
            end
            if load_vid
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).vid_vel=vid_vel(ft_index);
            end
            if load_ton
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).lick = licks;
            end
            if determine_session
                proj_meta(meta_cnt).rd(zl_cnt,tp_cnt).session = session;
            end
        end
    end
    toc
    meta_cnt=meta_cnt+1;
end
display('************ saving proj_meta file to the Adata dir ************')

try
    save([meta_save_dir filename '.mat'],'proj_meta','-v7.3');
catch ME
    warning(ME.message)
    assignin('base',[filename],proj_meta);
    disp(['could not save proj_meta to disk, saved to workspace as:' filename]);
    s=input('press enter to try again','s');
    save([meta_save_dir filename '.mat'],'proj_meta','-v7.3');
end

display(['************ Done! ************'])


function session = parse_comment(comments)
session=[];
for ond = 1:length(comments)
    temp = regexp(lower(cell2mat(comments(ond))),'fb|pb|dark|ori|omission|flip','match');
    if isempty(temp)
        temp = 'undef ';
    end
    session = [session temp];
end
% kill last white space