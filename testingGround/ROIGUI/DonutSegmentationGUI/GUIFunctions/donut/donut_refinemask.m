function donut_refinemask(IdxList)

global gh

se=strel('disk',1);

for ii=1:size(IdxList,2)
    
    [xL,xR,yL,yR]=donut_retrbound(IdxList(1,ii));
    
    if get(gh.main.ChckbxInferReg,'Value')
        ImTemp=gh.data.ImReg(xL:xR,yL:yR,:);
    else
        ImTemp=gh.data.ImRaw(xL:xR,yL:yR,:);
    end
    
    if gh.data.MaskType(IdxList(1,ii))==1
        MaskDil=(gh.data.LblMaskI(xL:xR,yL:yR)==IdxList(1,ii));
    else
        MaskDil=(gh.data.LblMaskM(xL:xR,yL:yR)==IdxList(1,ii));
    end
    
    ChangeFlag=0;
    
    for jj=1:gh.param.NumRing
        
        MaskTemp=MaskDil;
        MaskDil=imdilate(MaskDil,se);
        MaskDiff=single(MaskDil-MaskTemp);
        MaskDiff(MaskDiff==0)=nan;
        
        MaskRep=reshape(repmat(MaskDiff,1,gh.data.sze(3)),(xR-xL+1),(yR-yL+1),gh.data.sze(3));
        ImTempComp=ImTemp.*MaskRep;
        ImTempComp=reshape(ImTempComp,(xR-xL+1)*(yR-yL+1),gh.data.sze(3));
        corrMat=corr([gh.data.RawF(IdxList(1,ii),:)' ImTempComp']);
        NewPixels=reshape((corrMat(1,2:end)>gh.param.CretCorr2),xR-xL+1,yR-yL+1);
        
        MaskDil=(MaskTemp+NewPixels)>0;
        
        if nansum(NewPixels(:))
            ChangeFlag=1;
        end
    end
    
    if ChangeFlag
        fprintf('%s\n',['Mask ' num2str(IdxList(ii)) ' changed.']);
    end
    
    if gh.data.MaskType(IdxList(1,ii))==1
        gh.data.LblMaskI(gh.data.LblMaskI==IdxList(1,ii))=0;
        gh.data.MaskPatchFin{1,IdxList(1,ii)}=MaskDil;
        OverlapMask=((gh.data.MaskPatchFin{1,IdxList(1,ii)}.*gh.data.LblMaskI(xL:xR,yL:yR))==0);
        gh.data.LblMaskI(xL:xR,yL:yR)=max(IdxList(1,ii)*gh.data.MaskPatchFin{1,IdxList(1,ii)},gh.data.LblMaskI(xL:xR,yL:yR)).*OverlapMask;
        gh.data.MaskType(1,IdxList(1,ii))=1;
    else
        gh.data.LblMaskM(gh.data.LblMaskM==IdxList(1,ii))=0;
        gh.data.MaskPatchFin{1,IdxList(1,ii)}=MaskDil;
        OverlapMask=((gh.data.MaskPatchFin{1,IdxList(1,ii)}.*gh.data.LblMaskM(xL:xR,yL:yR))==0);
        gh.data.LblMaskM(xL:xR,yL:yR)=max(IdxList(1,ii)*gh.data.MaskPatchFin{1,IdxList(1,ii)},gh.data.LblMaskM(xL:xR,yL:yR)).*OverlapMask;
        gh.data.MaskType(1,IdxList(1,ii))=2;
    end
    
    donut_extractsigfunc(IdxList(1,ii));
    
end

gh.data.LblMaskM=gh.data.LblMaskM.*(~gh.data.LblMaskI);

donut_clustersignal;

donut_dispdrawfunc;