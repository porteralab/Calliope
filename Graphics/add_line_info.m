function add_line_info(varargin)
% adds information to lines (i.e. hoverover/datapoint marker tool/tooltip)
% for convenience.
%
% examples:
% add_line_info({'test',1},{'test_line2',2}); %adds info to two lines
% add_line_info({'del'},{'test_line2',2}) %deletes first line-info
% if less arguments than lines provided, labelling the last one
%
% requires Matlab >2019a
% 2019 FW

%check matlab version
if verLessThan('matlab','9.6.0'), error('please upgrade Matlab to >2019a to use this function'); end
% if numel(varargin)==1 && isa(varargin{1},'cell'), varargin=[varargin{:}]; end
linez=findall(gcf,'type','line');
if isempty(linez), linez=findall(gcf,'type','errorbar'); end
if isempty(linez), error('couldn''t detect any lines or errorbars to add info to!'); end
for l=1:numel(linez)
    if l>numel(varargin),continue; end
    if any(cell2mat(cellfun(@(x) regexpi(num2str(x),'del','once')~=0,varargin{l},'uni',0))), linez(l).DataTipTemplate.DataTipRows(3:end)=[]; continue; end
    if mod(numel(varargin{l}),2)~=0 || isempty(varargin{l}), continue; end
    nPts=numel(linez(1).XData);
    for arg=1:2:numel(varargin{l})
        name=varargin{l}{arg};
        val =varargin{l}{arg+1};
        if isnumeric(val)
            linez(l).DataTipTemplate.DataTipRows(end+1) = dataTipTextRow([name ':'], repmat(val,nPts,1));
        else
            linez(l).DataTipTemplate.DataTipRows(end+1) = dataTipTextRow([name ':'], repmat(string(val),nPts(1),1) );
        end
        linez(l).DataTipTemplate.Interpreter='none';
    end
end
end