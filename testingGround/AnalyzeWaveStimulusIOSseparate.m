
    %% Get experiment directory and load information
%     [ExptDir] = uigetdir( BaseDir, 'Select experiment directory' );
%     cd(ExptDir);
%     disp(['Analyzing IOS-wave experiment: ' pwd]);
%     
    
    %% Settings
    SpatialFilterSTD = 1.5;
    PowCuttOff = 0;
    PowMultiplier = 1;
    FrequencySelectRange = 2;
    AutoFindRemoveBadLines = false;
    DoHighPassFilter = false;
    NormalizePerFrame = true;

    
    %% Load data
    lengthAUX = length(auxdata)-(743+422);
    nFrames = size(dat,3);

    %% filtering
     %% Average filter dataset
    if SpatialFilterSTD > 0
        disp([' * Applying Gaussian image filter, kernel standard deviation: ' num2str(SpatialFilterSTD) ' pixels']);
        AvgFilter = fspecial('gaussian',31,SpatialFilterSTD);
        dat = imfilter(dat,AvgFilter);
    end
    
    
    
    %% settings
    [idxRange] = round(([start_1.Position(1) stop_1.Position(1)]-743)/lengthAUX*nFrames);
    SamplingFreq=1/mean(diff(fr(1,:)))*1000;
   
    dat = single(dat);
    data1 = dat(:,:,idxRange(1):idxRange(2));
   

   
    [idxRange] = round(([start_2.Position(1) stop_2.Position(1)]-743)/lengthAUX*nFrames);
    data2 = dat(:,:,idxRange(1):idxRange(2));
    
    
    [idxRange] = round(([start_3.Position(1) stop_3.Position(1)]-743)/lengthAUX*nFrames);
    data3 = dat(:,:,idxRange(1):idxRange(2));
    

    [idxRange] = round(([start_4.Position(1) stop_4.Position(1)]-743)/lengthAUX*nFrames);
    data4 = dat(:,:,idxRange(1):idxRange(2));
   

    StimulusFreq1 = 0.25;
    StimulusFreq2 = 0.25;
    StimulusFreq3 = 0.083;
    StimulusFreq4 = 0.083;

    %% Get data specs
    [yRes1,xRes1,tRes1] = size(data1);
    %StimFreq1 = grat_indFreq1.Hor;
    StimFreq1 = StimulusFreq1;
    [yRes2,xRes2,tRes2] = size(data2);
    %StimFreq2 = StimulusFreq2.Ver;
    StimFreq2 = StimulusFreq2;
    [yRes3,xRes3,tRes3] = size(data3);
    %StimFreq3 = StimulusFreq3.Hor;
    StimFreq3 = StimulusFreq3;
    [yRes4,xRes4,tRes4] = size(data4);
    %StimFreq4 = StimulusFreq4.Ver;
    StimFreq4 = StimulusFreq4;
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
    AllFrequencies1 = (SamplingFreq/2) * linspace( 0, 1, tRes1/2 );
    FreqDiff = abs(AllFrequencies1-StimFreq1);
    FreqIndx1 = find(FreqDiff == min(FreqDiff));
    
    AllFrequencies2 = (SamplingFreq/2) * linspace( 0, 1, tRes2/2 );
    FreqDiff = abs(AllFrequencies2-StimFreq2);
    FreqIndx2 = find(FreqDiff == min(FreqDiff));

    AllFrequencies3 = (SamplingFreq/2) * linspace( 0, 1, tRes3/2 );
    FreqDiff = abs(AllFrequencies3-StimFreq3);
    FreqIndx3 = find(FreqDiff == min(FreqDiff));

    AllFrequencies4 = (SamplingFreq/2) * linspace( 0, 1, tRes4/2 );
    FreqDiff = abs(AllFrequencies4-StimFreq4);
    FreqIndx4 = find(FreqDiff == min(FreqDiff));
    
    
    %% Display information
    disp(' * Horizontal direction 1');
    disp(['   - Number of frames: ' num2str(tRes1)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['   -  Estimated horizontal stimulus frequency: ' num2str(StimFreq1) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies1(FreqIndx1)) ' Hz']);
    
    disp(' * Vertical direction 1');
    disp(['   - Number of frames: ' num2str(tRes2)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['   - Estimated vertical stimulus frequency: ' num2str(StimFreq2) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies2(FreqIndx2)) ' Hz']);

    disp(' * Horizontal direction 2');
    disp(['   - Number of frames: ' num2str(tRes3)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['* Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['* Estimated horizontal stimulus frequency: ' num2str(StimFreq3) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies3(FreqIndx3)) ' Hz']);
    
    disp(' * Vertical direction 2');
    disp(['   - Number of frames: ' num2str(tRes4)]);
    disp(['   - Sampling frequency: ' num2str(SamplingFreq) ' Hz']);
    disp(['* Estimated vertical stimulus frequency: ' num2str(StimFreq4) ...
        ' Hz, nearest in Fourier spectrum: ' num2str(AllFrequencies4(FreqIndx4)) ' Hz']);

    
   
    
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
    
    
   
          
            DATA1  = fft(data1,[],3);
            clear data1
            DATA2  = fft(data2,[],3);
            clear data2
            DATA3  = fft(data3,[],3);
            clear data3
            DATA4  = fft(data4,[],3);
            clear data4
            FreqRange =[-FrequencySelectRange:FrequencySelectRange];
                FourierSpectrHor1= DATA1(:,:,FreqIndx1);
                FourierSpectrVer1 = DATA3(:,:,FreqIndx3);
                FourierSpectrHor2 = DATA2(:,:,FreqIndx2);
                FourierSpectrVer2 = DATA4(:,:,FreqIndx4);
                
%                  FourierSpectrHor1= DATA1(:,:,FreqIndx1);
%                 FourierSpectrVer1 = DATA2(:,:,FreqIndx2);
%                 FourierSpectrHor2 = DATA3(:,:,FreqIndx3);
%                 FourierSpectrVer2 = DATA4(:,:,FreqIndx4);
    
    
    %% Select correct stimuli
    if FrequencySelectRange > 100
        figure;
        for f = -FrequencySelectRange:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrHor1(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies1(FreqIndx1+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrHor1 = squeeze(FourierSpectrHor1(:,:,SelectedFreqIx));

        for f = -FrequencySelectRange:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrVer1(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies2(FreqIndx2+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrVer1 = squeeze(FourierSpectrVer1(:,:,SelectedFreqIx));

        for f = -FrequencySelectRange:FrequencySelectRange
            subplot(1,FrequencySelectRange,f);
            imagesc(mod( angle(squeeze(FourierSpectrHor2(:,:,f)))+pi, 2*pi ) -pi, [-pi pi] );
            colormap('hsv');
            title([ 'Freq = ' num2str(f) ' (' num2str(AllFrequencies3(FreqIndx3+FreqRange(f))) ' Hz)' ]);
            axis off; axis equal; axis tight;
        end
        SelectedFreqIx = input(['Select stimulus frequency (1 to ' num2str(FrequencySelectRange) '): ']);
        FourierSpectrHor2 = squeeze(FourierSpectrHor2(:,:,SelectedFreqIx));

        for f = -FrequencySelectRange:FrequencySelectRange
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
    C = colormap( hsv(361));
    PhaseMapHor = zeros( yRes, xRes, 3 );
    PhaseMapVer = zeros( yRes, xRes, 3 );
    PhaseMapHor1 = zeros( yRes, xRes, 3 );
    PhaseMapHor2 = zeros( yRes, xRes, 3 );
    PhaseMapVer1 = zeros( yRes, xRes, 3 );
    PhaseMapVer2 = zeros( yRes, xRes, 3 );
    for y = 1:yRes
        for x = 1:xRes
            if ~isnan(PhaseHor1(y,x))
                PhaseMapHor1(y,x,:) = C(floor(181+((PhaseHor1(y,x)/pi)*180)),:);
            end
            if ~isnan(PhaseHor2(y,x))
                PhaseMapHor2(y,x,:) = C(floor(181+((PhaseHor2(y,x)/pi)*180)),:);
            end
            if ~isnan(PhaseVer1(y,x))
                PhaseMapVer1(y,x,:) = C(floor(181+((PhaseVer1(y,x)/pi)*180)),:);
            end
            if ~isnan(PhaseVer2(y,x))
                PhaseMapVer2(y,x,:) = C(floor(181+((PhaseVer2(y,x)/pi)*180)),:);
            end
            if ~isnan(PhaseHor(y,x))
                PhaseMapHor(y,x,:) = C(floor(181+((PhaseHor(y,x)/pi)*180)),:);
            end
            if ~isnan(PhaseVer(y,x))
                PhaseMapVer(y,x,:) = C(floor(181+((PhaseVer(y,x)/pi)*180)),:);
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
    imwrite(PhaseMapHor1,'PhaseMapHor1.jpg');

    subplot(3,2,2);
    imshow(PhaseMapHor2);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapHor2,'PhaseMapHor2.jpg');
    
    subplot(3,2,3);
    imshow(PhaseMapVer1);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer1,'PhaseMapVer1.jpg');

    subplot(3,2,4);
    imshow(PhaseMapVer2);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer2,'PhaseMapVer2.jpg');
        
    subplot(3,2,5);
    imshow(PhaseMapHor);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapHor,'PhaseMapHor.jpg');

    subplot(3,2,6);
    imshow(PhaseMapVer);
    axis off; axis equal; axis tight; hold off;
    imwrite(PhaseMapVer,'PhaseMapVer.jpg');
        

    figure;    
    subplot(2,2,1);
    imshow(ScaledPhaseMapHor);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapHor,'ScaledPhaseMapHor.jpg');

    subplot(2,2,2);
    imshow(ScaledPhaseMapVer);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapVer,'ScaledPhaseMapVer.jpg');

    subplot(2,2,3);
    imshow(ScaledPhaseMapHorBlack);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapHorBlack,'ScaledPhaseMapHorBlack.jpg');

    subplot(2,2,4);
    imshow(ScaledPhaseMapVerBlack);
    axis off; axis equal; axis tight; hold off;
    imwrite(ScaledPhaseMapVerBlack,'ScaledPhaseMapVerBlack.jpg');

    
    figure;    
    subplot(1,3,1);
    imshow(HorRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopy,'HorRetinotopy.jpg');

    subplot(1,3,2);
    imshow(VerRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopy,'VerRetinotopy.jpg');

    subplot(1,3,3);
    imshow(HorVerRetinotopy);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopy,'HorVerRetinotopy.jpg');

    
    figure;    
    subplot(1,3,1);
    imshow(HorRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopyBVoverlay,'HorRetinotopyBVoverlay.jpg');

    subplot(1,3,2);
    imshow(VerRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopyBVoverlay,'VerRetinotopyBVoverlay.jpg');

    subplot(1,3,3);
    imshow(HorVerRetinotopyBVoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopyBVoverlay,'HorVerRetinotopyBVoverlay.jpg');
    

    figure;
    subplot(1,3,1);
    imshow(HorRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorRetinotopyBLoverlay,'HorRetinotopyBLoverlay.jpg');

    subplot(1,3,2);
    imshow(VerRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(VerRetinotopyBLoverlay,'VerRetinotopyBLoverlay.jpg');

    subplot(1,3,3);
    imshow(HorVerRetinotopyBLoverlay);
    axis off; axis equal; axis tight; hold off;
    imwrite(HorVerRetinotopyBLoverlay,'HorVerRetinotopyBLoverlay.jpg');

    disp(' * Done!!');


% function [YF, Y0] = LOCAL_MovingAverageHighPassFilter( Y, SamplingFreq, BaselineWindowSize )
%     % Baseline the data using sliding window approach
% 
%     % Calculate moving average baseline
%     Y0 = smooth(Y,SamplingFreq*BaselineWindowSize);
%     YF = Y - Y0;
%     
% end

