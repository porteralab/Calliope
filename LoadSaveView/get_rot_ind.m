function [pix_inds]=get_rot_ind(dims,cf,tx,ty)
% dims: [x y n] - dimension of data
% cf: center frame
% tx: tilt in x (0 means no tilt)
% ty: tilt in y (0 means no tilt)


cf_shift=zeros(dims(1:2));


xdist=ceil(dims(1)/(abs(tx)+1));

for ind=1:abs(tx)+1
    cf_shift((ind-1)*xdist+1:min(dims(1),ind*xdist),:)=ind*sign(tx);
end

ydist=ceil(dims(2)/(abs(ty)+1));

for ind=1:abs(ty)+1
    cf_shift(:,(ind-1)*ydist+1:min(dims(2),ind*ydist))=cf_shift(:,(ind-1)*ydist+1:min(dims(2),ind*ydist))+ind*sign(ty);
end

cf_shift=cf_shift-round((tx+ty)/2);
cf_shift=cf_shift*dims(1)*dims(2);

pix_inds=[(cf-1)*dims(1)*dims(2)+1:cf*dims(1)*dims(2)]+reshape(cf_shift,[1 dims(1)*dims(2)]);
pix_inds(pix_inds<1)=1;
pix_inds(pix_inds>prod(dims))=prod(dims);

