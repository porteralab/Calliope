function [binned_act]=act2bin(act,pos,nbins)
% bins activity in act to a second variable, typically space
% GK - 14.10.2014

if nargin<3
    nbins=100;
end

max_pos=max(pos);
min_pos=min(pos);

bin_size=(max_pos-min_pos)/nbins;

for ind=1:nbins
    binned_act(:,ind)=mean(act(:,pos>bin_size*(ind-1)&pos<bin_size*ind),2);
end




