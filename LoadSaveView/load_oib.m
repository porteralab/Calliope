function data = load_oib(fname)
% this function loads and opens olympus files and takes out the frames 
% and puts them in a variable with a suitable format for the rest 
% of manipulations

predata = bfopen(fname);
[r c] = size(predata{1}{1,1});
data = zeros(r, c, length(predata{1}));
for ind = 1:length(predata{1})
    data(:, :, ind) = predata{1}{ind,1};  
end
