function donut_icafunc(AddFlag)

global gh

gh.param.ICAFlag=1;
AreaPatch=floor(gh.param.HlfWid^2/4);

if ~AddFlag
    StartNum=1;
    gh.data.LblMaskI=zeros(size(gh.data.LblMask));
    gh.data.LblMaskM=zeros(size(gh.data.LblMask));
    gh.data.Ma=cell(1,size(gh.data.ix,1));
    gh.data.Wm=cell(1,size(gh.data.ix,1));
    gh.data.MaskPatchBin=cell(1,size(gh.data.ix,1));
    gh.data.MaskPatchFin=cell(1,size(gh.data.ix,1));
    gh.data.CRMax=zeros(1,size(gh.data.ix,1));
    gh.data.EigValRetained=zeros(1,size(gh.data.ix,1));
    gh.data.MaskType=zeros(1,size(gh.data.ix,1));
    gh.data.icasig=cell(1,size(gh.data.ix,1));
else
    StartNum=size(gh.data.ix,1);
    gh.data.Ma{1,StartNum}=[];
    gh.data.Wm{1,StartNum}=[];
    gh.data.MaskPatchBin{1,StartNum}=[];
    gh.data.MaskPatchFin{1,StartNum}=[];
    gh.data.CRMax(1,StartNum)=0;
    gh.data.EigValRetained(1,StartNum)=0;
    gh.data.MaskType(1,StartNum)=0;
    gh.data.icasig{1,StartNum}=[];
end


