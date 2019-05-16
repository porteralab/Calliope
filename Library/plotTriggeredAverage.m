function snps=plotTriggeredAverage(data,trigs,win)
% function HaHaHa (credits to PZ)


if nargin<3
    win=[100 100];
end


trigs(trigs<win(1)+1)=[];
trigs(trigs>size(data,2)-win(2)-1)=[];

snps=[];

for ind=1:length(trigs)
    snps(:,ind)=mean(data(:,trigs(ind)-win(1):trigs(ind)+win(2)),1);
end

ms=mean(snps,2);

if nargout==0
    figure;
    plot(ms)
    hold on
    plot([1 1]*win(1),[min(ms) max(ms)]);
    axis tight
end
