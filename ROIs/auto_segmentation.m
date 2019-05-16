function [ROIs]=auto_segmentation(data,dx,dy,mFrame,mu,thres,area,nPC,nIC,do_smoothing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------Automatic segmentation---------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Perform automatic segmentation of neurons using PCA and ICA.

% Inputs: 
%-------------------------------------------------------------------------
% data      - data  
% mFrame    - number of frames to average for analysis
% mu        - Weight factor for the temporal information in the ICA
% thres     - Threshold given in SD for ROI segmentation 
% area      - ROI size limits in px, e.g [200 1000]
% npc       - Number of principal components to compute and use for ICA
% nic       - Number of independent components to compute in ICA
% dx        - x correction
% dy        - y correction


% Output:
%-------------------------------------------------------------------------
% ROIs      - All ROIs with repetitions and overlaps removed.

% Example:
%-------------------------------------------------------------------------
% First load the bin file for the dataset.
% auto_segmentation(data,dx,dy,10,0.8,3.00,[200 1000],150,150)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%------Standard settings-----%%%%%%%%%%%%%%%%%%%%%%%%
if exist('mFrame','var')
    if isempty(mFrame)
        mFrame = 10;
    end
else
    mFrame = 10;
end

if exist('nPC','var')
    if isempty(nPC)
        nPC = 150;
    end
else
    nPC = 150;
end

if exist('nIC','var')
    if isempty(nIC)
        nIC = 150;
    end
else
    nIC = 150;
end

if exist('mu','var')
    if isempty(mu)
        mu = 0.8;
    end
else
    mu = 0.8;
end

if exist('thres','var')
    if isempty(thres)
        thres = 3.00;
    end
else
    thres = 3.00;
end

if exist('area','var')
    if isempty(area)
        area = [200 1000];
    end
else
    area = [200 1000];
end

if exist('filt_dev','var')
    if isempty(filt_dev)
        filt_dev = 2;
    end
else
    filt_dev = 2;
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%-------Calculate dF/F----------%%%%%%%%%%%%%%%%%%%%%%
tic
disp('----------------Calculating dF/F----------------')
for layer = 1:size(data,2);
    medianData{layer} = median(data{layer},3);
    for frame = 1:size(data{layer},3)
        data{layer}(:,:,frame) = (data{layer}(:,:,frame)-medianData{layer})./medianData{layer};
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%------PCA ICA Analysis-----%%%%%%%%%%%%%%%%%%%%%%%%
for layer = 1:size(data,2);
    %Average frames
    avgdata = avgStack(data{layer}, mFrame, [dx{layer}, dy{layer}]);

    %Calculate PCA
    [mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
        movtm] = CellsortPCA(avgdata, [], nPC, [], [], []);
    
    clear avgdata;
    toc
    %Calculate ICA
    PCuse = 1:nPC;
    [ica_sig, ica_filters, ica_A, numiter] = ...
        CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC, [], [], []);
    
    %Perform segementation
    [L] = ...
        CellsortSegmentation_axon(ica_filters, 2, thres, area, 0);
    
    
    clear tempROIs

    %Get individual ROIs
    tempROIs = struct;
    count = 1;
    segments = permute(L,[2 3 1]);
    for ind = 1:size(segments,3)
        temp = regionprops(segments(:,:,ind) > 0 , 'Area', 'PixelIdxList');
        for jnd=1:size(temp,1)
            if temp(jnd).Area > area(1)
                tempROIs(count).indices = temp(jnd).PixelIdxList;
                tempROIs(count).Area = temp(jnd).Area;
                tempROIs(count).ica = ind;
                count = count + 1;
            end
        end
    end
    if ~isfield(tempROIs,'indices')
        disp('ERROR - no ROIs found at these settings - try adjusting the area');
        keyboard
    end
        
    for indic = 1:length(tempROIs);
        allROIs{layer}(indic).indices = tempROIs(indic).indices;
    end
end
toc
%%%%%%%%%%%%%%%%----Post segmentation ROI modification----%%%%%%%%%%%%%%%%%
disp('----------------Smooth ROIs----------------')
if do_smoothing
    %Smooth ROIs using a gaussian filter, round binary mask and erode with 2 px
    mask = zeros(size(data{1},1),size(data{1},2));
    for layer = 1:size(data,2);
        for indic = 1:length(allROIs{layer});
            tempSmoothROI = [];
            maskROI = mask;
            maskROI(allROIs{layer}(indic).indices) = 1;
            tempSmoothROI = round(imgaussfilt(maskROI,2));
            se=strel('disk',2);
            tempSmoothROI = imerode(tempSmoothROI,se);
            pixClusts=bwconncomp(tempSmoothROI);
            [~,maxClust]=max(cellfun(@length,pixClusts.PixelIdxList));
            smoothROI{layer}(indic).indices = pixClusts.PixelIdxList{maxClust};
        end
    end
else
    smoothROI=allROIs;
end

disp('----------------Remove overlapping ROIs----------------')
%Remove overlapping ROIs
overlap = {};
for layer = 1:size(data,2);
    
    cnt = 0;
    overlap{layer}=[];
    for indic1 = 1:length(smoothROI{layer});
        for indic2 = (1+indic1):length(smoothROI{layer});
            tempOverlap = length(intersect(smoothROI{layer}(indic1).indices,smoothROI{layer}(indic2).indices));
            if tempOverlap > 50;
                cnt = cnt + 1;
                overlap{layer}(cnt) = indic2;
            end
        end
    end

    
    try
        overlap{layer} = unique(overlap{layer});
        cleanROIs{layer} = smoothROI{layer};
        cleanROIs{layer}(overlap{layer}) = [];
    catch
        cleanROIs{layer} = smoothROI{layer};
    end
end
        
for layer = 1:size(data,2);
    for indic1 = 1:length(cleanROIs{layer});
        for indic2 = (1+indic1):length(cleanROIs{layer});
            cleanROIs{layer}(indic1).indices = setdiff(cleanROIs{layer}(indic1).indices,cleanROIs{layer}(indic2).indices);
            cleanROIs{layer}(indic2).indices = setdiff(cleanROIs{layer}(indic2).indices,cleanROIs{layer}(indic1).indices);
            cleanROIs{layer}(indic1).type = 0;
            cleanROIs{layer}(indic1).shift = [0 0];
        end
    end
end
% %Plot final ROIs
% ind=1
% ROIs2image(cleanROIs{ind},size(template{ind}),'display',1);
% ROIs2image(cleanROIs{ind},size(template{ind}),'template',template{ind},'display',1);
% ROIs2image(cleanROIs{ind},size(template{ind}),'template',template{ind},'display',1,'singlecolor',[1 0 0]);
disp('----------------DONE!----------------')
toc
ROIs = cleanROIs;
