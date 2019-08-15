function find_stim_resp_cells(siteID)

evalin('base','clear raw_traces')
ad=checkAux(siteID);
data=show_last_stack(siteID);

close all

[dx,dy]=register_frames(data(:,1:750,:),mean(data(:,1:750,10:20),3));

data=shift_data(data,dx,dy);

ft=get_frame_times(ad(2,:));
trigs = find(diff(ad(6,ft)>0.5)==1);

trigs=floor(trigs/4);

trigs(trigs<25)=[];
trigs(trigs>size(data,3)-25)=[];


bl_fr=bsxfun(@plus,trigs,[-25:-5]');
st_fr=bsxfun(@plus,trigs,[5:25]');

view_stack(data)

stim_trig_avg=mean(data(:,:,reshape(st_fr,prod(size(st_fr)),1)),3)-  mean(data(:,:,reshape(bl_fr,prod(size(bl_fr)),1)),3);

figure;imagesc(stim_trig_avg)
set(gca,'clim',[0 30])
colormap gray
axis off
set(gca,'position',[0 0 1 1])
set(gcf,'position', [207         652        1818         318])
assignin('base','ad',ad)
assignin('base','data',data)