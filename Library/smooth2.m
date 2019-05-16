function [fdata]=smooth2(data,windowSize,dim)
% smooths data by calculating a running average of specified window size
% ------------------------------------------------------------------------
% inputs: data - your vector
%         windowSize - the window over which to take the running average
% outputs:
%         fdata: your smoothed vector
% doc edited by AF, 08.05.2014
if nargin<3
    [M,I]=min(size(data));
    if I == 2
        dim = 1;
    else
        dim = 2;
    end
end

if dim == 1
    data = data';
end
data=[data(:,1)*ones(1,ceil(windowSize/2)) data data(:,end)*ones(1,floor(windowSize/2))];
for ind = 1:size(data,1)
    fdata(ind,:)=filter(ones(1,windowSize)/windowSize,1,data(ind,:));
end
fdata = fdata(:,windowSize+1:end);
if dim == 1
    fdata = fdata';
end







