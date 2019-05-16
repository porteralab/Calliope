function [data] = remove_stimleak(data)
% HEURISTIC CORRECTION - DO NOT USE IF YOU DON'T KNOW WHAT YOU ARE DOING
% assumes that stim leak is additive and constont over one row of the
% image.
% substracts the mean of each row from every row of the matrix and adds the
% template to image
% documented BW - 09.05.2014


mdata=mean(data,3);

for ind=1:size(data,3)
    data(:,:,ind)=uint16(data(:,:,ind)-mean(data(:,:,ind),2)*ones(1,size(mdata,2))+mdata);
end