function [data,nbr_frames]=load_bin(fnames,nbr_piezo_layers)
%Function loads .bin files.
%
% As an input argument use the exact directory path to the file.
% e.g. data=load_bin('\\servername\RawData\username\animalname\stackid.bin',4)
% The resulted variable can then be used in e.g. "view_stack" to look at 
% the raw imaging data.
%
% documented by DM - 08.05.2014

% finfo=dir(fname);
% fi=fopen(fname,'r');
% 
% x_res=fread(fi,1,'int16=>double');
% y_res=fread(fi,1,'int16=>double');
% nbr_images=round(finfo.bytes/x_res/y_res/2);
% 
% data=zeros(x_res,y_res,nbr_images,'int16');
% for ind=1:size(data,3)
%     data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
% end
% 
% fclose(fi);

if nargin == 1
    nbr_piezo_layers=1;
end
if isa(fnames,'char')
    fnames={fnames};
end

% load the 2P data
% pre-allocate space for data
for knd=1:length(fnames)
    finfo=dir([fnames{knd}]);
    fi=fopen([fnames{knd}],'r');
    x_res=fread(fi,1,'int16=>double');
    y_res=fread(fi,1,'int16=>double');
    nbr_frames(knd)=round(finfo.bytes/x_res/y_res/2);
    nbr_frames(knd)=nbr_frames(knd)-rem(nbr_frames(knd),nbr_piezo_layers);
    fclose(fi);
end
number_of_frames_total=sum(nbr_frames);
if nbr_piezo_layers>1
    data=cell(1,nbr_piezo_layers);
    for knd=1:nbr_piezo_layers
        data{knd}=zeros(x_res,y_res,round(number_of_frames_total/4),'int16');
    end
else
    data=zeros(x_res,y_res,number_of_frames_total,'int16');
end

% load the data
for ind=1:length(fnames)
    if exist([fnames{ind}],'file');
        disp(['loading file ' fnames{ind} ' from data directory']);
        curr_load_path=[fnames{ind}];
    end
    
    fi=fopen(curr_load_path,'r');
    x_res=fread(fi,1,'int16=>double');
    y_res=fread(fi,1,'int16=>double');
    
    if nbr_piezo_layers>1
        for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
            data{rem(knd-1,nbr_piezo_layers)+1}(:,:,floor((knd-1)/nbr_piezo_layers)+1)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
        end
    else
        for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
            data(:,:,knd)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
        end
    end
    fclose(fi);
end