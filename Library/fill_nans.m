function B=fill_nans(A)


B=A;

nan_inds=find(isnan(A));

mask=[1 -1 -size(A,1)-1 -size(A,1) -size(A,1)+1 size(A,1)-1 size(A,1) size(A,1)+1];
u_mask=[1 -size(A,1) -size(A,1)+1 size(A,1) size(A,1)+1];
d_mask=[-1 -size(A,1)-1 -size(A,1) size(A,1)-1 size(A,1)];

for ind=1:length(nan_inds)
    
    if ismember(ind,1:size(A,1):numel(A))
        curr_mask=u_mask+nan_inds(ind);
    elseif ismember(ind,size(A,1):size(A,1):numel(A))
        curr_mask=d_mask+nan_inds(ind);
    else
        curr_mask=mask+nan_inds(ind);
    end
    
    curr_mask(curr_mask<1)=[];
    curr_mask(curr_mask>numel(A))=[];
    
    B(nan_inds(ind))=nanmean(A(curr_mask));
    
end

