function y=find_segments(x,lookfor)
% finds segments of specified number in 1D vector and outputs:
% indices (1st column) and sequence length (2nd column). 
% Second argument searches for other numbers than default (1). 
%
% x=[1 0 0 1 1 1 1];
% find_segments(x);
%
% ans=
%      1     1
%      4     4
%
% FW 2018

if ~exist('lookfor','var') || isempty(lookfor), lookfor=1; end 
lookfor=lookfor+min(min(x))+1; %workaround to make it work with '0'
x=x+min(min(x))+1;
x=padarray(x,[0 1],0); %pad input sequence to get first/last indices

y=[find(diff(ismember(x,lookfor),[],2)==1);...      %1) search for indices
   find(diff(ismember(x,lookfor),[],2)==-1) - ...   %2) get length of sequences
   find(diff(ismember(x,lookfor),[],2)==1)]';
end
