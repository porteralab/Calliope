function [result,dat,fr] = analyzeOII_Fourier(ExpID,ExpIDBV,hfreq,vfreq,varargin)
%analyzeOII Fourier Analysis of intrinsic optical Imaging Data
%   ExpID: Experiment ID of the OII stack (red LED)
%   ExpIDBV: Experiment ID of the bloodvessel stack (green LED). Leave empty if you don't have one
%   hfreq: stimulation frequency of the horizontal bar moving up and down.
%   vfreq: stimulation frequency of the vertical bar moving left and right.
%   These two values can be obtained from the stimulus ini file. Will be
%   computed from aux_file in a later version
%   usage:
%       analyzeOII_Fourier(25922,25920,0.125,0.036)
%
%   optional parameters:
%     'SpatialFilterSTD' - spatial gaussian filter, kernel std in pixels
%     'SpatialFilterWindow' - default: 15
%     'Normalize' - Normalization ('Mean' (default), 'Median', 'GlobalSmooth')
%     'FrequencySelectRange' - frequency range for fourier transform (for debugging)
%     'RescueStimBounds' - get stimID from stimPOS channel, in case stimID was not recorded
%     'StimChannels' - specify both stim channels default: [3 2]

p = inputParser; % parse varargin
addParameter(p,'SpatialFilterSTD',0,@isnumeric)
addParameter(p,'SpatialFilterWindow',15,@isnumeric)
addParameter(p,'Normalize','Mean' ,@ischar) % 'Mean', 'GlobalSmooth'
addParameter(p,'FrequencySelectRange',0,@isnumeric);
addParameter(p,'RescueStimBounds',0,@isnumeric);
addParameter(p,'StimChannels',[3 2],@isnumeric); %[stimID stimPOS]
addParameter(p,'savemaps',0,@isnumeric);
addParameter(p,'ach',0,@isnumeric); %get channels directly from resp. ach file
addParameter(p,'tmpSave',0,@isnumeric);
addParameter(p,'vdata',[],@isnumeric);
addParameter(p,'vmeta_info',[],@isnumeric);

parse(p,varargin{:})
settings = p.Results;

shutter=1;
if settings.ach~=1 % default
    stimPOS=settings.StimChannels(2);
    stimID=settings.StimChannels(1);
    %try to check mismatch (*.ach and standard-option) => output warning
    try
        channels=parse_ach([],ExpID);
        stimPOS_assert=find(strcmp(channels.aux_chans(:,2),{'Stim'}));
        stimID_assert=find(~cellfun('isempty',regexpi(channels.aux_chans(:,2),'ID')));
        if ~isequal(stimPOS, stimPOS_assert) || ~isequal(stimID,stimID_assert)
            warning('stimID or stimPOS channels mismatch: ach file seems to indicate other channels than default in this script. Maybe try to run the script with (''ach'',1) parameters?')
        end
    catch
    end
else
    fprintf('getting channels directly from .ach file...\n');
    channels=parse_ach([],ExpID);
    stimPOS=find(strcmp(channels.aux_chans(:,2),{'Stim'}));
    stimID=find(~cellfun('isempty',regexpi(channels.aux_chans(:,2),'ID')));
end

if isempty(ExpIDBV)
    [dp,info]=get_data_path(ExpID);
else
    [dp,info]=get_data_path(ExpIDBV);
end

if ~isempty(settings.vmeta_info), fr=settings.vmeta_info; end
if ~isempty(settings.vdata), dat=settings.vdata; end

