function y = nanSEM(x,dim)
% calculates the standard error of the mean 
%-------------------------------------------------------------------------
% input "dim" specifies the dimension of the input matrix giving the 
% n number for the experiment 
% SEM =(standard deviation / sqrt(n)
% if no dimension is specified, the first non-singleton (different than one)
% dimension will be used
% doc edited by AF, 08.05.2014

if nargin==1, 
  % Determine which dimension SEM will use
  dim = find(size(x)~=1, 1 );
  if isempty(dim), dim = 1; end

  y = nanstd(x)/sqrt(size(x,dim));
else
  y = nanstd(x,0,dim)/sqrt(size(x,dim));
end