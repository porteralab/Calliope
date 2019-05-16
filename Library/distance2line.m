function dist=distance2line(B,point)
% distance from point to the nearest point on the vector B
% note, both need to be in the form Nx1

B=B(:);
point=point(:);

alpha=(B'*point)/(B'*B);
dist=sqrt(sum((point-alpha*B).^2));




