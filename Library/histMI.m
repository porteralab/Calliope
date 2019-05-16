function MI = histMI(a,b,nbins)
% compute Mutual Information of two continuous random variables using a
% histogram based estimation of the PDFs
%
% GK 02.22.2015


a=ntzo(a(:));
b=ntzo(b(:));

ctrs{1}=[0:1/nbins:1];
ctrs{2}=[0:1/nbins:1];

Pab=hist3([a b],ctrs)/length(a);

Pa=log(sum(Pab,1));
Pb=log(sum(Pab,2));

MI=nansum(nansum(Pab.*bsxfun(@minus,bsxfun(@minus,log(Pab),Pa),Pb)));

