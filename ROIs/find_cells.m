function [ROIs,np]=find_cells(template,vis_output_on)
% this function automatically finds cells in image based on local intensity
% threshold, lightest objects are classified as cells

if nargin<2
    vis_output_on=0;
end

min_num_pix_per_cell=250;
win_size = round(min(size(template))/50);

local_average = filter2(ones(win_size)/win_size^2,template);
t_fil = template./local_average;
t_fil = t_fil(win_size+1:end-win_size, win_size+1:end-win_size);

 figure;imagesc(t_fil)
 
t_mask=zeros(size(t_fil));
t_mask(t_fil>median(t_fil(:))+0.2*std(t_fil(:)))=1;
%t_mask = imfill(t_mask,'holes');
t_mask = imopen(t_mask, strel('disk',1));
t_mask = bwareaopen(t_mask, min_num_pix_per_cell);
t_labels=zeros(size(template));
t_labels(win_size+1:end-win_size, win_size+1:end-win_size) = bwlabel(t_mask);


np.indices=find(~t_mask);

% for ind=1:max(t_labels(:))
%     ROIs(ind).indices = find(t_labels==ind);
% end


if vis_output_on
    template = template(win_size+1:end-win_size, win_size+1:end-win_size);
    max_cont=mean(template(:))+2*std(template(:));
    min_cont=mean(template(:))-2*std(template(:));
    
    figure('menubar','none');
    axes('position',[0 0 1 1]);
    tmp=(template-min_cont)/(max_cont-min_cont);
    tmp(tmp>1)=1;
    tmp(tmp<0)=0;
    overlay(:,:,1)=tmp;
    overlay(:,:,2)=bwperim(t_mask);
    overlay(:,:,3)=zeros(size(t_mask));
    imagesc(overlay)
    hold on
    
%     for ind=1:length(ROIs)
%         [txt_x,txt_y]=ind2sub(size(local_average),min(ROIs(ind).indices));
%         text(txt_y-win_size,txt_x-win_size,num2str(ind),'color','w')
%     end
        
    
    
    box off
    axis off
end
