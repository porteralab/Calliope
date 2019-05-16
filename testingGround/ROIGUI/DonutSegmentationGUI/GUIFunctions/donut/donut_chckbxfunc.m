function donut_chckbxfunc(hObject)

global gh

ObjTag=get(hObject,'Tag');
ChckbxList={'AddMask';'RemoveMask';'DilateMask';'ChangeMask';'PlotDF';'Draw';'Erase'};

if get(hObject,'Value')
    for ii=1:size(ChckbxList,1)
        if ~strcmp(ObjTag(7:end),ChckbxList{ii,1})
            set(eval(['gh.disp.Chckbx' ChckbxList{ii,1}]),'Value',0);
        end
    end
end