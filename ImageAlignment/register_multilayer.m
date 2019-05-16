function [mean_data,dx_corr,dy_corr]=register_multilayer(data,nbr_frames_per_layer)

nbr_layers=size(data,3)/nbr_frames_per_layer;


if floor(nbr_layers)~=nbr_layers
    disp('hmmmmm.... premature stopping??? you know what that feels like? riiiight???')
    nbr_layers=floor(nbr_layers);
    data=data(:,:,1:nbr_layers*nbr_frames_per_layer);
end


for ind=1:nbr_layers 
    current_frames=data(:,:,(ind-1)*nbr_frames_per_layer+1:ind*nbr_frames_per_layer);
    current_frames=correct_line_shift(current_frames);
    [dx,dy]=register_frames(current_frames,mean(current_frames(:,:,1:5),3));
    dx=round(dx-mean(dx)/2);
    dy=round(dy-mean(dy)/2);
    
    [tmp]=shift_data(current_frames,dx,dy);
    good_data_ind=abs(dx-mean(dx))<25&abs(dy-mean(dy))<25;
    if sum(good_data_ind)>25
        mean_data(:,:,ind)=mean(tmp(:,:,good_data_ind),3);
    else
        mean_data(:,:,ind)=mean(current_frames,3);
    end

end

nbr_layers_mean=size(mean_data,3);
dx=[];
dy=[];

for ind=2:nbr_layers_mean
    [dx(ind),dy(ind)]=register_frames(mean_data(:,:,ind),mean_data(:,:,ind-1));
    if abs(dx(ind))>10 | abs(dy(ind))>10
        [dx_tmp,dy_tmp]=fix_registration(mean_data(:,:,ind-1:ind),mean_data(:,:,ind-1),dx(ind-1:ind),dy(ind-1:ind));
        dx(ind)=dx_tmp(2);
        dy(ind)=dy_tmp(2);
    end
end
endpoint=0.5;
corr_range=round([0.1 0.6]*nbr_layers_mean);
dx_cs=cumsum(dx);
dy_cs=cumsum(dy);

dx_corr=dx_cs-(polyval(polyfit([corr_range(1):corr_range(2)],dx_cs(corr_range(1):corr_range(2)),1),[1:nbr_layers_mean]));
dy_corr=dy_cs-(polyval(polyfit([corr_range(1):corr_range(2)],dy_cs(corr_range(1):corr_range(2)),1),[1:nbr_layers_mean]));

mean_data=shift_data(mean_data,dx_corr,dy_corr);

