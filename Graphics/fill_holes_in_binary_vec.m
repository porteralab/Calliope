function [out]=fill_holes_in_binary_vec(in,win)

% correct errors in a binary (only 0's and 1's) vector by setting them to 0
% ------------------------------------------------------------------------
% inputs:
%         in: your input vector
%         win: window to exclude e.g. win = 20, exclude first 20 and last
%         20 elements from correction
% doc edited by AF, 08.05.2014

out=in;
for ind=win+1:length(in)-win
    if abs(mean(in(ind-win:ind-1))-in(ind))>0.5 && abs(mean(in(ind+1:ind+win))-in(ind))>0.5
        out(ind)=~in(ind);
    end
end