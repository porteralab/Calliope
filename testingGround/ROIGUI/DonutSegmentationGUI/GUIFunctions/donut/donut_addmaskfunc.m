function donut_addmaskfunc(NewMaskP)

global gh

gh.data.ix(end+1)=NewMaskP(1);
gh.data.iy(end+1)=NewMaskP(2);

donut_inferfunc(1);

if isempty(gh.data.LblMask==size(gh.data.ix,1))
    
    [xL,xR,yL,yR]=donut_retrbound(size(gh.data.ix,1));
    
    circsze=gh.param.HlfWid*2/3;
    [rr cc]=meshgrid(1:2*gh.param.HlfWid+1);
    R=sqrt((rr-gh.param.HlfWid-1).^2+(cc-gh.param.HlfWid-1).^2)<=circsze;
    
    SzePad=zeros(2,2);
    SzePad(1,1)=max(1-(gh.data.ix(end,1)-gh.param.HlfWid),0);
    SzePad(1,2)=max((gh.data.ix(end,1)+gh.param.HlfWid)-gh.data.sze(1),0);
    SzePad(2,1)=max(1-(gh.data.iy(end,1)-gh.param.HlfWid),0);
    SzePad(2,2)=max((gh.data.iy(end,1)+gh.param.HlfWid)-gh.data.sze(2),0);
    
    gh.data.LblMask(xL:xR,yL:yR)=max(gh.data.LblMask(xL:xR,yL:yR),...
        size(gh.data.ix,1)*R(SzePad(1,1)+1:end-SzePad(1,2),SzePad(2,1)+1:end-SzePad(2,2)));

end

if gh.param.ICAFlag
    donut_icafunc(1);
end