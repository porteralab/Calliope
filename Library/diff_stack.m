function [data]=diff_stack(data,template)

% takes the difference of a stack frame from the template (mean) image
% ------------------------------------------------------------------------
% inputs:
%        data: your stack
%        template: the average stack or template you want to use as a
%        baseline. If none is specified, the mean of the stack will be
%        used.
% doc edited by AF, 08.05.2014

if nargin<2
    template=mean(data,3);
end


for ind=2:size(data,3)
    data(:,:,ind)=data(:,:,ind)-mean(mean(data(:,:,ind)));
end
template=mean(data,3);

for ind=2:size(data,3)
    data(:,:,ind)=data(:,:,ind)-template;
end
data(:,:,1)=data(:,:,2);