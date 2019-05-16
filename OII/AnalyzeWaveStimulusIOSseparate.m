function AnalyzeWaveStimulusIOSseparate( varargin )
% function AnalyzeWaveStimulusIOSsimult( data1, data2, ...
%     SamplingFreq1, SamplingFreq2, StimulusFreq1, StimulusFreq2 )

    if nargin > 0
        BaseDir = varargin{1};
    else
        BaseDir = pwd;
    end

    %% Get experiment directory and load information
    [ExptDir] = uigetdir( BaseDir, 'Select experiment directory' );
    cd(ExptDir);
    disp(['Analyzing IOS-wave experiment: ' pwd]);
    
    
    %% Settings
    SpatialFilterSTD = 1.5;
    PowCuttOff = 0;
    PowMultiplier = 1;
    FrequencySelectRange = 7;
    AutoFindRemoveBadLines = false;
    DoHighPassFilter = true;
    NormalizePerFrame = true;

    
    %% Load data
    disp(' * Loading data');
    load('HorDown_Data.mat');
    data1 = double(BinnedData);
    SamplingFreq1 = SamplingFreq;
    StimulusFreq1 = StimulusFreq;

    load('VertLeft_Data.mat');
    data2 = double(BinnedData);
    SamplingFreq2 = SamplingFreq;
    StimulusFreq2 = StimulusFreq;
    
    load('HorUp_Data.mat');
    data3 = double(BinnedData);
    SamplingFreq3 = SamplingFreq;
    StimulusFreq3 = StimulusFreq;

    load('VertRight_Data.mat');
    data4 = double(BinnedData);
    SamplingFreq4 = SamplingFreq;
    StimulusFreq4 = StimulusFreq;


    %% Get data specs
    [yRes1,xRes1,tRes1] = size(data1);
    StimFreq1 = StimulusFreq1.Hor;
    [yRes2,xRes2,tRes2] = size(data2);
    StimFreq2 = StimulusFreq2.Ver;
    [yRes3,xRes3,tRes3] = size(data3);
    StimFreq3 = StimulusFreq3.Hor;
    [yRes4,xRes4,tRes4] = size(data4);
    StimFreq4 = StimulusFreq4.Ver;
    if sum(diff([xRes1 xRes2 xRes3 xRes4]))~=0 || sum(diff([yRes1 yRes2 yRes3 yRes4]))~=0
        error('XY-resolution of image-stacks is not equal');
    else
        xRes = xRes1;
        yRes = yRes1;
        disp([' * XY resolution: X=' num2str(xRes) ', Y=' num2str(yRes) ' pixels']);
    end
    

    %% Load the bloodvessel and bolus file (if present)
    disp(' * Loading bloodvessel and bolus image');
    BVfile = dir([ '.' filesep 'BloodvesselPattern*.tiff' ]);
    if ~isempty(BVfile)
        Ibv = imadjust(im2double(imread([ '.' filesep BVfile(1).name ])));
        Ivalues = sort(Ibv(:),'ascend');
        Ibv = Ibv - Ivalues(round(0.1*length(Ivalues)));
        Ivalues = sort(Ibv(:),'ascend');
        Ibv = Ibv / Ivalues(round(0.95*length(Ivalues)));
        Ibv(Ibv<0) = 0;
        Ibv(Ibv>1) = 1;
    else
        disp('   !! No bloodvessel image found...');
        Ibv = zeros([yRes xRes]);
    end
    BLfile = dir([ '.' filesep 'BolusLocation*.tiff' ]);
    if ~isempty(BLfile)
        Ibl = imadjust(im2double(imread([ '.' filesep BLfile(1).name ])));
        Ivalues = sort(Ibl(:),'ascend');
        Ibl = Ibl - Ivalues(round(0.1*length(Ivalues)));
        Ivalues = sort(Ibl(:),'ascend');
        Ibl = Ibl / Ivalues(round(0.95*length(Ivalues)));
        Ibl(Ibl<0) = 0;
        Ibl(Ibl>1) = 1;
    else
        disp('   !! No bolus image found...');
        Ibl = zeros([yRes xRes]);
    end
    
    
    %% Find and remove bad lines
    if AutoFindRemoveBadLines
        HorScan = squeeze(mean(mean(data1,3),1));
        BadLines = find(HorScan<(min(HorScan)*2));
        disp([' * Found and removed bad lines (data1): ' num2str(BadLines)]);
        data1( :, BadLines, : ) = [];
        
        HorScan = squeeze(mean(mean(data2,3),1));
        BadLines = find(HorScan<(min(HorScan)*2));
        disp([' * Found and removed bad lines (data2): ' num2str(BadLines)]);
        data2( :, BadLines, : ) = [];
        
        Ibv(:,BadLines) = [];
        Ibl(:,BadLines) = [];
    end
    

    %% Get index for stimulus frequency
    AllFrequencies1 = (SamplingFreq1/2) * linspace( 0, 1, tRes1/2 );
    FreqDiff = abs(AllFrequencies1-StimFreq1);
    FreqIndx1 = find(FreqDiff == min(FreqDiff));
    
    AllFrequencies2 = (SamplingFreq2/2) * linspace( 0, 1, tRes2/2 );
    FreqDiff = abs(AllFrequencies2-StimFreq2);
    FreqIndx2 = find(FreqDiff == min(FreqDiff));

    AllFrequencies3 = (SamplingFreq3/2) * linspace( 0, 1, tRes3/2 );
    FreqDiff = abs(AllFrequencies3-StimFreq3);
    FreqIndx3 = find(FreqDiff == min(FreqDiff));

    AllFrequencies4 = (SamplingFreq4/2) * linspace( 0, 1, tRes4/2 );
    FreqDiff = abs(AllFrequencies4-StimFreq4);
    FreqIndx4 = find(FreqDiff == min(FreqDiff));
    
    
    %% Display information
    disp(' * Horizontal direction 1');
    disp(['   - Number of frames: ' num2str(tRes1)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq1) ' Hz']);
    disp(['   -  Estimated horizontal stimulus frequency: ' num2str(StimFreq1) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies1(FreqIndx1)) ' Hz']);
    
    disp(' * Vertical direction 1');
    disp(['   - Number of frames: ' num2str(tRes2)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq2) ' Hz']);
    disp(['   - Estimated vertical stimulus frequency: ' num2str(StimFreq2) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies2(FreqIndx2)) ' Hz']);

    disp(' * Horizontal direction 2');
    disp(['   - Number of frames: ' num2str(tRes3)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq3) ' Hz']);
    disp(['* Sampling frequency: ' num2str(SamplingFreq3) ' Hz']);
    disp(['* Estimated horizontal stimulus frequency: ' num2str(StimFreq3) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies3(FreqIndx3)) ' Hz']);
    
    disp(' * Vertical direction 2');
    disp(['   - Number of frames: ' num2str(tRes4)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq4) ' Hz']);
    disp(['* Estimated vertical stimulus frequency: ' num2str(StimFreq4) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies4(FreqIndx4)) ' Hz']);

    
    %% Average filter dataset
    if SpatialFilterSTD > 0
        disp([' * Applying Gaussian image filter, kernel standard deviation: ' num2str(SpatialFilterSTD) ' pixels']);
        AvgFilter = fspecial('gaussian',31,SpatialFilterSTD);
        for t = 1:tRes1
            data1(:,:,t) = imfilter( data1(:,:,t), AvgFilter );
        end
        for t = 1:tRes2
            data2(:,:,t) = imfilter( data2(:,:,t), AvgFilter );
        end
        for t = 1:tRes3
            data3(:,:,t) = imfilter( data3(:,:,t), AvgFilter );
        end
        for t = 1:tRes4
            data4(:,:,t) = imfilter( data4(:,:,t), AvgFilter );
        end
    end
    
    
    %% Normalize per frame
    if NormalizePerFrame
        disp(' * Normalizing images for each timepoint');
        for t = 1:tRes1
            data1(:,:,t) = data1(:,:,t) - (sum(sum(data1(:,:,t),1),2)./(xRes*yRes));
        end
        for t = 1:tRes2
            data2(:,:,t) = data2(:,:,t) - (sum(sum(data2(:,:,t),1),2)./(xRes*yRes));
        end
        for t = 1:tRes3
            data3(:,:,t) = data3(:,:,t) - (sum(sum(data3(:,:,t),1),2)./(xRes*yRes));
        end
        for t = 1:tRes4
            data4(:,:,t) = data4(:,:,t) - (sum(sum(data4(:,:,t),1),2)./(xRes*yRes));
        end
    end
    
    
    
    
    %% Get Fourier spectrum
    if DoHighPassFilter
        disp([' * Highpass filtering (low-cut horizontal=' num2str(1/(4/StimFreq1)) ...
            ' Hz, vertical=' num2str(1/(4/StimFreq2)) 'Hz)']);
        disp( '   ... and calculating Fourier tranforms');
    else
        disp(' * Calculating Fourier tranforms');
    end   
    FourierSpectrHor1 = zeros(yRes,xRes,FrequencySelectRange);
    FourierSpectrVer1 = zeros(yRes,xRes,FrequencySelectRange);
    FourierSpectrHor2 = zeros(yRes,xRes,FrequencySelectRange);
    FourierSpectrVer2 = zeros(yRes,xRes,FrequencySelectRange);
    FreqRange = round((FrequencySelectRange-1)/-2):round((FrequencySelectRange-1)/2);
    w = waitbar(0,'Calculating Fourier transforms..');
    for y = 1:yRes
        waitbar(y/yRes);
        for x = 1:xRes
            T1 = squeeze(data1(y,x,:));
            T2 = squeeze(data2(y,x,:));
            T3 = squeeze(data3(y,x,:));
            T4 = squeeze(data4(y,x,:));
