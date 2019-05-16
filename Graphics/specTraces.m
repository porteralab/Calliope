function [h, data]=specTraces(data,varargin)
%[h, data]=specTraces(data,varargin)
% plots data traces out of an array on top of each other
% normalizes data to 0..1 first and downsamples data for fast presentation
% input:   data, your data matrix
% outputs: h, the figure
%          data, returns the normalized data
% optional parameter:
% 'plot'        [0,1] display plot. default=1.
% 'downsample'  [0,1] downsample data for faster display. default=0.
% 'legendNames' {..}  legend. Names for individual traces as cell array. 
% 'title'       'foobar' title for the plot.
% ML 30.10.2013
% doc edited by AF, 08.05.2014

p = inputParser;
if verLessThan('matlab','8.2')
    p.addParamValue('plot',1,@isnumeric)
    p.addParamValue('autotranspose',1,@isnumeric)
    p.addParamValue('downsample',0,@isnumeric)
    p.addParamValue('legendNames',{},@iscell)
    p.addParamValue('title',[],@ischar)
    p.parse(varargin{:})
else
    addRequired(p,'data',@isnumeric)
    addParameter(p,'plot',1,@isnumeric)
    addParameter(p,'autotranspose',1,@isnumeric)
    addParameter(p,'downsample',0,@isnumeric)
    addParameter(p,'legendNames',{},@iscell)
    addParameter(p,'title',[],@ischar)
    parse(p,data,varargin{:})
    data = p.Results.data;
end


dim = size(data);
if p.Results.autotranspose
    if dim(1) < dim(2)
        data = data';
        dim = size(data);
    end
end

minvalues = min(data);
maxvalues = max(data);
ranges = maxvalues - minvalues;

% normalize data
data = bsxfun(@minus,data,minvalues);
data = bsxfun(@rdivide,data,ranges);

% 'staple' data for plotting
data = bsxfun(@plus,data,(dim(2)-1)*1.1:-1.1:0');

if p.Results.plot
    h = figure;
    hold on
    if p.Results.downsample
        
        if dim(1) > 50000 && dim(1) <= 500000
            plot(data(1:10:end,:));
            xlim([1 dim(1)/10])
            set(gca,'XTickLabel',get(gca,'XTick')*10);
        elseif dim(1) > 500000
            plot(data(1:100:end,:));
            xlim([1 dim(1)/100]);
            set(gca,'XTickLabel',get(gca,'XTick')*100);
        else
            plot(data);
            xlim([1 dim(1)])
        end
    else
        plot(data);
        xlim([1 dim(1)])
    end
    if ~isempty(p.Results.legendNames)
        legend(p.Results.legendNames,'location','northeastoutside')
    end
    if ~isempty(p.Results.title)
        title(p.Results.title,'interpreter','none')
    end
    ylim([0 (dim(2))*1.1])
    set(gca,'YTick',[0.5:1.1:dim(2)*1.1+.5])
    set(gca,'YTickLabel',[dim(2):-1:1])
else
    h = [];
end
    