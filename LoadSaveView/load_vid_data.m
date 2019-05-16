function [vdata, vmeta_info] = load_vid_data(file_name,format)


if nargin < 1
    disp('usage: load_vid_data(file_name[, file_format])');
    return;
end
if nargin < 2
    format = 'int16';
end

meta_info_size=4;

little_endian=1;

%% try to open file, otherwise quit
[fi, message] = fopen(file_name, 'r', 'ieee-le');
if fi == -1
    error(['There was a problem reading the following file:' char(13) file_name char(13) message]);
    return
end
meta_info = fread(fi, meta_info_size, 'double');
size_y=meta_info(3);
size_x=meta_info(4);

if rem(size_y,1)>0 || rem(size_x,1)>0
    disp('NC Warning: File format is little endian -- this is probably an old file type');
    little_endian=0;
    fclose(fi);
    [fi, message] = fopen(file_name, 'r', 'ieee-be');
    meta_info = fread(fi, meta_info_size, 'double');
    size_y=meta_info(3);
    size_x=meta_info(4);
end

if size_x==0|size_y==0
    size_x=1024;
    size_y=1344;
end

fseek(fi, 0, 'eof');
file_size = ftell(fi);
fclose(fi);

%% open the file again - this time to read in the data
if little_endian
    fi = fopen(file_name, 'r', 'ieee-le');
else
    fi = fopen(file_name, 'r', 'ieee-be');
end

%% get all header information
% double = 8 bytes, uint8 = 1 byte
nbr_frames=floor((file_size)/(size_x*size_y*2+meta_info_size*8));

vdata=zeros(size_x,size_y,nbr_frames,format);
vmeta_info=zeros(meta_info_size,nbr_frames);
if strcmp(format,'int16')
    for ind=1:nbr_frames
        vmeta_info(:,ind) = fread(fi, meta_info_size, 'double');
        vdata(1:size_x,1:size_y,ind)=reshape(fread(fi,size_x*size_y,'int16=>int16'),size_y,size_x)';
    end
else
    for ind=1:nbr_frames
        vmeta_info(:,ind) = fread(fi, meta_info_size, 'double');
        vdata(:,:,ind)=reshape(fread(fi,size_x*size_y,'int8=>int8'),size_y,size_x)';
    end
end


%% read in the data

fclose(fi);


%% EOF
