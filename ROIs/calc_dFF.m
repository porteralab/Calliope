function [dF] = calc_dFF(F)
% calculates dF/F and smoothes the fluorescence trace F

if sum(size(F)>1) == 2  %for matrices, assumes that F is longer than no of ROIs
    if size(F,1) < size(F,2)
        dF = bsxfun(@rdivide,F,mean(F,2));
    else
        dF = bsxfun(@rdivide,F,mean(F));
    end
else
    dF=F/mean(F);
end
%dF=psmooth(dF);
