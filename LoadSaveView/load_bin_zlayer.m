function [data,nbr_frames]=load_bin_zlayer(fnames,nbr_piezo_layers,z_layer,applyreg)
% loads .bin files per-zlayer, based on load_bin function
% can attempt to apply registration (optional)
%
% usage (to load z-layer 1/4):
% data=load_bin_zlayer('\\servername\RawData\username\animalname\stackid.bin',4,1);
% data=load_bin_zlayer(getfield(read_info_from_ExpLog(12345),'fnames'),4,1,1);
%
% FW 04.04.2018

if nargin==0 && ishandle(1001)
    warning('Loading ExpID (%i) from open calliope window.\n',calliope_getCurStack);
    fnames=calliope_getCurStack;
end

if ~exist('applyreg','var'), applyreg=input('load registered data? [0|1]: '); end
if ~exist('z_layer','var'), z_layer=input('specify z-layer: '); end

if isnumeric(fnames)
    ExpLog=getExpLog;
    expid=ExpLog.expid{[ExpLog.stackid{:}]==fnames};
    [data_path,ExpIDinfo]=get_data_path(expid);
    fnames=[data_path ExpIDinfo.userID '\' ExpIDinfo.mouse_id  '\' 'S1-T' num2str(fnames) '_' ExpIDinfo.main_channel '.bin'];
end

if applyreg %load whole exp
    warning('loading the whole experiment...');
    ExpLog=getExpLog;
    if isnumeric(expid)
        expid=ExpLog.expid{[ExpLog.stackid{:}]==expid};
        fnames=getfield(read_info_from_ExpLog(expid),'fnames');
    end
end

if nargin == 1 || ~exist('nbr_piezo_layers','var')
    nbr_piezo_layers=4;
    warning('assuming 4 piezo layers.');
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
data=zeros(x_res,y_res,number_of_frames_total/nbr_piezo_layers,'int16');

% load the data
frames=[0 cumsum(nbr_frames(1:end))/nbr_piezo_layers];
for f=1:length(fnames)
    if exist([fnames{f}],'file');
        disp(['loading file ' fnames{f} ' from data directory']);
        curr_load_path=[fnames{f}];
    end
    data(:,:,frames(f)+1:frames(f+1))=load_zlayer(fnames{f},z_layer);
end

if exist('applyreg','var') && applyreg==1
    data=apply_registration(data,fnames{1},z_layer);
end
if nargout==0
   disp('NC: assigning ''data'' variable in ''base'' workspace');
end
end

function  [data,nbr_images]=load_zlayer(fname,z_layer)
finfo=dir(fname);
fi=fopen(fname,'r');

x_res=fread(fi,1,'int16=>double');
y_res=fread(fi,1,'int16=>double');
nbr_images=round(finfo.bytes/x_res/y_res/2);

if z_layer>1
    for ind=1:z_layer-1
        fseek(fi,x_res*y_res*2,'cof');
    end
end

data=zeros(x_res,y_res,nbr_images/4,'int16');
for ind=1:size(data,3)
    data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
    fseek(fi,x_res*y_res*2*3,'cof');
end
fclose(fi);
end

function [data]=apply_registration(data,fname,z_layer)
ExpID=str2double(regexpi(fname,'(?<=S1-T)\d*(?=.\w\w\w)','match'));
adata_dir=set_lab_paths;
[adata_file,mouse_id,userID,projID]=get_adata_filename(ExpID,adata_dir,getExpLog);
try
    load([adata_dir '\' userID '\' mouse_id '\' adata_file],'dx','dy');
catch me
    error('Couldn''t load registration from Adata file: %s',me.message);
end
disp(['Now registering data on dx dy values and correcting line shift']);
data=shift_data(data,dx{z_layer},dy{z_layer});
data=correct_line_shift(data,mean(data,3));
end