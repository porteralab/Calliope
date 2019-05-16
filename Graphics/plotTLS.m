function [fig,b]=plotTLS(xx,yy,varargin)
%[fig,b]=plotTLS(xx,yy,varargin)
% Calculate total least square regression and confidence intervals
% fig    : figure handle
% b      : intercept and slope
% xx     : x values
% yy     : y values

parserObj = inputParser;
parserObj.KeepUnmatched = true;
parserObj.addParameter('sh_color',[0.9 0.9 0.9],@isnumeric); % shading color
parserObj.addParameter('alpha',0.05,@isnumeric); % p-value CI
parserObj.addParameter('trns',1,@isnumeric); % transparency
parserObj.addParameter('plotXY',1,@isnumeric);
parserObj.addParameter('xlim',[],@isnumeric);
parserObj.addParameter('reflinePlotOptions',struct(),@isstruct);
parserObj.addOptional('LineSpec','-',@(x) ischar(x) && (numel(x) <= 4));
parserObj.parse(varargin{:});

%# your inputs are in Results
args = parserObj.Results;
%# plot's arguments are unmatched
plotArgs = struct2pv(parserObj.Unmatched);

if size(xx,1)
    xx=xx';
    yy=yy';
end
[ b, ~, ~, ~, ~]  = deming(xx, yy);
if isempty(args.xlim)
    xmin = min(xx)*1.1;
    xmax = max(yy)*1.1;
else
    xmin = args.xlim(1);
    xmax = args.xlim(2);
end
xx2 = [xmin:range([xmin xmax])/100:xmax];

% jackknife
alpha = 0.05;
n = length(yy);
y_sub = zeros(size(xx2,2),n);
ignoreFlag = [false; true(n-1,1)];
for nn = 1:n
    b_sub = deming(xx(circshift(ignoreFlag,nn)),yy(circshift(ignoreFlag,nn)),1);
    y_sub(:,nn) = b_sub(2)*xx2+b_sub(1);
end

%Critical t-value used for confidence intervals
t_c = tinv(1-alpha/2,n-2);

SEM_sub = (std(y_sub,[],2)*(n-1)/sqrt(n))';

y_reg = b(2)*xx2 + b(1);
y_CI(1,:) = y_reg + t_c.*SEM_sub;
y_CI(2,:) = y_reg - t_c.*SEM_sub;

%plot
fig=figure;
hold on
% CII
h1=patch([xx2 fliplr(xx2) ],[y_CI(1,:) fliplr(y_CI(2,:))],args.sh_color,'LineStyle','none');
set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
if args.plotXY %% values
    plot(xx,yy,'o','LineStyle','None',plotArgs{:})
end
% regression line
h2=plot(xx2,y_reg,'k-',args.reflinePlotOptions);
set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

xlim([xmin xmax])
ylim([min(yy)*1.1 max(yy)*1.1])
set(gca ,'Layer', 'Top')
shg;
end


function [pv_list, pv_array] = struct2pv(s)
p = fieldnames(s);
v = struct2cell(s);
pv_array = [p, v];
pv_list = reshape(pv_array', [],1)';
end