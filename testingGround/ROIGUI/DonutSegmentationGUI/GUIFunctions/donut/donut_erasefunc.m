function donut_erasefunc

global gh

StrokeSze=gh.param.NumRing-1;
[rr cc]=meshgrid(1:2*StrokeSze+1);
se=sqrt((rr-StrokeSze-1).^2+(cc-StrokeSze-1).^2)<=StrokeSze;

if gh.data.MaskType(1,gh.param.CurrentCellNum)==1
    if gh.data.LblMaskI(gh.param.CursorP(1),gh.param.CursorP(2))==gh.param.CurrentCellNum
        gh.data.LblMaskI(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze)=~se.*...
        gh.data.LblMaskI(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze);
    end
else
    if gh.data.LblMaskM(gh.param.CursorP(1),gh.param.CursorP(2))==gh.param.CurrentCellNum
        gh.data.LblMaskM(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze)=~se.*...
        gh.data.LblMaskM(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze);
    end
end

donut_extractsigfunc(gh.param.CurrentCellNum);
donut_clustersignal;
donut_dispdrawfunc;