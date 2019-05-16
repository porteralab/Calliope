function donut_axesfunc(hObject,handles)

global gh

coordinates=get(gh.disp.AxesMain,'CurrentPoint');
gh.param.CursorP=round(fliplr(coordinates(1,1:2)));
gh.param.ClickType=get(gh.disp.figure1,'selectiontype');

if strcmp(gh.param.ClickType,'alt')
    DistMtx=squareform(pdist([[gh.data.ix gh.data.iy];gh.param.CursorP]));
    [DMin,IdxMin]=min(DistMtx(end,1:end-1));
    if DMin<(gh.param.HlfWid+3)
        gh.param.CurrentCellNum=IdxMin;
    end
    donut_dispdrawfunc;
else
    if get(gh.disp.ChckbxRemoveMask,'Value')...
            || get(gh.disp.ChckbxChangeMask,'Value')...
            || get(gh.disp.ChckbxPlotDF,'Value')...
            || get(gh.disp.ChckbxDilateMask,'Value')
        DistMtx=squareform(pdist([[gh.data.ix gh.data.iy];gh.param.CursorP]));
        [DMin,IdxMin]=min(DistMtx(end,1:end-1));
        if DMin<gh.param.HlfWid
            if get(gh.disp.ChckbxRemoveMask,'Value')
                donut_delmaskfunc(IdxMin);
            elseif get(gh.disp.ChckbxChangeMask,'Value')
                donut_switchmaskfunc(IdxMin);
            elseif get(gh.disp.ChckbxDilateMask,'Value')
                donut_refinemask(IdxMin);
            elseif get(gh.disp.ChckbxPlotDF,'Value')
                figure;
                plot(gh.data.RawF(IdxMin,:));
                xlim([1,gh.data.sze(3)]);
                ylim([0,max(gh.data.RawF(IdxMin,:))]);
                xlabel('Frame');
                ylabel('Mean fluorescence intensity');
                title(IdxMin);
            end
        end
    elseif get(gh.disp.ChckbxAddMask,'Value')
        donut_addmaskfunc(gh.param.CursorP);
    elseif get(gh.disp.ChckbxDraw,'Value')
        donut_drawfunc;
    elseif get(gh.disp.ChckbxErase,'Value')
        donut_erasefunc;
    end
end