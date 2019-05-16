function donut_switchmaskfunc(IdxMin)

global gh

[xL,xR,yL,yR]=donut_retrbound(IdxMin);
AreaPatch=floor(gh.param.HlfWid^2/4);

if gh.data.MaskType(1,IdxMin)==1
    
    gh.data.LblMaskI(gh.data.LblMaskI==IdxMin)=0;
    
    gh.data.MaskPatchFin{1,IdxMin}=bwareaopen(gh.data.LblMask(xL:xR,yL:yR)==IdxMin,AreaPatch,4);
    OverlapMask=((gh.data.MaskPatchFin{1,IdxMin}.*gh.data.LblMaskM(xL:xR,yL:yR))==0);
    gh.data.LblMaskM(xL:xR,yL:yR)=max(IdxMin*gh.data.MaskPatchFin{1,IdxMin},gh.data.LblMaskM(xL:xR,yL:yR)).*OverlapMask;
    gh.data.MaskType(1,IdxMin)=2;
    gh.data.LblMaskM=gh.data.LblMaskM.*(~gh.data.LblMaskI);
    
elseif gh.data.MaskType(1,IdxMin)==2
    
    gh.data.LblMaskM(gh.data.LblMaskM==IdxMin)=0;
    
    gh.data.MaskPatchFin{1,IdxMin}=bwareaopen(gh.data.MaskPatchBin{1,IdxMin},AreaPatch,4);
    OverlapMask=((gh.data.MaskPatchFin{1,IdxMin}.*gh.data.LblMaskI(xL:xR,yL:yR))==0);
    gh.data.LblMaskI(xL:xR,yL:yR)=max(IdxMin*gh.data.MaskPatchFin{1,IdxMin},gh.data.LblMaskI(xL:xR,yL:yR)).*OverlapMask;
    gh.data.MaskType(1,IdxMin)=1;
    
    gh.data.LblMaskM=gh.data.LblMaskM.*(~gh.data.LblMaskI);
end
donut_extractsigfunc(IdxMin);
donut_clustersignal;
donut_dispdrawfunc;
