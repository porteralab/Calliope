function [imgout]=overlay_ROIs_on_image(imgin,ROIs)

max_scale=prctile(imgin(:),99);
min_scale=prctile(imgin(:),1);

imgin=(imgin-min_scale)/(max_scale-min_scale);
imgin(imgin>1)=1;
imgin(imgin<0)=0;

imgout=zeros([size(imgin) 3]);

roiim=zeros(size(imgin));
for ind=1:length(ROIs)
    roiim(ROIs(ind).indices)=1;
end
roiim=bwperim(roiim);
tmp=imgin;
tmp(roiim==1)=1;
imgout(:,:,1)=tmp;
imgout(:,:,2)=imgin;
imgout(:,:,3)=imgin;
