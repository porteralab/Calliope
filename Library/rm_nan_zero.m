
function [result,idx] = rm_nan_zero(input,dim)
%%[result,idx] = rm_nan_zero(input,dim)
% remove NaN or/and zeros linewise from array
% inputs:
%        input: your input array
%        dim: the array dimension over which to remove NaN's and zeros
%        (if 1, remove all-zero columns - if 2, remove all-zero rows
% ML
% doc edited by AF, 08.05.2014
if nargin < 2
    dim = 1;
end
if length(size(input)) ~= 2 || dim > 2
    error('works only for two dimensional arrays');
end

idx = ~any(isnan(input),dim) & sum(input,dim)~=0;
if dim == 2
    result = input(idx,:);
%     result = input(~any(isnan(input),dim),:);
%     result = result(sum(result,dim)~=0,:);
elseif dim == 1
%     idx = ~any(isnan(input),dim) | sum(result,dim)~=0;
    result = input(:,idx);
%     result = input(:,~any(isnan(input),dim));
%     result = result(:,sum(result,dim)~=0);
end