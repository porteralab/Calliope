function [ROIs]=rotate_ROIs(ROIs,rot_angle,im_size)

for ind=1:length(ROIs)
    tmp=zeros(im_size);
    tmp(ROIs(ind).indices)=1;
    tmp=imresize(tmp,[1 1]*max(im_size),'nearest');
    tmp=imrotate(tmp,rot_angle,'crop');
    tmp=imresize(tmp,im_size,'nearest');
    ROIs(ind).indices=find(tmp);
end