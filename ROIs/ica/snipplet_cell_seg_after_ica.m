segments = permute(ica_segments,[2 3 1]);
segments = segments>0;
for ind=1:size(segments,3)
    segments(:,:,ind) = imfill(segments(:,:,ind),'holes');
    segments(:,:,ind) = imerode(segments(:,:,ind),strel('disk',1));
    tempprops = regionprops(segments(:,:,ind),'Area','PixelIdxList');
    [~,maxi] = max([tempprops.Area]);
    segprops(ind) = tempprops(maxi);
end

% version #1
for ind=1:size(segments,3)
    for jnd = 1:size(segments,3)
        if ind ~= jnd
            corr_result = corr2(segments(:,:,ind),segments(:,:,jnd));
            if corr_result > 0.5
                temp = zeros(size(segments(:,:,1)));
                temp(intersect([segprops(ind).PixelIdxList],[segprops(jnd).PixelIdxList])) = 1;
                segments(:,:,ind) = temp;
                segments(:,:,jnd) = zeros(size(segments(:,:,1)));
            elseif corr_result > 0.01 && corr_result <= 0.5
                tempind = intersect([segprops(ind).PixelIdxList],[segprops(jnd).PixelIdxList]);
                temp = segments(:,:,ind);
                temp(tempind) = 0;
                segments(:,:,ind) = temp;
                temp = segments(:,:,jnd);
                temp(tempind) = 0;
                segments(:,:,jnd) = temp;
            end
        end
        
    end
end


% version 2
% for cell segmentation, kind of working
segments = permute(ica_segments,[2 3 1]);
segments = segments>0;
for ind=1:size(segments,3)
    segments(:,:,ind) = imfill(segments(:,:,ind),'holes');
    segments(:,:,ind) = imerode(segments(:,:,ind),strel('disk',1));
    tempprops = regionprops(segments(:,:,ind),'Area','PixelIdxList');
    segprops(ind) = tempprops(1);
    segprops(ind).PixelIdxList = cell2mat({tempprops.PixelIdxList}');
    segprops(ind).Area = cell2mat({tempprops.Area}');
%     [~,maxi] = max([tempprops.Area]);
%     segprops(ind) = tempprops(maxi);
end
for ind=1:size(segments,3)
    for jnd = 1:size(segments,3)
        if ind ~= jnd
            temp_ind = intersect([segprops(ind).PixelIdxList],[segprops(jnd).PixelIdxList]);
            maxArea = [max(segprops(ind).Area),max(segprops(jnd).Area)];
            [~,I] = min(maxArea);
            if (length(temp_ind)/maxArea(I)) > 0.9 && (length(temp_ind)/maxArea(mod(I,2)+1)) > 0.7
                temp = zeros(size(segments(:,:,1)));
                temp(unique([segprops(ind).PixelIdxList; segprops(jnd).PixelIdxList])) = 1;
                segments(:,:,ind) = temp;
                segments(:,:,jnd) = zeros(size(segments(:,:,1)));
                segprops(jnd).Area = 0;
            elseif (length(temp_ind)/maxArea(I)) > 0.9 && (length(temp_ind)/maxArea(mod(I,2)+1)) > 0.3
                if I == 1
                    segments(:,:,jnd) = zeros(size(segments(:,:,1)));
%                     segprops(jnd).Area = 0;
                else
                    segments(:,:,ind) = segments(:,:,jnd);
                    segments(:,:,jnd) = zeros(size(segments(:,:,1)));
%                     segprops(jnd).Area = 0;
                end
            else
%                 tempind = intersect([segprops(ind).PixelIdxList],[segprops(jnd).PixelIdxList]);
%                 temp = segments(:,:,ind);
%                 temp(tempind) = 0;
%                 segments(:,:,ind) = temp;
%                 temp = segments(:,:,jnd);
%                 temp(tempind) = 0;
%                 segments(:,:,jnd) = temp;
                
            end
        end
    end
end
