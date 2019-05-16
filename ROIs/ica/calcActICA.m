load_var
[xls_num,xls_txt] = xlsread(evalin('base', 'vars.path.batch.file'));
adata_dir = evalin('base', 'vars.path.Adata');
rdata_dir = evalin('base', 'vars.path.rawdata');
s = filesep;

for fnd = 703:703
    fileID = num2str(xls_num(fnd-1,5));
    disp([fileID '    ' num2str(fnd)]);
    dateid = datestr(datenum(xls_txt(fnd,2),'dd.mm.yyyy'),'yyyy-mm-dd');
    animal = cell2mat(xls_txt(fnd,9));
    filedata =  dir([rdata_dir animal s 'ImagingData' s dateid s '*' fileID '*525.bin' ]);
    data = load_bin([rdata_dir animal s 'ImagingData' s dateid s filedata.name]);
    load([adata_dir animal s dateid s animal '-Adata-' fileID '.mat'],'dx','dy');
    
    
    data = shift_data(data, dx, dy);
    data = correct_line_shift(data, mean(data,3));
    data = data - min(min(min(data)));
    % data = avgStack(data, 1, [dx, dy]);
    
    avgdata = avgStack(data, 3, [dx, dy]);
    
    [mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
        movtm] = CellsortPCA(avgdata, [], 100, [], [], []);
    % [mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
    %     movtm] = CellsortPCA(data, [], 100, [3 1], [], []);
    
    %  [PCuse] = CellsortChoosePCs(mixedfilters);
    %  CellsortPlotPCspectrum(avgdata, CovEvals, PCuse);
    % CellsortPlotPCspectrum(data, CovEvals, PCuse);
    PCuse = 1:30;
    [ica_sig, ica_filters, ica_A, numiter] = ...
        CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, 0.7, [], [], [], []);
    
    %  CellsortICAplot('series', ica_filters, ica_sig, template, [], 0.15, 2, 1, [], [], [])
    [ica_segments, segmentlabel, segcentroid] = ...
        CellsortSegmentation(ica_filters, 1.5, 2, [300 10000], 1);
    
    segments = permute(ica_segments,[2 3 1]);
    segments = segments>0;
    for ind=1:size(segments,3)
        segments(:,:,ind) = imfill(segments(:,:,ind),'holes');
        %     segments(:,:,ind) = imerode(segments(:,:,ind),strel('disk',1));
        tempprops = regionprops(segments(:,:,ind),'Area','PixelIdxList');
        [~,maxi] = max([tempprops.Area]);
        segprops(ind) = tempprops(maxi);
    end
    avgseg = sum(segments,3);
    overlapping = [];
    for ind=1:size(segments,3)
        if sum(avgseg(segprops(ind).PixelIdxList)) ~= segprops(ind).Area
            overlapping = [overlapping ind];
        end
    end
    
    dim = size(segments);
    
    for ind=1:length(overlapping)-1
        for knd=ind+1:length(overlapping)
            overPixel = [];
            overPixel = intersect([segprops(overlapping(ind)).PixelIdxList],[segprops(overlapping(knd)).PixelIdxList]);
            maxRegion = max(segprops(overlapping(ind)).Area, segprops(overlapping(knd)).Area);
            if length(overPixel)/maxRegion > 0.5 % same ROI
                segments([segprops(overlapping(ind)).PixelIdxList]+(overlapping(knd)-1)*dim(1)*dim(2)) = 1;
                segments([segprops(overlapping(knd)).PixelIdxList]+(overlapping(ind)-1)*dim(1)*dim(2)) = 1;
            elseif isempty(overPixel)
                % do nothing - not connected
            else % overlapping ROI
                segments(overPixel+(overlapping(ind)-1)*dim(1)*dim(2)) = 0;
                segments(overPixel+(overlapping(knd)-1)*dim(1)*dim(2)) = 0;
                % make sure that both segments are segmentated
                segments(find(bwperim(segments(:,:,overlapping(ind)))==1) + (overlapping(ind)-1)*dim(1)*dim(2)) = 0;
                segments(find(bwperim(segments(:,:,overlapping(knd)))==1) + (overlapping(knd)-1)*dim(1)*dim(2)) = 0;
                tempprops = regionprops(segments(:,:,overlapping(knd)),'Area','PixelIdxList');
                [~,maxi] = max([tempprops.Area]);
                if ~isempty(maxi)
                    segprops(overlapping(knd)) = tempprops(maxi);
                end
            end
        end
    end
    
    % remove small stuff
    
    imROIs = sum(segments,3)>0;
    ROIs = regionprops(imROIs, 'Area', 'PixelIdxList', 'Centroid');
    ROIs = ROIs([ROIs.Area] > 150);
    %rename field to match former convention
    f = fieldnames(ROIs);
    v = struct2cell(ROIs);
    f{strmatch('PixelIdxList',f,'exact')} = 'indices';
    ROIs = cell2struct(v,f);
    ROIs=ROI_activity(data,ROIs);
    np=struct;
    bv=struct;
    ROItrans=[0 0 0];
    save([adata_dir animal s dateid s animal '-Adata-' fileID '.mat'],'ROIs','np','bv','ROItrans','-append');
end