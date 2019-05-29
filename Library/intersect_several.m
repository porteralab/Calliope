function [varargout] = intersect_several(varargin)
% intersects multiple comma-separated variables
%
% examples:
% intersect_several(1:10,1:20,10:30)
% intersect_several({'a'},{'a','b','c'},{'a','c'})
% intersect_several('a','abc','ac')
%
% 2019 FW

varargout=varargin{1};
for ind=2:numel(varargin)-1
    varargout=intersect(varargout,varargin{ind+1});
end
if ~isa(varargout,'cell'), varargout={varargout}; end

end