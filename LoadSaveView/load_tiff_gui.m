function [data, image_info, template, fname]=load_tiff_gui(number_of_frames,data_path)
% loads a tiff stack via uigetfile and outputs as data and mean data
% (template)

if nargin<2
    data_path='';
end

[fname, fpath]=uigetfile([data_path '*.tif'],'multiselect','on');
 
% if multiple files are selected output one large data matrix
if iscell(fname)
    for knd=1:length(fname)
        image_info{knd}=imfinfo([fpath fname{knd}]);
        number_of_frames(knd)=length(image_info{knd});
    end
    number_of_frames_total=sum(number_of_frames);
    
    %initialize the data array
    data=zeros(image_info{1}(1).Height,image_info{1}(1).Width,number_of_frames_total,'uint16');
    cnt=0;
    for knd=1:length(fname)
        for ind=1:number_of_frames
            cnt=cnt+1;
            data(:,:,cnt)=uint16(imread([fpath fname{knd}],ind,'Info',image_info{knd}));
        end
    end
else
    
    image_info=imfinfo([fpath fname]);
    
    %by default read all frames
    if nargin<1 | number_of_frames==-1
        number_of_frames=length(image_info);
    end
    
    %initialize the data array
    data=zeros(image_info(1).Height,image_info(1).Width,number_of_frames,'uint16');
    
    for ind=1:number_of_frames
        data(:,:,ind)=uint16(imread([fpath fname],ind,'Info',image_info));
    end
end

if nargout>2
    % define template
    template=mean(data,3);
end
