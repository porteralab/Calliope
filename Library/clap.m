function clap
% clear all variables except proj_meta
% GK - 16.08.2015

all_vars=evalin('base','whos');

for ind=1:length(all_vars)
    if ~strcmp(all_vars(ind).name,'proj_meta');
        evalin('base',['clear ' all_vars(ind).name]);
    end
end

        