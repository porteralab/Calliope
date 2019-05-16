function [data]=load_tiff(fname)
% loads a tiff stack via uigetfile and outputs as data and mean data
% (template)

image_info=imfinfo([fname]);

%by default read all frames
number_of_frames=length(image_info);


%initialize the data array
data=zeros(image_info(1).Height,image_info(1).Width,number_of_frames,'uint16');

for ind=1:number_of_frames
    data(:,:,ind)=uint16(imread([fname],ind,'Info',image_info));
end