for ii=StartNum:size(gh.data.ix,1)
    [xL,xR,yL,yR]=donut_retrbound(ii);
    
    AreaMax=(xR-xL+1)*(yR-yL+1)/2;
    AreaMin=(xR-xL+1)*(yR-yL+1)/6;
    
    if get(gh.main.ChckbxInferReg,'Value')
        ImROIv{1,ii}=gh.data.ImReg(xL:xR,yL:yR,:);
    else
        ImROIv{1,ii}=gh.data.ImRaw(xL:xR,yL:yR,:);
    end
    [mixsig]=reshape(ImROIv{1,ii},(xR-xL+1)*(yR-yL+1),gh.data.sze(3));
    
    [gh.data.icasig{1,ii},gh.data.Ma{1,ii},gh.data.Wm{1,ii},gh.data.EigValRetained(1,ii)]=...
        fastica(mixsig,'lastEig',gh.param.NumPC,'numOfIC',gh.param.NumIC);
    
    if ~isempty(gh.data.Ma{1,ii})
        MaskPatch{ii,1}=reshape(gh.data.Ma{1,ii}(:,1),(xR-xL+1),(yR-yL+1));
        MaskPatch{ii,2}=reshape(gh.data.Ma{1,ii}(:,2),(xR-xL+1),(yR-yL+1));
        M1=mean(gh.data.Ma{1,ii}(:,1));
        M2=mean(gh.data.Ma{1,ii}(:,2));
        MaskPatchBin{ii,1}=MaskPatch{ii,1}>M1;
        MaskPatchBin{ii,2}=MaskPatch{ii,1}<M1;
        MaskPatchBin{ii,3}=MaskPatch{ii,2}>M2;
        MaskPatchBin{ii,4}=MaskPatch{ii,2}<M2;
        
        for jj=1:4
            CRMtx=normxcorr2(MaskPatchBin{ii,jj},(gh.data.LblMask(xL:xR,yL:yR)==ii));
            sze=size(CRMtx);
            CR(ii,jj)=CRMtx(ceil(sze(1)/2),ceil(sze(2)/2));
        end
        [gh.data.CRMax(1,ii),IdxMax]=max(CR(ii,:));
        gh.data.MaskPatchBin{1,ii}=bwmorph(MaskPatchBin{ii,IdxMax},'spur');
        
        if (sum(gh.data.MaskPatchBin{1,ii}(:))<AreaMax)...
                && (sum(gh.data.MaskPatchBin{1,ii}(:))>AreaMin)...
                && ((gh.data.CRMax(1,ii)>gh.param.CretCorr0) ||...
                ((gh.data.CRMax(1,ii)>gh.param.CretCorr0*2/3) && (gh.data.EigValRetained(1,ii)>(gh.param.InclCret*2/3))) ||...
                ((gh.data.CRMax(1,ii)>gh.param.CretCorr0/3) && (gh.data.EigValRetained(1,ii)>gh.param.InclCret)))
            
            gh.data.MaskPatchFin{1,ii}=bwareaopen(gh.data.MaskPatchBin{1,ii},AreaPatch,4);
            OverlapMask=((gh.data.MaskPatchFin{1,ii}.*gh.data.LblMaskI(xL:xR,yL:yR))==0);
            gh.data.LblMaskI(xL:xR,yL:yR)=max(ii*gh.data.MaskPatchFin{1,ii},gh.data.LblMaskI(xL:xR,yL:yR)).*OverlapMask;
            gh.data.MaskType(1,ii)=1;
        end
    end
    
    if ~gh.data.MaskType(1,ii)
        corrMat=corr(mixsig');
        corrMatSum=sum(corrMat,1);
        
        dissimilarity=1-corrMat;
        Z=linkage(dissimilarity,'complete');
        groups=cluster(Z,'criterion','distance','MaxClust',3);
        
        for jj=1:3
            MaskPatchBin{ii,jj}=(reshape(groups,xR-xL+1,yR-yL+1)==jj);
            CRMtx=normxcorr2(MaskPatchBin{ii,jj},reshape(corrMatSum>mean(corrMatSum),xR-xL+1,yR-yL+1));
            sze=size(CRMtx);
            CR(ii,jj)=CRMtx(floor(sze(1)/2),floor(sze(2)/2));
        end
        [gh.data.CRMax(1,ii),IdxMax]=max(CR(ii,:));
        gh.data.MaskPatchBin{1,ii}=bwmorph(MaskPatchBin{ii,IdxMax},'spur');
        
        if (sum(gh.data.MaskPatchBin{1,ii}(:))<AreaMax)...
                && (sum(gh.data.MaskPatchBin{1,ii}(:))>AreaMin)...
                && (gh.data.CRMax(1,ii)>gh.param.CretCorr1)
            gh.data.MaskPatchFin{1,ii}=bwareaopen(gh.data.MaskPatchBin{1,ii},AreaPatch,4);
            OverlapMask=((gh.data.MaskPatchFin{1,ii}.*gh.data.LblMaskI(xL:xR,yL:yR))==0);
            gh.data.LblMaskI(xL:xR,yL:yR)=max(ii*gh.data.MaskPatchFin{1,ii},gh.data.LblMaskI(xL:xR,yL:yR)).*OverlapMask;
            gh.data.MaskType(1,ii)=1;
        else
            gh.data.MaskPatchFin{1,ii}=bwareaopen(gh.data.LblMask(xL:xR,yL:yR)==ii,AreaPatch,4);
            OverlapMask=((gh.data.MaskPatchFin{1,ii}.*gh.data.LblMaskM(xL:xR,yL:yR))==0);
            gh.data.LblMaskM(xL:xR,yL:yR)=max(ii*gh.data.MaskPatchFin{1,ii},gh.data.LblMaskM(xL:xR,yL:yR)).*OverlapMask;
            gh.data.MaskType(1,ii)=2;
        end
        
    end
end

gh.data.LblMaskM=gh.data.LblMaskM.*(~gh.data.LblMaskI);

for ii=StartNum:size(gh.data.ix,1)
    if gh.data.MaskType(ii)==1
        gh.data.LblMaskI=gh.data.LblMaskI.*~((gh.data.LblMaskI==ii)-bwareaopen(gh.data.LblMaskI==ii,round(gh.param.HlfWid/2),4));
    else
        gh.data.LblMaskM=gh.data.LblMaskM.*~((gh.data.LblMaskM==ii)-bwareaopen(gh.data.LblMaskM==ii,round(gh.param.HlfWid/2),4));
    end
end

if ~AddFlag
    donut_extractsigfunc(1:size(gh.data.ix,1));
else
    donut_extractsigfunc(size(gh.data.ix,1));
end

donut_clustersignal;

donut_dispdrawfunc;