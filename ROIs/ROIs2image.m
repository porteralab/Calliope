function [im] = ROIs2image(ROIs,dim,varargin)
%ROIs2image Convert indices of ROIs to an image
%   ROIs2image(ROIs,dim,'Property1',PropertyValue1, ...)
%
%   written by Marcus 2012
%
%   INPUTS
%   ROIs        structure containing the indices as fieldnames 'indices'
%               or 'PixelIdxList'
%   dim         dimension of output image
%
%   optional INPUTS and PROPERTIES
%   e.g. ROIs2image(ROIs, size(template), 'randcolor', 0)
%   type        ['full', 'perim'] - type of filling
%   randcolor   [0,1] - random coloring (default is 1)
%   singlecolor single color for all ROIs, in RGB e.g. [0 1 1]
%   template    background image, coloring always random
%   display     [0,1] - output ROIs as figure

randcolor = 1;
singlecolor = [];
display = 0;
template = [];
typefill = 'full';
sel = expmat((1:length(ROIs))',2);

if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin(1:end-1), 'char'));
    for ind = 1:length(numIndex)
        switch lower(varargin{numIndex(ind)})
            case 'randcolor'
                randcolor = varargin{numIndex(ind) + 1};
            case 'singlecolor'
                singlecolor = varargin{numIndex(ind) + 1};
            case 'display'
                display = varargin{numIndex(ind) + 1};
            case 'template'
                template = varargin{numIndex(ind) + 1};
            case 'type'
                typefill = varargin{numIndex(ind) + 1};
            case 'sel'
                sel = varargin{numIndex(ind) + 1};
                % second column is color group, set to 1 if nothing is provided
                if ~isempty(sel)
                    [m1,ii] = min(size(sel));
                    if ii == 1;
                        sel = sel';
                        if m1 == 1
                            sel(:,2) = 1;
                        end
                    end
                end
        end
    end
end

% rename index field if necessary
if sum(cell2mat(regexp(fieldnames(ROIs),'PixelIdxList')))
    [ROIs.('PixelIdxList')] = ROIs.('indices');
    ROIs = rmfield(ROIs,'PixelIdxList');
elseif sum(cell2mat(regexp(fieldnames(ROIs),'indices')))
    % do nothing
else
    error('ROIs do not contain field ''PixelIdxList'' or ''indices''!');
end

% centroids = zeros(2, length(ROIs));



if randcolor && isempty(singlecolor)
    colors = randperm(max(sel(:,2)))+1;
    colors2 = rand(3,max(sel(:,2)));
elseif ~randcolor && isempty(singlecolor)
    colors = 2:max(sel(:,2))+1;
    colors2 = jet(max(sel(:,2)))';
else
    colors = repmat(round(sum(singlecolor)) * 10, 1, max(sel(:,2)));
    colors2 =  repmat(singlecolor', 1, max(sel(:,2)));
end

if isempty(template)
    im = zeros(dim);
    for ind = 1:length(sel)
        if strcmp(typefill,'full')
            if ismember(ind,sel(:,1))
                im(ROIs(ind).indices) = colors(sel(sel(:,1)==ind,2));
            else
                im(ROIs(ind).indices) = 1;
            end
        else
            tempim = logical(zeros(dim));
            tempim(ROIs(ind).indices) = 1;
            tempim = bwperim(tempim);
            if ismember(ind,sel(:,1))
                im(tempim>0) = colors(sel(sel(:,1)==ind,2));
            else
                im(tempim>0) = 1;
            end
            %     temp = regionprops(tempim, 'Centroid');
            %     centroids(:,ind) = temp.Centroid;
        end
    end
else
    im = repmat(template,[1 1 3]);
    max_scale = prctile(im(:),99);
    min_scale = prctile(im(:),1);
%     min_scale = min(template(:));
%     max_scale = max(template(:));
    im = (im - min_scale)/(max_scale - min_scale);
    for ind = 1:length(ROIs)
        idx = ROIs(ind).indices;
        if strcmp(typefill,'perim')
            tempim = logical(zeros(dim));
            tempim(idx) = 1;
            tempim = bwperim(tempim);
            idx = find(tempim > 0);
            if ismember(ind,sel(:,1))
                for ii = 1:3
                    im(idx + (ii-1)*prod(dim)) = repmat(colors2(ii,sel(sel(:,1)==ind,2)),1,length(idx));
                end
            else
                for ii = 1:3
                    im(idx + (ii-1)*prod(dim)) = 0.5;%repmat(0,1,length(idx));
                end
            end
        else
            if ismember(ind,sel(:,1))
                for ii = 1:3
                    im(idx + (ii-1)*prod(dim)) = colors2(ii,sel(sel(:,1)==ind,2));
                end
            else
                for ii = 1:3
                    im(idx + (ii-1)*prod(dim)) = 0.5;
                end
            end
        end
    end
    im(im>1) = 1;
    im(im<0) = 0;
end


if display
    figure, imagesc(im)
    colormap colorcube
    axis off
    axis equal
    set(gca,'Position', [0 0 1 1]);
end