function donut_dispdrawfunc

global gh

if ~get(gh.disp.ChckbxDispAvg,'Value')
    if ~get(gh.disp.ChckbxLKDisp,'Value')
        for ii=1:3
            gh.data.cSlice(:,:,ii)=donut_adjustcontrast(NormIm(gh.data.ImRaw(:,:,gh.data.cFrame)),gh.data.cMin,gh.data.cMax);
        end
    else
        for ii=1:3
            gh.data.cSlice(:,:,ii)=donut_adjustcontrast(NormIm(gh.data.ImReg(:,:,gh.data.cFrame)),gh.data.cMin,gh.data.cMax);
        end
    end
else
    if ~get(gh.disp.ChckbxLKDisp,'Value')
        for ii=1:3
            gh.data.cSlice(:,:,ii)=donut_adjustcontrast(NormIm(gh.data.ImRawAvg),gh.data.cMin,gh.data.cMax);
        end
    else
        for ii=1:3
            gh.data.cSlice(:,:,ii)=donut_adjustcontrast(NormIm(gh.data.ImRegAvg),gh.data.cMin,gh.data.cMax);
        end
    end
end

if get(gh.disp.ChckbxDispCluster,'Value') && gh.param.ClusterFlag
    alpha=repmat(0.35*(gh.data.LblMaskC>0),[1 1 3]);
    labels=single(label2rgb(gh.data.LblMaskC)/255);
    gh.data.cSlice=((1-alpha).*gh.data.cSlice)+(alpha.*labels);
else
    if gh.param.InferFlag
        if get(gh.disp.ChckbxDispSF,'Value');
            if get(gh.disp.ChckbxDispSFIC,'Value');
                gh.data.cSlice(:,:,1)=min(gh.data.cSlice(:,:,1),~bwperim(gh.data.LblMaskI));
                gh.data.cSlice(:,:,2)=min(gh.data.cSlice(:,:,2),~bwperim(gh.data.LblMaskI));
                gh.data.cSlice(:,:,3)=max(gh.data.cSlice(:,:,3),bwperim(gh.data.LblMaskI));
                
                gh.data.cSlice(:,:,1)=max(gh.data.cSlice(:,:,1),bwperim(gh.data.LblMaskM));
                gh.data.cSlice(:,:,2)=min(gh.data.cSlice(:,:,2),~bwperim(gh.data.LblMaskM));
                gh.data.cSlice(:,:,3)=min(gh.data.cSlice(:,:,3),~bwperim(gh.data.LblMaskM));
            else
                gh.data.cSlice(:,:,1)=max(gh.data.cSlice(:,:,1),bwperim(gh.data.LblMask));
                gh.data.cSlice(:,:,2)=min(gh.data.cSlice(:,:,2),~bwperim(gh.data.LblMask));
                gh.data.cSlice(:,:,3)=min(gh.data.cSlice(:,:,3),~bwperim(gh.data.LblMask));
            end
        end
    end
end


set(gh.disp.ih,'CDATA',gh.data.cSlice);

if myIsField(gh.disp,'TextH')
    if size(gh.disp.TextH,1)>=1
        NumMasks=size(gh.disp.TextH,2);
        for ii=1:NumMasks
            delete(gh.disp.TextH{1,NumMasks-ii+1});
            gh.disp.TextH=CellRemoveEmpty(gh.disp.TextH,NumMasks-ii+1);
        end
    end
end
if get(gh.disp.ChckbxDispMaskNum,'Value')
    for ii=1:size(gh.data.ix,1)
        if ii==gh.param.CurrentCellNum
            C=0.9*[0 1 0];
        else
            C=0.8*[1 1 1];
        end
        if ~get(gh.disp.ChckbxDispCluster,'Value')
            gh.disp.TextH{1,ii}=text(gh.data.iy(ii),gh.data.ix(ii),num2str(ii),'Parent',gh.disp.AxesMain,'color',C);
        else
            gh.disp.TextH{1,ii}=text(gh.data.iy(ii),gh.data.ix(ii),num2str(gh.data.groups(ii)),'Parent',gh.disp.AxesMain,'color',C);
        end
    end
end