function CellOut=CellRemoveEmpty(CellIn,Idx)

for ii=1:length(Idx)
    CellIn{1,Idx(ii)}=[];
end

CellOut=CellIn(~cellfun('isempty',CellIn));