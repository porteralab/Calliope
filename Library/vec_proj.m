function [proj]=vec_proj(B,vec)

% B is a Nx2 set of 2 basis vectors

% proj=B'*vec; 
proj=inv(B'*B)*B'*vec; 