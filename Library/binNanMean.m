function [out,grps]=binNanMean(data,group,ngrps)

grps=unique(group);

if nargin<3
    out=nan(size(data,1),length(grps));
else
    out=nan(size(data,1),length(unique(group)));
end

for ind=1:length(grps)
    out(:,ind)=nanmean(data(:,group==ind),2);
end
    
    