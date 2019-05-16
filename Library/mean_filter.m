function B=mean_filter(A)

B=A;

mask=[0 1 -1 -size(A,1)-1 -size(A,1) -size(A,1)+1 size(A,1)-1 size(A,1) size(A,1)+1];
u_mask=[0 1 -size(A,1) -size(A,1)+1 size(A,1) size(A,1)+1];
d_mask=[0 -1 -size(A,1)-1 -size(A,1) size(A,1)-1 size(A,1)];

for gnd=1:numel(A)
    
    if ismember(gnd,1:size(A,1):numel(A))
        curr_mask=u_mask+gnd;
    elseif ismember(gnd,size(A,1):size(A,1):numel(A))
        curr_mask=d_mask+gnd;
    else
        curr_mask=mask+gnd;
    end
    
    curr_mask(curr_mask<1)=[];
    curr_mask(curr_mask>numel(A))=[];
    
    B(gnd)=mean(A(curr_mask));
end