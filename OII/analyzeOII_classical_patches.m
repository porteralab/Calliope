
% path = 'F:\RawData\leinmarc';
% animal = 'PZ_121010_21';
path = '\\KELLER-RIG1-AUX\tempData';
animal = [];
stackID = 'S1-T19328';
ext = '.vid';
ext2 = '.lvd';
patches = [3 6];
stim_ch = 3;

% load video data
[vdata, vmeta_info]=load_vid_data(fullfile(path,animal,[stackID ext]),'int16');
% load stim id data and process it
data=load_lvd(fullfile(path,animal,[stackID ext2]));
[~,~,stim_cond] = unique(round(data(stim_ch,:)*10));
nn = hist(stim_cond,length(unique(stim_cond)));
wrongstimconds = find(nn < 20);
for ind = 1:length(wrongstimconds)
    stim_cond(stim_cond == wrongstimconds(ind)) = 1;
    stim_cond(stim_cond > wrongstimconds(ind)) = stim_cond(stim_cond > wrongstimconds(ind)) - 1;
    wrongstimconds = wrongstimconds - 1;
end
stim_cond = stim_cond - 1;
% figure;plot(stim_cond)

frame_times=vmeta_info(1,:);
% figure;plot(frame_times)
frame_times(1)=1;
frame_id=stim_cond(frame_times);

% determine last stim id
lastStimID = unique(frame_id,'stable');
lastStimID = lastStimID(end);
repseq = strfind(frame_id',[ lastStimID 0]);
if frame_id(end) == lastStimID
    repseq = [0 repseq length(frame_id)];
else
    repseq = [0 repseq];
end
frame_id_reps = zeros(size(frame_id));
for ind = 1:length(repseq)-1
   frame_id_reps(repseq(ind)+1:repseq(ind+1)) = ind; 
end

condimg = zeros(size(vdata,1),size(vdata,2),prod(patches));
bkg = mean(vdata(:,:,frame_id==0),3);
for ind = 1:prod(patches)
    clear aa3
    for jnd = 1:max(frame_id_reps)
        aa = intersect(find(frame_id == ind), find(frame_id_reps==jnd));
        aa1= fliplr(mean(vdata(:,:,aa(1)-4:aa(1)),3)); % first four frame correction
        aa2= fliplr(mean(vdata(:,:,aa),3));
        aa3(:,:,jnd)= aa2-aa1;
    end
    
    % %     temp = mean(vdata(:,:,frame_id==ind),3);
    % %     temp(temp < prctile(temp(:),1.5)) = min(temp(:));
    condimg(:,:,ind) = sum(aa3,3); 
    % condimg(:,:,ind) = fliplr(temp-bkg);
end

pixel_in_x = size(vdata,2);
fov_in_um = 200;
lowpass = 2;
lowpass_pix = lowpass * pixel_in_x / fov_in_um;
kernel_size = ceil(lowpass_pix * 5);
sp_filter = fspecial('gaussian', kernel_size, lowpass_pix); 
condimg_f = zeros(size(vdata,1),size(vdata,2),prod(patches));
for ind = 1:prod(patches)
    condimg_f(:,:,ind) = Filter2Modified(sp_filter, condimg(:,:,ind)-mean(condimg(:))); % Here was the main bug 
end



figure
montage(permute(condimg_f,[1, 2, 4, 3]), 'Size', patches)
 set(gca,'clim',[min(condimg_f(:))*0.6 max(condimg_f(:))])

figure
montage(permute(condimg,[1, 2, 4, 3]), 'Size', patches)
 set(gca,'clim',[min(condimg(:))*.4 max(condimg(:))*0.2])



% 
% figure;imagesc(mean(vdata(:,:,frame_id==2),3)-mean(vdata(:,:,frame_id<0),3));
% colormap gray
% set(gca,'clim',[-0.4 0.15])
% set(gca,'clim',[-0.5 0.15])
% set(gca,'clim',[-0.4 0.05])
% set(gca,'clim',[-0.4 0.25])
% figure;imagesc(mean(vdata(:,:,frame_id==3),3)-mean(vdata(:,:,frame_id<0),3));
% colormap gray
% set(gca,'clim',[-0.4 0.25])