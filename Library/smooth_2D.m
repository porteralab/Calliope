function out = smooth_2D(data,windowSize);
% Smooth each column in your input vector
% AF, 02.09.2015
out = filter(ones(1,windowSize)/windowSize,1,data);

end