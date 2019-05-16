function stack = avgStack(data, binsize, clipping)
% stack = avgStack(data, binsize, clipping)
%
% Average frames in your stack to produce a (stack length / binsize)stack
% -------------------------------------------------------------------------
% data - your stack
% binsize - number of frames over which to average
% clipping - [optional] clip borders [dx, dy]
% 
% Re-documented 8.5.14 AF
% 
% "Do not trust everything you read online"
%                        - Abraham Lincoln

if (nargin<3) || isempty(clipping)
    clipping = 0;
else
    if size(clipping,2) ~= 2
        error('Wrong format of clipping values. Use 2D array in the form N X 2');
    else
        mindx = abs(min(clipping(:,1)));
        maxdx = max(clipping(:,1));
        mindy = abs(min(clipping(:,2)));
        maxdy = max(clipping(:,2));
    end
end

stack = zeros(size(data,1), size(data,2), ceil(size(data,3)/binsize),class(data));
knd = 1;
if sum(clipping) == 0
    for ind = 1:binsize:size(data,3)
        if ind+binsize < size(data,3)
            stack(:,:,knd) = mean(data(:,:,ind:ind + binsize - 1),3);
        else
            stack(:,:,knd) = mean(data(:,:,ind:end),3);
        end
        knd = knd + 1;
    end
else
    for ind = 1:binsize:size(data,3)
        if ind+binsize < size(data,3)
            stack(:,:,knd) = imRemoveBorders(mean(data(:,:,ind:ind + binsize - 1),3), [mindy maxdy mindx maxdx]);
        else
            stack(:,:,knd) = imRemoveBorders(mean(data(:,:,ind:end),3),[mindy maxdy mindx maxdx]);
        end
        knd = knd + 1;
    end
    
end