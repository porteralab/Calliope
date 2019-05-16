function save_tiff_stack(data,filename)
% saves a tiff stack 

% make sure data is in uint16 format
data=uint16(data);

imwrite(data(:,:,1),filename,'tiff','writemode','overwrite','compression','none');
for ind=2:size(data,3)
    imwrite(data(:,:,ind),filename,'tiff','writemode','append','compression', 'none');
end



