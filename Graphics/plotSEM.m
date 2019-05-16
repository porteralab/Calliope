function h = plotSEM(data, varargin)
%plotSEM(data,varargin)
% Plot your vector accompanied by sexy SEM (Standard Error of the Mean) shading, also
% for use with vectors containing NaN's
%
% data: your original 2D matrix, where rows are measurements and columns
% are trials
% varargin passes over parameters to plot function except 
% 'sh_color' - shading color (default: 0.9 0.9 0.9)
% 'trns'     - transparency for SEM shading (default: 1)
% 
% e.g.
% plotSEM(data,'Color',[1 0 0],'LineWidth',2,'LineStyle',':');
% plotSEM(data,'Color',[1 0 0],'sh_color',[0.5 0.5 0.5],'trns',0.2);
% 
%--------------------------------------------------------------------------
% Requires NaN Suite (free to download at
% http://www.mathworks.com/matlabcentral/fileexchange/6837-nan-suite)
% !!!!!!-----ACHTUNG-----!!!!!!!!
% If you want to export to .eps, do not use a transparency setting other
% than trns = 1, because that makes Adobe Illustrator unhappy
%
% ML: rewritten Aris initial function to be more flexible with plotting
% parameters

% parsing the arguments
parserObj = inputParser;
parserObj.KeepUnmatched = true;
parserObj.addParamValue('sh_color',[0.9 0.9 0.9],@isnumeric); % shading color
parserObj.addParamValue('trns',1,@isnumeric); % transparency
parserObj.addOptional('LineSpec','-',@(x) ischar(x) && (numel(x) <= 4));
%# and some more of your special arguments

parserObj.parse(varargin{:});

%# your inputs are in Results
myArguments = parserObj.Results;

%# plot's arguments are unmatched
plotArgs = struct2pv(parserObj.Unmatched);
% done parsing input arguments

% calculate SEM
stderror = nan_sem(data,2);

x_label = [1:size(data,1) fliplr(1:size(data,1))];


hold on;
dtpl = [(nanmean(data,2)'+stderror') fliplr(nanmean(data,2)'-stderror')];
% plot SEM
patch(x_label,dtpl,myArguments.sh_color,'LineStyle','none'); 
alpha(myArguments.trns)
% plot mean data 
plot(nanmean(data,2),myArguments.LineSpec,plotArgs{:})

% group patches to not be considered for the legend
% and reorder data that SEM is in the background (for multiple plots))
temp = get(gca,'Children');
h1Group = hggroup;
set(findobj(temp,'type','patch'),'Parent',h1Group)
set(get(get(h1Group,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
temp = get(gca,'Children');
set(gca,'Children',flipud(temp));

hold off;
shg;

end


function [pv_list, pv_array] = struct2pv(s)
p = fieldnames(s);
v = struct2cell(s);
pv_array = [p, v];
pv_list = reshape(pv_array', [],1)';
end
