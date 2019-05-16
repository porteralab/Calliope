function [data,marks]=rotate_stack(data,marks,dimorder)


data_size=size(data);

for ind=1:length(marks)
    [tmp(1),tmp(2),tmp(3)]=ind2sub(size(data),marks(ind));
    marks(ind)=sub2ind(data_size(dimorder),tmp(dimorder(1)),tmp(dimorder(2)),tmp(dimorder(3)));
end

data=permute(data,dimorder);


