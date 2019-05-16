function donut_extractsigfunc2(IdxList)

global gh

if size(IdxList,2)>1
    gh.data.RawF=zeros(size(gh.data.ix,1),gh.data.sze(3));
end

for ii=1:size(IdxList,2)
    
    if gh.data.MaskType(1,IdxList(1,ii))==1
        [rr,cc]=ind2sub([gh.data.sze(1) gh.data.sze(2)],find(gh.data.LblMaskI==IdxList(1,ii)));
    else
        [rr,cc]=ind2sub([gh.data.sze(1) gh.data.sze(2)],find(gh.data.LblMaskM==IdxList(1,ii)));
    end
    
    if ~isempty(rr)
        xL=min(rr);
        xR=max(rr);
        yL=min(cc);
        yR=max(cc);
        
        if get(gh.main.ChckbxInferReg,'Value')
            ImTemp=gh.data.ImReg(xL:xR,yL:yR,:);
        else
            ImTemp=gh.data.ImRaw(xL:xR,yL:yR,:);
        end
        
        if gh.data.MaskType(1,IdxList(1,ii))==1
            MaskTemp=single(gh.data.LblMaskI(xL:xR,yL:yR)==IdxList(1,ii));
        else
            MaskTemp=single(gh.data.LblMaskM(xL:xR,yL:yR)==IdxList(1,ii));
        end
        MaskTemp(MaskTemp==0)=nan;
        
        MaskRep=reshape(repmat(MaskTemp,1,gh.data.sze(3)),(xR-xL+1),(yR-yL+1),gh.data.sze(3));
        ImTempComp=ImTemp.*MaskRep;
        ImTempComp=reshape(ImTempComp,(xR-xL+1)*(yR-yL+1),gh.data.sze(3));
        gh.data.RawF(IdxList(ii),:)=nanmean(ImTempComp,1);
    else
        gh.data.RawF(IdxList(ii),:)=nan;
    end
end