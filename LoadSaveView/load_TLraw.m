function [data]=load_TLraw(fname,chan);

% LOAD_TLRAW Loads ThorimageLS RAW format files.
%	[data]=load_TLraw(fname,chan) loads ThorimageLS RAW format files from
%	channel "chan".
%
%   Depends on the Experiment xml file being in the same folder as the
%   image. TR2011

xmlpath = fileparts(fname);

[x_res y_res frames channels] = parseThorlabsXML(char([xmlpath '\Experiment.xml']));

finfo=dir(fname);
fi=fopen(fname,'r');

nbr_images = frames * channels;

data=zeros(x_res,y_res,frames,'int16');

for idx=1:frames
    if idx == 1;
        fseek(fi,y_res*x_res * (chan-1)*2,0);
    end
    data(:,:,idx)=reshape(fread(fi,y_res*x_res,'int16=>int16' ),y_res,x_res)';
    fseek(fi,y_res*x_res * (channels+1) ,0);
end

fclose(fi);
