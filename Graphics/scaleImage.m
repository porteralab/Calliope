function output = scaleImage(data, minim, maxim)

% conversion form int16 to uint16 and scale to min/ max
% inputs:
%        data: your data matrix
%        minim: selected minimum. If none is specified, the minimum value of
%        the dataset is chosen.
%        maxim: selected maximum. If none is specified, the maximum value of
%        the dataset is chosen.

tic
if nargin < 2
    minim = single(min(data(:)));
%     minim = min(data(:));
end
if nargin < 3
    maxim = single(max(data(:)));
end

output = uint16(zeros(size(data)));
% toc
for i = 1:size(data,3)
   output(:,:,i) = ((single(data(:,:,i)) - minim) / (maxim - minim)) * 65536;
%    output(:,:,i) = data(:,:,i) - minim;
end
% toc
