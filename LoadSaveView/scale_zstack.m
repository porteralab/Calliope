function mean_data=scale_zstack(mean_data)


for ind=1:size(mean_data,3)
    tmp=mean_data(:,:,ind);
    p05=prctile(tmp(:),5);
    p95=prctile(tmp(:),95);
    mean_data(:,:,ind)=(mean_data(:,:,ind)-p05)/(p95-p05);
end
