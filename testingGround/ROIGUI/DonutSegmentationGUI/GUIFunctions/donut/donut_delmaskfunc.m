function donut_delmaskfunc(IdxMin)

global gh

gh.data.ix(IdxMin)=[];
gh.data.iy(IdxMin)=[];
gh.data.LblMask(gh.data.LblMask==IdxMin)=0;
gh.data.LblMask(gh.data.LblMask>IdxMin)=gh.data.LblMask(gh.data.LblMask>IdxMin)-1;

ICMFlag=0;
if ~isempty(gh.data.LblMaskI(gh.data.LblMaskI==IdxMin))
    gh.data.LblMaskI(gh.data.LblMaskI==IdxMin)=0;
    ICMFlag=1;
elseif ~isempty(gh.data.LblMaskM(gh.data.LblMaskM==IdxMin))
    gh.data.LblMaskM(gh.data.LblMaskM==IdxMin)=0;
    ICMFlag=1;
end

if ICMFlag
    gh.data.LblMaskI(gh.data.LblMaskI>IdxMin)=gh.data.LblMaskI(gh.data.LblMaskI>IdxMin)-1;
    gh.data.LblMaskM(gh.data.LblMaskM>IdxMin)=gh.data.LblMaskM(gh.data.LblMaskM>IdxMin)-1;
    
    gh.data.icasig=CellRemoveEmpty(gh.data.icasig,IdxMin);
    gh.data.Ma=CellRemoveEmpty(gh.data.Ma,IdxMin);
    gh.data.MaskPatchBin=CellRemoveEmpty(gh.data.MaskPatchBin,IdxMin);
    gh.data.MaskPatchFin=CellRemoveEmpty(gh.data.MaskPatchFin,IdxMin);
        
    gh.data.CRMax(IdxMin)=[];
    gh.data.EigValRetained(IdxMin)=[];
    gh.data.MaskType(IdxMin)=[];
    
    gh.data.RawF(IdxMin,:)=[];
end

donut_clustersignal;
donut_dispdrawfunc;