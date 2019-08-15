function varargout=show_last_stack(exp,varargin)
% show_last_stack loads .bin file and displays raw 2P imaging data in a
% movie.
%
% Loads the last stack found in imaging temp directory or stack specified by ID
%
% OPTIONAL inputs:
% ch_combined (default=1) - combine channels for two channel data (needs stackID)
% splitdata (default=1)   - splitdata if multilayer stack
% calcMM (default=0)      - plot mismatch response based on full-frame
%                           averaged signal. Only works with single channel
%                           and splitdata
% reg (default=1)         - load/show registered first/last 10% of first z-layer
% zl (default=1)          - load/show first/last 10% of first z-layer

%e.g.: show_last_stack();
%e.g.: show_last_stack(12345);
%
%Control for movie as for tiff_stack
% 'shift+arrow up/down' - adjust brightness
% 'arrow up/down' - adjust movie speed
% 'space tab' - pause movie
% 't' - create average image of stack
%
%documented by DM and ML - 08.05.2014
% modified by FW 08.07.2017, 08.05.2019

%parse varargin arguments one-liner. Assumes name-value pairs.
cellfun(@(x,y) assignin('caller',x,y),varargin(1:2:end),varargin(2:2:end),'uni',0);

if ~exist('exp','var') || isempty(exp), exp=0; end
if ~exist('splitdata','var') || isempty(splitdata), splitdata=1; end
if ~exist('ch_combined','var') || isempty(ch_combined), ch_combined=1; end
if ~exist('calcMM','var') || isempty(calcMM), calcMM=0; end
if ~exist('ProjID','var') || isempty(ProjID), ProjID=[]; end
if ~exist('check_z','var') || isempty(check_z), check_z=0; end
if ~exist('reg','var') || isempty(reg), reg=0; end
if ~exist('zl','var') || isempty(zl), zl=0; end

