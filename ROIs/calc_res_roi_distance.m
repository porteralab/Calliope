function dist=calc_res_roi_distance(roi1,roi2,ROIs,resFOV,frameFOV,resPix,framePix,dutyCycle)
% calculate the distance between the center of mass of two ROIs
% roi1 index of ROI 1
% roi2 index of ROI 2
% ROIs the ROIs structure
% resFOV the resonant field of view in um
% frameFOV the frame galvo field of view in um
% resPix the resonant axis pixel resolution
% framePix the frame galvo axis pixel resolution
% duty cycle the duty cycle of the resonant axis (default 0.5)
%
% example:
% calc_res_roi_distance(10,15,proj_meta(1).rd(1,1).ROIinfo,300,200,750,400,0.5)

if nargin<8
    dutyCycle=0.5;
end

sx=sin([1/resPix*dutyCycle:pi/resPix*dutyCycle:pi]);
pd=sx((1/dutyCycle-1)*resPix/2+1:(1/dutyCycle-1)*resPix/2+resPix);
resPos=cumsum(pd/sum(pd)*resFOV);

framePos=[1:framePix]/framePix*frameFOV;
 
im1=ROIs2image(ROIs(roi1),[framePix resPix]);
xc1=round(median(find(sum(im1))));
yc1=round(median(find(sum(im1'))));

im2=ROIs2image(ROIs(roi2),[framePix resPix]);
xc2=round(median(find(sum(im2))));
yc2=round(median(find(sum(im2'))));


dx=resPos(xc2)-resPos(xc1);
dy=framePos(yc2)-framePos(yc1);

dist=sqrt(dx^2+dy^2);