%             T1 = gpuArray(squeeze(data1(y,x,:)));
%             T2 = gpuArray(squeeze(data2(y,x,:)));
%             T3 = gpuArray(squeeze(data3(y,x,:)));
%             T4 = gpuArray(squeeze(data4(y,x,:)));
            if DoHighPassFilter
                T1 = LOCAL_MovingAverageHighPassFilter( T1, SamplingFreq1, 4/StimFreq1 );
                T2 = LOCAL_MovingAverageHighPassFilter( T2, SamplingFreq2, 4/StimFreq2 );
                T3 = LOCAL_MovingAverageHighPassFilter( T3, SamplingFreq3, 4/StimFreq3 );
                T4 = LOCAL_MovingAverageHighPassFilter( T4, SamplingFreq4, 4/StimFreq4 );
            end
            Fs1  = fft( T1 );
            Fs2  = fft( T2 );
            Fs3  = fft( T3 );
            Fs4  = fft( T4 );
            
            if FrequencySelectRange > 1
                for f = 1:FrequencySelectRange
                    FourierSpectrHor1(y,x,f) = Fs1(FreqIndx1+FreqRange(f));
                    FourierSpectrVer1(y,x,f) = Fs2(FreqIndx2+FreqRange(f));
                    FourierSpectrHor2(y,x,f) = Fs3(FreqIndx3+FreqRange(f));
                    FourierSpectrVer2(y,x,f) = Fs4(FreqIndx4+FreqRange(f));