if exist('D:\tempData\','file') == 7
    tmp_dir='D:\tempData\';
elseif exist('E:\tempData\','file') == 7
    tmp_dir='E:\tempData\';
elseif isa(exp,'char') && ~isempty(regexp(exp,'\:\\|\\\\')) %if path given (to load absolute file-paths use load_bin)
    tmp_dir=exp;
    exp=0;
end
if exp>0 && isempty(dir([tmp_dir filesep 'S1-T' num2str(exp) '*.bin']))
    disp('Exp not found in tempData folder, loading from RawData...');
    if ~isempty(dir(['F:\RawData\tmp\' filesep 'S1-T' num2str(exp) '*.bin']))
        tmp_dir='F:\RawData\tmp\';
    else
        [data_path,ExpIDinfo]=get_data_path(qexp(exp,'expid'));
        tmp_dir=[data_path ExpIDinfo.userID '\' ExpIDinfo.mouse_id '\'];
    end;
    if isempty(tmp_dir)
        error('couldn''t find/load exp');
    end
    
end




if exp<=0
    previous=exp;
    tmpfiles=dir([tmp_dir '*.bin']);
    tmpfiles=struct2cell(tmpfiles);
    [~,tmp_time_ind]=sort(cell2mat(tmpfiles(5,:)));
    fname=tmpfiles{1,tmp_time_ind(end+previous)};
    exp=fname(5:strfind(fname,'_ch')-1);
end


% else
tmpfiles=dir([tmp_dir '*.bin']);
tmpfiles=struct2cell(tmpfiles);
exp=num2str(exp);
fnameCh1=['S1-T' exp '_ch610.bin'];
fnameCh2=['S1-T' exp '_ch525.bin'];
srchCh1=strcmp(fnameCh1,tmpfiles(1,:));
srchCh2=strcmp(fnameCh2,tmpfiles(1,:));
if isempty(find(srchCh1))==0 && isempty(find(srchCh2))~=0
    fname=fnameCh1;
elseif isempty(find(srchCh1))~=0 && isempty(find(srchCh2))==0
    fname=fnameCh2;
elseif isempty(find(srchCh1))==0 && isempty(find(srchCh2))==0
    disp(['Exp files from both channels recorded'])
    load_ch=input(['Load ch610 (0) ch525 (1) or both (2)? ']);
    if load_ch==0
        fname=fnameCh1;
    elseif load_ch==1
        fname=fnameCh2;
    else
        fname={fnameCh1 fnameCh2};
    end
end
% end




if reg || zl
    if ~zl, zl=1; end
    if reg, zl=reg; end
    data=load_zlayer_partial([tmp_dir fname],zl,4);
    if isempty(reg) || reg==0,
        view_stack(data);set(gcf,'name',['unregistered ' regexpi(fname,'(?<=S1-T)\d+','match','once')])
        if nargout>0, varargout{1}=data; end
        return
    end
    if isempty(data), fprintf('couldn''t load file: %s\nerror: %s',[tmp_dir fname],err.message); return; end
    if reg
        fprintf('registering first,last 10%% of data...');
        [dx,dy]=register_frames(data); fprintf('done.\n')
        view_stack(shift_data(data,dx,dy)); set(gcf,'name',['registered ' regexpi(fname,'(?<=S1-T)\d+','match','once')])
    end
    if nargout>0, varargout{1}=data; end
    return
end


if exist('fname','var')
    if ~isa(fname,'cell')
        disp(['last stack: ' fname]);
        
        data=load_bin([tmp_dir fname]);
        inidata = readini([tmp_dir regexprep(fname,'.bin','.ini')]);
        %         check_zdrift(data(:,:,[1:inidata.piezo.nbrlayers:50*inidata.piezo.nbrlayers end-inidata.piezo.nbrlayers:50*inidata.piezo.nbrlayers:end]))
        if splitdata && inidata.piezo.nbrlayers > 1
            dim = size(data);
            if mod(dim(3),inidata.piezo.nbrlayers) > 0
                data = data(:,:,1:end-mod(dim(3),inidata.piezo.nbrlayers));
                dim = size(data);
                warning('frame numbers are not an even multiple of piezo layers');
            end
            data = reshape(data,dim(1),dim(2)*inidata.piezo.nbrlayers,dim(3)/inidata.piezo.nbrlayers);
        end
        view_stack(data)
    elseif size(fname,2) == 2 && ch_combined
        ind = 1;
        fname{ind}
        data1=load_bin([tmp_dir fname{ind}]);
        inidata = readini([tmp_dir regexprep(fname{ind},'.bin','.ini')]);
        if splitdata && inidata.piezo.nbrlayers > 1
            dim = size(data1);
            if mod(dim(3),inidata.piezo.nbrlayers) > 0
                data1 = data1(:,:,1:end-mod(dim(3),inidata.piezo.nbrlayers));
                dim = size(data1);
                warning('frame numbers are not an even multiple of piezo layers');
            end
            data1 = reshape(data1,dim(1),dim(2)*inidata.piezo.nbrlayers,dim(3)/inidata.piezo.nbrlayers);
        end
        
        ind = 2;
        fname{ind}
        data=load_bin([tmp_dir fname{ind}]);
        inidata = readini([tmp_dir regexprep(fname{ind},'.bin','.ini')]);
        if splitdata && inidata.piezo.nbrlayers > 1
            dim = size(data);
            if mod(dim(3),inidata.piezo.nbrlayers) > 0
                data = data(:,:,1:end-mod(dim(3),inidata.piezo.nbrlayers));
                dim = size(data);
            end
            data = reshape(data,dim(1),dim(2)*inidata.piezo.nbrlayers,dim(3)/inidata.piezo.nbrlayers);
        end
        
        ims(:,:,1,:) = ntzo(data1);
        ims(:,:,2,:) = ntzo(data);
        ims(:,:,3,:) = zeros(size(data));
        view_stack_RGB(ims);
    else
        for ind=1:size(fname,2)
            fname{ind}
            data=load_bin([tmp_dir fname{ind}]);
            inidata = readini([tmp_dir regexprep(fname{ind},'.bin','.ini')]);
            %             check_zdrift(data(:,:,[1:inidata.piezo.nbrlayers:50*inidata.piezo.nbrlayers end-inidata.piezo.nbrlayers:50*inidata.piezo.nbrlayers:end]))
            if splitdata && inidata.piezo.nbrlayers > 1
                dim = size(data);
                if mod(dim(3),inidata.piezo.nbrlayers) > 0
                    data = data(:,:,1:end-mod(dim(3),inidata.piezo.nbrlayers));
                    dim = size(data);
                    warning('frame numbers are not an even multiple of piezo layers');
                end
                data = reshape(data,dim(1),dim(2)*inidata.piezo.nbrlayers,dim(3)/inidata.piezo.nbrlayers);
            end
            view_stack(data)
        end
    end
end

if calcMM
    mean_act=zeros(1,size(data,3));
    for frame=1:size(data,3)
        mean_act(frame)=mean(reshape(data(:,:,frame),1,size(data,1)*size(data,2)));
    end
    mean_act_full=psmooth(mean_act);
    mean_act_full=mean_act_full'/median(mean_act_full);
    
    [~,curr_hostname]=system('hostname');
    if ~isempty(strfind(curr_hostname,'rig1-2pi'))
        aux_tmp_dir='\\keller-rig1-aux.fmi.ch\tempData\';
    elseif ~isempty(strfind(curr_hostname,'rig2-2pi'))
        aux_tmp_dir='\\keller-rig2-aux.fmi.ch\tempData\';
    elseif ~isempty(strfind(curr_hostname,'rig3-2pi'))
        aux_tmp_dir='\\arber-rig3-aux.fmi.ch\tempData\';
    else
        %display(['Please only use calcMM on an *-2pi rig machine only.'])
        aux_tmp_dir=input('Enter aux_tmp dir ');
    end
    
    aux_fname=['S1-T' exp '.lvd'];
    aux_data=load_lvd([aux_tmp_dir aux_fname]);
    ftindex=get_frame_times(aux_data(2,:));
    ftindex=ftindex(2:4:end);
    
    ps_id=aux_data(3,ftindex);
    [~,~,velM_smoothed,~]=get_vel_ind_from_adata(aux_data(5,:));
    velM_smoothed=velM_smoothed(ftindex);
    
    [mm_resp,~,~,~,~,~,~,~,~,~]=calculate_Mismatch(mean_act_full,velM_smoothed,[],ps_id,true,ProjID);
    figure;plot(squeeze(mean(mm_resp,3)));
end

if check_z==1
    check_zdrift(data(:,1:750,:));
end


if nargout>0 %prevent console flooding
    varargout{1}=data;
    try varargout{2}=data1; catch; end
end

end

function  [data,nbr_images]=load_zlayer_partial(fname,z_layer,nlayers)
%loads only first/last 10% of file, only specified z-layer
%FW 2019
if ~exist('nlayers','var') || isempty(nlayers), nlayers=4; end
find_closest_to_n=@(x,n) x+ (n-rem(x,n));

% up=max([1-perc,.9]); down=min([perc,.1]); %minimally load 10%

finfo=dir(fname);
fi=fopen(fname,'r');

x_res=fread(fi,1,'int16=>double');
y_res=fread(fi,1,'int16=>double');
nbr_images=round(finfo.bytes/x_res/y_res/2);

disp(['loading first/last 10% of zlayer'   num2str(z_layer) ', ' fname ' from data directory']);

if z_layer>1
    for ind=1:z_layer-1
        fseek(fi,x_res*y_res*2,'cof');
    end
end

e=(nbr_images/nlayers);
e_low=1:find_closest_to_n(e*.1,nlayers);
e_high=(find_closest_to_n(e*.9,nlayers))+1:(e-1);
frames=[e_low e_high];

data=zeros(x_res,y_res,numel(frames)-1,'int16');
if nlayers>1
    for ind=1:numel(e_low)
        data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
        fseek(fi,x_res*y_res*2*3,'cof');
    end
    fseek(fi,x_res*y_res*2*4*(min(e_high)-max(e_low)),'cof'); %skip between
    for knd=1:numel(e_high)
        data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
        fseek(fi,x_res*y_res*2*3,'cof');
        ind=ind+1;
    end
else
    for ind=1:numel(e_low)
        data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
    end
    fseek(fi,x_res*y_res*2*4*(min(e_high)-max(e_low)),'cof'); %skip between
    for knd=1:numel(e_high)
        data(:,:,ind)=fread(fi,[y_res x_res],'int16=>int16')';
        ind=ind+1;
    end
end

fclose(fi);

end


function check_zdrift(data)
%needs fixing?
disp('checking z_drift (AF method)');
[dx,dy] = register_frames(data,mean(data(:,:,20:30),3));
data = shift_data(data,dx,dy);
im1 = mean(data(:,:,1:floor(end/2)),3);
im2 = mean(data(:,:,ceil(end/2+1):end),3);
im3(:,:,1) = ntzo(im1);
im3(:,:,2) = ntzo(im2);
im3(:,:,3) = zeros(size(im1));
figure;
colormap gray
subplot(1,3,1); imagesc(imadjust(ntzo(im1),[0 0.4]));axis off;title('first 50 frames')
subplot(1,3,2); imagesc(imadjust(ntzo(im2),[0 0.4]));axis off;title('last 50 frames')
subplot(1,3,3); imagesc(im3);axis off;title('combined')
end
