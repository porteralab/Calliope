function donut_drawfunc

global gh

StrokeSze=gh.param.NumRing-1;
[rr cc]=meshgrid(1:2*StrokeSze+1);
se=sqrt((rr-StrokeSze-1).^2+(cc-StrokeSze-1).^2)<=StrokeSze;

if gh.data.MaskType(1,gh.param.CurrentCellNum)==1
    gh.data.LblMaskI(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze)=max(gh.param.CurrentCellNum*se,...
    gh.data.LblMaskI(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze));
    
    gh.data.LblMaskM=gh.data.LblMaskM.*(~gh.data.LblMaskI);
    
else
    gh.data.LblMaskM(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze)=max(gh.param.CurrentCellNum*se,...
        gh.data.LblMaskM(gh.param.CursorP(1)-StrokeSze:gh.param.CursorP(1)+StrokeSze,...
        gh.param.CursorP(2)-StrokeSze:gh.param.CursorP(2)+StrokeSze));
    
    gh.data.LblMaskI=gh.data.LblMaskI.*(~gh.data.LblMaskM);
end

donut_extractsigfunc(gh.param.CurrentCellNum);
donut_clustersignal;
donut_dispdrawfunc;