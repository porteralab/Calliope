function stack = build_rgb_stack(red,green,blue,norm)
%stack = build_rgb_stack(red,green,blue,ntzo)
% build RGB stack from single channels
% empty input channels [] will be filled with zeros
% input ntzo specifies whether data should be normalized to 0..1
%
% 2014 ML
if nargin < 4
    norm = 1;
end

if ~(isempty(red) || isempty(green))
    if any(size(red) ~= size(green))
        error('Single channels have different dimensions and but are not empty.')
    end
end
if ~(isempty(green) || isempty(blue))
    if any(size(green) ~= size(blue))
        error('Single channels have different dimensions and but are not empty.')
    end
end

stack = single(zeros([size(red,1) size(red,2) 3 size(red,3)]));

if ~isempty(red)
    if norm
        red = ntzo(red);
    end
    stack(:,:,1,:) = red;
end


if ~isempty(red)
    if norm
        green = ntzo(green);
    end
    stack(:,:,2,:) = green;
end


if ~isempty(blue)
    if norm
        blue = ntzo(blue);
    end
    stack(:,:,3,:) = blue;
end