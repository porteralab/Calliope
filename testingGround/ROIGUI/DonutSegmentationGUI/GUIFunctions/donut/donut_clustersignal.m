function donut_clustersignal

global gh

gh.param.ClusterFlag=1;

corrMat=corr(gh.data.RawF');
dissimilarity=1-corrMat;
Z=linkage(dissimilarity,'average');
gh.data.groups=cluster(Z,'criterion','distance','cutoff',1.5);

gh.data.LblMaskC=max(gh.data.LblMaskM,gh.data.LblMaskI);
for ii=1:size(gh.data.ix,1)
    if gh.data.MaskType(1,ii)==1
        gh.data.LblMaskC(gh.data.LblMaskI==ii)=gh.data.groups(ii);
    elseif gh.data.MaskType(1,ii)==2
        gh.data.LblMaskC(gh.data.LblMaskM==ii)=gh.data.groups(ii);
    end
end

% gh.data.LblMaskC=gh.data.LblMask;
% for ii=1:size(gh.data.ix,1)
%         gh.data.LblMaskC(gh.data.LblMask==ii)=gh.data.groups(ii);
% end

% 
% for ii=1:max(gh.data.groups)
%     LblMaskTemp=bwlabel(gh.data.LblMaskC==ii);
%     if max(LblMaskTemp(:))>1
%         
%         CentroidCoorTemp=[];
%         StatROI=regionprops(LblMaskTemp);
%         for jj=1:size(StatROI,1);
%             CentroidCoorTemp(jj,:)=StatROI(jj,1).Centroid;
%         end
%         
%         DistMtx=squareform(pdist(CentroidCoorTemp));
%         
%         
%         
%     end
% end
% 
% 
% 
% imagesc(gh.data.LblMaskC)
% 
% for ii=1:max(gh.data.groups)
%     corr(gh.data.RawF(gh.data.groups==ii,:)')
% end

