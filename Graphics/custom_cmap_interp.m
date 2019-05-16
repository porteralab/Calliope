function cmap = custom_cmap_interp(lowcolor,midcolor,highcolor,nColors)
%cmap = custom_cmap_interp(lowcolor,midcolor,highcolor,nColors)
%
% Generates a custom colormap interpolating 3 colors (left edge to middle
% to right edge). nColors specifies the number of colors (default=256).
% ML

if nargin < 1
    lowcolor = [0 0 1]; %blue
    midcolor = [1 1 1]; %white
    highcolor = [1 0 0];%red
end
if nargin < 4
    nColors = 256; % number of colors for the resulting map
end

cmap = zeros(nColors, 3 ); % pre-allocate
xi = linspace(0, 1, nColors);
for ci = 1:3 % for each channel
    cmap(:,ci) = interp1( [0 .5 1], [lowcolor(ci) midcolor(ci) highcolor(ci)], xi )';
end