path = [dp info.userID '\' info.mouse_id '\'];
adata_dir=set_lab_paths;

outputpath = [adata_dir info.userID '\' info.mouse_id '\'];

%% Settings
%   AutoFindRemoveBadLines = false;
%   DoHighPassFilter = false;


%% Load data
% vid is the old extension. format is the same.
% this takes a longer time => display

if ~exist('dat','var') || ~exist('fr','var')
    fprintf('loading S1-T%d.oii and S1-T%d.vid, this will take a while...',ExpID,ExpID)
    try
        [dat,fr] = load_vid_data([path 'S1-T' num2str(ExpID) '.oii']);
    catch
        [dat,fr] = load_vid_data([path 'S1-T' num2str(ExpID) '.vid']);
    end
    
    if settings.tmpSave  %if outputs are not used, temporarily store current videofiles in workspace for later use
        fprintf('\nsaving data in workspace for later use (vmeta_info, vdata variables)...\n')
        assignin('base','vmeta_info',fr);
        assignin('base','vdata',dat);
    end
else
    fprintf('using provided video data...\n');
end
fprintf('done.\n');

%% load settings data
aux_data = load_lvd([path 'S1-T' num2str(ExpID) '.lvd']);

if ismember(ExpID,[37397 37395 37357 37359 37361 37362 37363 37365 37366])
    tmp=aux_data(stimID,:);
    aux_data(stimID,:)=aux_data(stimPOS,:);
    aux_data(stimPOS,:)=tmp;
end

temp = strfind(aux_data(shutter,:)>0.5,[0 1]);
temp2 = strfind(aux_data(shutter,:)>0.5,[1 0]);
if isempty(temp2)
    temp2 = size(aux_data,2);
end
aux_data = aux_data(:,temp:temp2);
stim_bound = [];
if settings.RescueStimBounds == 0
    stim_bound = [find(abs(diff(aux_data(stimID,:)))>0.5) size(aux_data,2)];
    
    % remove accidental stim boundaries found because of double step
    stim_bound(find(diff(stim_bound)==1)+1)=[];
else
    a = aux_data(3,:)<min(aux_data(3,:))*1.2;
    b = 1-a;
    temppos = strfind([0 a 0],[0 1]);
    lones = strfind([0 a 0],[1 0]) - temppos;
    
    tempidx = find(lones > 200);
    
    for jnd = 2:length(tempidx)-1
        stim_bound = [stim_bound temppos(tempidx(jnd)) temppos(tempidx(jnd))+lones(tempidx(jnd))];
    end
    stim_bound = [lones(1) stim_bound temppos(end)];
end

fr(1,1) = 1;
counter =1;
stimfreqs = zeros(1,4);
for ind = 1:2:7
    idxRange(counter).start = find(fr(1,:)>=stim_bound(ind),1,'first');
    idxRange(counter).stop = find(fr(1,:)<=stim_bound(ind+1),1,'last');
    
    da = diff(aux_data(stimPOS,stim_bound(ind):stim_bound(ind+1)));
    peaks = find(abs(da)>2);
    stimfreqs(counter) =  1/(.001*mean(diff(peaks)));
    counter=counter+1;
end

% for ind=1:4
%     idxRange(ind).stop = idxRange(ind).start + floor(.50*(idxRange(ind).stop-idxRange(ind).start));
% end

StimulusFreqs=[hfreq,hfreq,vfreq,vfreq];

if nnz(abs(stimfreqs-StimulusFreqs)>0.005)
    warning('Calculated Stimulus Frequency and Entered Stimulus Frequency Diverge (Small Deviations can be due to sampling issues)');
    stimfreqs
    StimulusFreqs
    s = input('Do you want to continue anyways (y/n) (n goes to breakpoint)?','s');
    if ~strcmp(s,'y')
        dbstop;
    end
end
%% filtering
%% Average filter dataset
%     dat = imresize(dat,.5);
meandat = impyramid(mean(dat,3),'reduce');
meandat_mask = meandat < 4094;  % assume 12bit data
if settings.SpatialFilterSTD > 0
    disp([' * Applying Gaussian image filter, kernel standard deviation: ' num2str(settings.SpatialFilterSTD) ' pixels']);
    AvgFilter = fspecial('gaussian',settings.SpatialFilterWindow,settings.SpatialFilterSTD);
    dat = imfilter(dat,AvgFilter);
end

dat = impyramid(dat,'reduce');

%% settings
dat = single(dat);
fig = figure(1110);
fig.Name = 'Image Brightness';
intProfile = squeeze(mean(mean(dat,1),2));
plot(intProfile,'b','DisplayName','raw');

SamplingFreq=1/mean(diff(fr(1,:)))*1000;


%% Get data specs
dataSpecs = struct();
for ii = 1:4
    [dataSpecs(ii).yRes,dataSpecs(ii).xRes,dataSpecs(ii).tRes]=size(dat(:,:,idxRange(ii).start:idxRange(ii).stop));
end
if sum(diff(cat(2,dataSpecs(:).xRes)))~=0 || sum(diff(cat(2,dataSpecs(:).yRes)))~=0
    error('XY-resolution of image-stacks is not equal');
else
    xRes = dataSpecs(1).xRes;
    yRes = dataSpecs(1).yRes;
    disp([' * XY resolution: X=' num2str(xRes) ', Y=' num2str(yRes) ' pixels']);
end


%% Get index for stimulus frequency
AllFrequencies = {};
FreqIdx = zeros(1,4);
for ii = 1:4
    AllFrequencies{ii} = (SamplingFreq/2) * linspace( 0, 1, dataSpecs(ii).tRes/2 );
    FreqDiff = abs(AllFrequencies{ii}-StimulusFreqs(ii));
    [~,FreqIdx(ii)] = min(FreqDiff);
end

%% Display information
for ii = 1:4
    disp([' * Direction ' num2str(ii)]);
    disp(['   - Number of frames: ' num2str(dataSpecs(ii).tRes)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['   -  Estimated stimulus frequency: ' num2str(StimulusFreqs(ii)) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies{ii}(FreqIdx(ii))) ' Hz']);
end


%% Normalize
switch settings.Normalize
    case 'Mean'
        disp(' * Normalizing images by their mean');
        dat = bsxfun(@rdivide,dat,mean(mean(dat)));
    case 'Median'
        % mean substraction per frame
        disp(' * Normalizing images by their median');
        dat = bsxfun(@rdivide,dat,median(median(dat)));
    case 'GlobalSmooth'
        intSmoothed = reshape(smooth2(intProfile,300),1,1,size(dat,3));
        dat = bsxfun(@rdivide,dat,intSmoothed);
    case 'None'
        % no normalization
end


%% Get Fourier spectrum
FourierSpecs = {};
idx =[-settings.FrequencySelectRange:settings.FrequencySelectRange];
disp(' * Calculating Fourier Transforms * ');
for ii = 1:4
    tmp = fft(dat(:,:,idxRange(ii).start:idxRange(ii).stop),[],3);
    FourierSpecs{ii}=squeeze(tmp(:,:,FreqIdx(ii)+idx));
end

if ~isempty(ExpIDBV)
    bgpath = [path 'S1-T' num2str(ExpIDBV) '.vid'];
    f = dir(bgpath);
    if ~isempty(f)
        [bgdat,~] = load_vid_data(bgpath);
    elseif ~isempty(dir([path 'S1-T' num2str(ExpIDBV) '.oii']))
        [bgdat,~] = load_vid_data([path 'S1-T' num2str(ExpIDBV) '.oii']);
    end
    Ibv = mean(bgdat,3);
    Ibv = mat2gray(Ibv);
    Ibv = impyramid(Ibv,'reduce');
    Ibv = fliplr(Ibv);
    figure
    imshow(Ibv,[])
else
    warning ('no bg file found, using mean image instead')
    Ibv = fliplr(meandat);
end

result.Ibv = Ibv;
result.FourierSpecs = FourierSpecs;
selected = false;
for jj = 1:length(idx)
    [result.Power,result.Phase,result.PhaseMap,result.PhaseMapHor,result.PhaseMapVer,result.PhaseHor,result.PhaseVer] = ...
        showFourierMaps(FourierSpecs,jj,Ibv,meandat_mask);
    if settings.FrequencySelectRange > 0
        s=input('Use this map? (y/n)','s');
        if strcmp(s,'y')
            selected = true;
            break
        end
    end
end



%% Calculate iso-azimuth lines
%     HorRetinotopy = ScaledPhaseMapHorBlack;
%     VerRetinotopy = ScaledPhaseMapVerBlack;
%     HorRetinotopy( repmat(max(HorRetinotopy,[],3),[1 1 3]) < 0.2 ) = 0;
%     VerRetinotopy( repmat(max(VerRetinotopy,[],3),[1 1 3]) < 0.2 ) = 0;
%     HorRetinotopy( repmat( mod(round(PhaseHor*10),round((pi/4)*10)) ~= 0, [1 1 3] ) ) = 0;
%     VerRetinotopy( repmat( mod(round(PhaseVer*10),round((pi/4)*10)) ~= 0, [1 1 3] ) ) = 0;
%     RetIx = repmat( sum(HorRetinotopy,3)>0, [1 1 3] );
%     HorVerRetinotopy = VerRetinotopy;
%     HorVerRetinotopy(RetIx) = HorRetinotopy(RetIx);




%% Overlay iso-azimuth lines with bloodvessel and bolus images
%     HorRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
%     RetIx = repmat( sum(HorRetinotopy,3)>0, [1 1 3] );
%     HorRetinotopyBVoverlay(RetIx) = HorRetinotopy(RetIx);
%
%     VerRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
%     RetIx = repmat( sum(VerRetinotopy,3)>0, [1 1 3] );
%     VerRetinotopyBVoverlay(RetIx) = VerRetinotopy(RetIx);
%
%     HorVerRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
%     RetIx = repmat( sum(HorVerRetinotopy,3)>0, [1 1 3] );
%     HorVerRetinotopyBVoverlay(RetIx) = HorVerRetinotopy(RetIx);


% mkdir
if settings.savemaps
    mkdir(outputpath);
    cd([outputpath]);
    % saving
    save(['Adata-S1-T' num2str(ExpID) '.mat'],'result')%,...
    % 'ScaledPhaseMapHor', 'ScaledPhaseMapVer', 'ScaledPhaseMapHorBlack', 'ScaledPhaseMapVerBlack',...
    % 'HorRetinotopy', 'VerRetinotopy', 'HorVerRetinotopy',...
    % 'HorRetinotopyBVoverlay', 'VerRetinotopyBVoverlay', 'HorVerRetinotopyBVoverlay', ...
    %  'Ibv');
    disp(' * Saved maps!');
end
end

