exp_id=72600;
tdata=load_bin(['\\keller-rig2-2pi\tempData\S1-T' num2str(exp_id) '_ch525.bin']);
data={};
for knd=1:4
    data{knd}=tdata(:,:,knd:4:end);
end
aux_data=load_lvd(['\\keller-rig2-aux\tempData\S1-T' num2str(exp_id) '.lvd']);
[frame_times]=get_frame_times(aux_data(2,:));
if length(frame_times)>size(tdata,3)
    frame_times=frame_times(1:end-1);
end

for ii=1:4
ft=frame_times(ii:4:end);
tr=aux_data(7,ft);
 
p=double(squeeze(data{ii}(:,:,1:1000)));
 
tr=tr(1:1000);
 
d=manualCorr(p,tr);
figure
imagesc(d);set(gca,'clim',[-0.15 0.15]);colorbar
 
end
