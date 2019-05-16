function [data, metadata] = load_lsm(fname)
% this function loads and opens lsm files
%
%Input to this function is the specified directory path to the file. 
%
%Status 08.05.2014: function does not work yet. For fruther questions ask
%Marcus Leinweber.
%
%
%documented by DM - 08.05.2014

predata = bfopen(fname);
[r, c] = size(predata{1}{1});
dim = size(predata{1});
data = zeros(r,c,dim(1)); %, length(predata{1}));
for ind = 1:dim(1)
    data(:, :, ind) = predata{1}{ind};  
end
% data = predata{1}{1};
metadata = predata{2};
