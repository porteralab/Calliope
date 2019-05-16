function [data]=load_bin_partial(fname,n_frames)
%Function loads .bin files paritally.
%
%As an input argument use the exact directory path to the file and the
%number of frames you want to load.
%e.g.: data1=load_bin(\\keller-rig1-ana\RawData\mahrdavi\DM_140401_2\S1-T25777_ch610,1000)
%The .bin file can the be loaded in e.g. "view_stack" to look at the raw imaging data.
%
%
%documented by DM - 08.05.2014

finfo=dir(fname);
fi=fopen(fname,'r');

x_res=fread(fi,1,'int16=>double');
y_res=fread(fi,1,'int16=>double');
nbr_images=round(finfo.bytes/x_res/y_res/2);

if n_frames>nbr_images
    n_frames=nbr_images;
end

data=zeros(x_res,y_res,n_frames,'int16');
for ind=1:size(data,3)
    data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
end

fclose(fi);

 