%                     FourierSpectrHor1(y,x,f) = gather(Fs1(FreqIndx1+FreqRange(f)));
%                     FourierSpectrVer1(y,x,f) = gather(Fs2(FreqIndx2+FreqRange(f)));
%                     FourierSpectrHor2(y,x,f) = gather(Fs3(FreqIndx3+FreqRange(f)));
%                     FourierSpectrVer2(y,x,f) = gather(Fs4(FreqIndx4+FreqRange(f)));
                end
            else
                FourierSpectrHor1(y,x) = Fs1(FreqIndx1);
                FourierSpectrVer1(y,x) = Fs2(FreqIndx2);
                FourierSpectrHor2(y,x) = Fs3(FreqIndx3);
                FourierSpectrVer2(y,x) = Fs4(FreqIndx4);
%                 FourierSpectrHor1(y,x) = gather(Fs1(FreqIndx1));
%                 FourierSpectrVer1(y,x) = gather(Fs2(FreqIndx2));
%                 FourierSpectrHor2(y,x) = gather(Fs3(FreqIndx3));
%                 FourierSpectrVer2(y,x) = gather(Fs4(FreqIndx4));
            end
        end
    end
    close(w);
    
    
    %% Select correct stimuli
    if FrequencySelectRange > 1
        figure;
        for f = 1:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrHor1(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies1(FreqIndx1+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrHor1 = squeeze(FourierSpectrHor1(:,:,SelectedFreqIx));

        for f = 1:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrVer1(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies2(FreqIndx2+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrVer1 = squeeze(FourierSpectrVer1(:,:,SelectedFreqIx));

        for f = 1:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrHor2(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies3(FreqIndx3+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrHor2 = squeeze(FourierSpectrHor2(:,:,SelectedFreqIx));

        for f = 1:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrVer2(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies4(FreqIndx4+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrVer2 = squeeze(FourierSpectrVer2(:,:,SelectedFreqIx));
    end
    
    
    %% Calculate phase and power maps
    disp(' * Calculating maps');
    PhaseHor1 = mod( angle(FourierSpectrHor1)+pi, 2*pi ) -pi;
    PhaseVer1 = mod( angle(FourierSpectrVer1)+pi, 2*pi ) -pi;
    PhaseHor2 = mod( angle(FourierSpectrHor2)+pi, 2*pi ) -pi;
    PhaseVer2 = mod( angle(FourierSpectrVer2)+pi, 2*pi ) -pi;
    PhaseHor = mod( angle(FourierSpectrHor2./FourierSpectrHor1)+pi, 2*pi ) -pi;
    PhaseVer = mod( angle(FourierSpectrVer2./FourierSpectrVer1)+pi, 2*pi ) -pi;
    
    PowerHor1 = log(abs(FourierSpectrHor1));
    PowerVer1 = log(abs(FourierSpectrVer1));
    PowerHor2 = log(abs(FourierSpectrHor2));
    PowerVer2 = log(abs(FourierSpectrVer2));
    
    Power = PowerHor1+PowerHor2+PowerVer1+PowerVer2;
    disp([' * Removed ' num2str(sum(isnan(Power(:)))) ' NaNs from the overall powermap']);
    disp([' * Removed ' num2str(sum(isinf(Power(:)))) ' Infs from the overall powermap']);
    Power(isinf(Power)) = NaN;
    Power = ( ( (Power-nanmean(Power(:))) ./ nanstd(Power(:)) ) ./ 6 ) + 0.5;
    AvgFilter = fspecial('average',5);
    Power = imfilter( Power, AvgFilter );
    Power = (Power-PowCuttOff)*PowMultiplier;
    Power(Power<0) = 0; Power(Power>1) = 1;
    
    
    %% Create color coded phase maps
    C = ColorMap( max(361), 'hsv' );
    PhaseMapHor = zeros( yRes, xRes, 3 );
    PhaseMapVer = zeros( yRes, xRes, 3 );
    PhaseMapHor1 = zeros( yRes, xRes, 3 );
    PhaseMapHor2 = zeros( yRes, xRes, 3 );
    PhaseMapVer1 = zeros( yRes, xRes, 3 );
    PhaseMapVer2 = zeros( yRes, xRes, 3 );
    for y = 1:yRes
        for x = 1:xRes
            if ~isnan(PhaseHor1(y,x))
                PhaseMapHor1(y,x,:) = C{floor(181+((PhaseHor1(y,x)/pi)*180))};
            end
            if ~isnan(PhaseHor2(y,x))
                PhaseMapHor2(y,x,:) = C{floor(181+((PhaseHor2(y,x)/pi)*180))};
            end
            if ~isnan(PhaseVer1(y,x))
                PhaseMapVer1(y,x,:) = C{floor(181+((PhaseVer1(y,x)/pi)*180))};
            end
            if ~isnan(PhaseVer2(y,x))
                PhaseMapVer2(y,x,:) = C{floor(181+((PhaseVer2(y,x)/pi)*180))};
            end
            if ~isnan(PhaseHor(y,x))
                PhaseMapHor(y,x,:) = C{floor(181+((PhaseHor(y,x)/pi)*180))};
            end
            if ~isnan(PhaseVer(y,x))
                PhaseMapVer(y,x,:) = C{floor(181+((PhaseVer(y,x)/pi)*180))};
            end
        end
    end
    ScaledPhaseMapHor = ( (PhaseMapHor-0.7) .* repmat(Power,[1 1 3]))+0.7;
    ScaledPhaseMapVer = ( (PhaseMapVer-0.7) .* repmat(Power,[1 1 3]))+0.7;   
    ScaledPhaseMapHorBlack = ( PhaseMapHor .* repmat(Power,[1 1 3]));
    ScaledPhaseMapVerBlack = ( PhaseMapVer .* repmat(Power,[1 1 3]));   

    PhaseMapHor1 = ( (PhaseMapHor1-0.7) .* repmat(Power,[1 1 3]))+0.7;
    PhaseMapHor2 = ( (PhaseMapHor2-0.7) .* repmat(Power,[1 1 3]))+0.7;
    PhaseMapVer1 = ( (PhaseMapVer1-0.7) .* repmat(Power,[1 1 3]))+0.7;
    PhaseMapVer2 = ( (PhaseMapVer2-0.7) .* repmat(Power,[1 1 3]))+0.7;
    
    %% Calculate iso-azimuth lines
    HorRetinotopy = ScaledPhaseMapHorBlack;
    VerRetinotopy = ScaledPhaseMapVerBlack;
    HorRetinotopy( repmat(max(HorRetinotopy,[],3),[1 1 3]) < 0.2 ) = 0;
    VerRetinotopy( repmat(max(VerRetinotopy,[],3),[1 1 3]) < 0.2 ) = 0;
    HorRetinotopy( repmat( mod(round(PhaseHor*10),round((pi/4)*10)) ~= 0, [1 1 3] ) ) = 0;
    VerRetinotopy( repmat( mod(round(PhaseVer*10),round((pi/4)*10)) ~= 0, [1 1 3] ) ) = 0;
    RetIx = repmat( sum(HorRetinotopy,3)>0, [1 1 3] );
    HorVerRetinotopy = VerRetinotopy;
    HorVerRetinotopy(RetIx) = HorRetinotopy(RetIx);
    

    %% Load the bloodvessel and bolus file (if present)
    BVfile = dir([ '.' filesep 'BloodvesselPattern*.tiff' ]);
    if ~isempty(BVfile)
        Ibv = imadjust(im2double(imread([ '.' filesep BVfile(1).name ])));
%         Ibv = flipdim(Ibv,1);
        Ivalues = sort(Ibv(:),'ascend');
        Ibv = Ibv - Ivalues(round(0.1*length(Ivalues)));
        Ivalues = sort(Ibv(:),'ascend');
        Ibv = Ibv / Ivalues(round(0.95*length(Ivalues)));
        Ibv(Ibv<0) = 0;
        Ibv(Ibv>1) = 1;
    else
        Ibv = zeros([yRes xRes]);
    end
    BLfile = dir([ '.' filesep 'BolusLocation*.tiff' ]);
    if ~isempty(BLfile)
        Ibl = imadjust(im2double(imread([ '.' filesep BLfile(1).name ])));
%         Ibl = flipdim(Ibl,1);
        Ivalues = sort(Ibl(:),'ascend');
        Ibl = Ibl - Ivalues(round(0.1*length(Ivalues)));
        Ivalues = sort(Ibl(:),'ascend');
        Ibl = Ibl / Ivalues(round(0.95*length(Ivalues)));
        Ibl(Ibl<0) = 0;
        Ibl(Ibl>1) = 1;
    else
        Ibl = zeros([yRes xRes]);
    end

    
    %% Overlay iso-azimuth lines with bloodvessel and bolus images
    HorRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
    RetIx = repmat( sum(HorRetinotopy,3)>0, [1 1 3] );
    HorRetinotopyBVoverlay(RetIx) = HorRetinotopy(RetIx);

    VerRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
    RetIx = repmat( sum(VerRetinotopy,3)>0, [1 1 3] );
    VerRetinotopyBVoverlay(RetIx) = VerRetinotopy(RetIx);

    HorVerRetinotopyBVoverlay = repmat(Ibv,[1 1 3]);
    RetIx = repmat( sum(HorVerRetinotopy,3)>0, [1 1 3] );
    HorVerRetinotopyBVoverlay(RetIx) = HorVerRetinotopy(RetIx);
    
    HorRetinotopyBLoverlay = repmat(Ibl,[1 1 3]);
    RetIx = repmat( sum(HorRetinotopy,3)>0, [1 1 3] );
    HorRetinotopyBLoverlay(RetIx) = HorRetinotopy(RetIx);
    
    VerRetinotopyBLoverlay = repmat(Ibl,[1 1 3]);
    RetIx = repmat( sum(VerRetinotopy,3)>0, [1 1 3] );
    VerRetinotopyBLoverlay(RetIx) = VerRetinotopy(RetIx);

    HorVerRetinotopyBLoverlay = repmat(Ibl,[1 1 3]);
    RetIx = repmat( sum(HorVerRetinotopy,3)>0, [1 1 3] );
    HorVerRetinotopyBLoverlay(RetIx) = HorVerRetinotopy(RetIx);
    
    
    save('Wave_maps.mat','PhaseMapHor1','PhaseMapHor2','PhaseMapVer1','PhaseMapVer2','PhaseMapHor','PhaseMapVer',...
        'ScaledPhaseMapHor', 'ScaledPhaseMapVer', 'ScaledPhaseMapHorBlack', 'ScaledPhaseMapVerBlack',...
        'HorRetinotopy', 'VerRetinotopy', 'HorVerRetinotopy',...
        'HorRetinotopyBVoverlay', 'VerRetinotopyBVoverlay', 'HorVerRetinotopyBVoverlay',...
        'HorRetinotopyBLoverlay', 'VerRetinotopyBLoverlay', 'HorVerRetinotopyBLoverlay');
    disp(' * Saved maps!');
    
    
    %% Display maps
    figure;
    
    subplot(3,2,1);
    imshow(PhaseMapHor1);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapHor1,'PhaseMapHor1.tiff');

    subplot(3,2,2);
    imshow(PhaseMapHor2);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapHor2,'PhaseMapHor2.tiff');
    
    subplot(3,2,3);
    imshow(PhaseMapVer1);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer1,'PhaseMapVer1.tiff');

    subplot(3,2,4);
    imshow(PhaseMapVer2);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer2,'PhaseMapVer2.tiff');
        
    subplot(3,2,5);
    imshow(PhaseMapHor);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapHor,'PhaseMapHor.tiff');

    subplot(3,2,6);
    imshow(PhaseMapVer);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer,'PhaseMapVer.tiff');
        

    figure;    
    subplot(2,2,1);
    imshow(ScaledPhaseMapHor);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapHor,'ScaledPhaseMapHor.tiff');

    subplot(2,2,2);
    imshow(ScaledPhaseMapVer);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapVer,'ScaledPhaseMapVer.tiff');

    subplot(2,2,3);
    imshow(ScaledPhaseMapHorBlack);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapHorBlack,'ScaledPhaseMapHorBlack.tiff');

    subplot(2,2,4);
    imshow(ScaledPhaseMapVerBlack);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapVerBlack,'ScaledPhaseMapVerBlack.tiff');

    
    figure;    
    subplot(1,3,1);
    imshow(HorRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopy,'HorRetinotopy.tiff');

    subplot(1,3,2);
    imshow(VerRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopy,'VerRetinotopy.tiff');

    subplot(1,3,3);
    imshow(HorVerRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopy,'HorVerRetinotopy.tiff');

    
    figure;    
    subplot(1,3,1);
    imshow(HorRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopyBVoverlay,'HorRetinotopyBVoverlay.tiff');

    subplot(1,3,2);
    imshow(VerRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopyBVoverlay,'VerRetinotopyBVoverlay.tiff');

    subplot(1,3,3);
    imshow(HorVerRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopyBVoverlay,'HorVerRetinotopyBVoverlay.tiff');
    

    figure;
    subplot(1,3,1);
    imshow(HorRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopyBLoverlay,'HorRetinotopyBLoverlay.tiff');

    subplot(1,3,2);
    imshow(VerRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopyBLoverlay,'VerRetinotopyBLoverlay.tiff');

    subplot(1,3,3);
    imshow(HorVerRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopyBLoverlay,'HorVerRetinotopyBLoverlay.tiff');

    disp(' * Done!!');
end

function [YF, Y0] = LOCAL_MovingAverageHighPassFilter( Y, SamplingFreq, BaselineWindowSize )
    % Baseline the data using sliding window approach

    % Calculate moving average baseline
    Y0 = smooth(Y,SamplingFreq*BaselineWindowSize);
    YF = Y - Y0;
    
end

