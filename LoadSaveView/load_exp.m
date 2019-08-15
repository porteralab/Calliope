function []=load_exp(ExpID,adata_dir,load_ftypes,ExpLog,ws,just_behave)
% loads specified file types of an experiment
%
% ExpID - the ExpID as defined in ExpLog
% adata_dir - location of the Adata files
% load_ftypes - cell array of strings of file type endings to load
% ExpLog - experiment database extract
% ws - string specifying workspace identity for output, either 'base' or 'caller'
% just_behave (0 or 1) - just load the behavioral data
%
% GK - 01.01.2012
% modified PZ 2014-05-08 load eyeR, load ton, define workspace identity for output
% modified ML 2014-12-02 delete input argument 'cah'
% modified GK 2014-12-02 added ability to skip corrupted eye data file


% find the adata file
[adata_file,mouse_id,userID,projID]=get_adata_filename(ExpID,adata_dir,ExpLog);
[pdef]=getProjDef(projID);


load_2P=sum(strcmp(load_ftypes,[pdef.main_channel(3:end) '.bin']));
if length(pdef.secondary_channels)==0
    load_2P_sec=0;
else
    load_2P_sec=sum(strcmp(load_ftypes,[pdef.secondary_channels{1}(3:end) '.bin']));
end
load_eye=sum(strcmp(load_ftypes,'.eye'));
load_run=sum(strcmp(load_ftypes,'.run'));
load_aux=sum(strcmp(load_ftypes,'.lvd'));
load_vid2=sum(strcmp(load_ftypes,'.vid2'));
load_vid=sum(strcmp(load_ftypes,'.vid'));
load_ach=sum(strcmp(load_ftypes,'.ach'));
load_eyeR=sum(strcmp(load_ftypes,'.eyeR'));
load_ton=sum(strcmp(load_ftypes,'.ton'));

if nargin<6
    just_behave=0;
end


try
    load_noregister = evalin('base','load_noregister');
catch
    load_noregister = 0;
end

data_dir=get_data_path(ExpID);

vars_to_assigin_base={};
is_z_stack=0;
fpga_frames_zstep=0;
resave_data=0;
template_sec = {};
act_map_sec = {};



if isempty(adata_file) & just_behave==0
    disp('Found no Adata file - register data before loading');
    return;
end




try
    if just_behave==0
        load([adata_dir '\' userID '\' mouse_id '\' adata_file]);
        if exist('aux_files','var')
            aux_files=regexprep((aux_files),'.*RawData\\+',strrep(data_dir,'\','\\'),'ignorecase'); %replace data_dir with dir get_data_path
        end
        if ~exist('mean_data','var')
            if ~exist('ROItrans','var');
                if isa(ROIs,'cell')
                    ROItrans=cell(1,length(ROIs));
                    for und=1:length(ROIs)
                        ROItrans{und}=zeros(3,1);
                    end
                else
                    ROItrans=zeros(3,1);
                end
            end
            nbr_frames_infile=nbr_frames;
            vars_to_assigin_base={vars_to_assigin_base{:},'ROIs','ROItrans','np','bv','act_map'};
        else
            is_z_stack=1;
            load_2P=0;
            load_2P_sec=0;
            load_eye=0;
            load_run=0;
            load_aux=0;
            load_vid2=0;
            load_vid = 0;
            vars_to_assigin_base={vars_to_assigin_base{:},'mean_data'};
        end
        if exist('template_sec','var') && ~isempty(template_sec)
            vars_to_assigin_base={vars_to_assigin_base{:},'template_sec'};
        end
        if exist('act_map_sec','var') && ~isempty(act_map_sec)
            vars_to_assigin_base={vars_to_assigin_base{:},'act_map_sec'};
        end
    else
        disp('Just loading behavioral data');
        [ExpInfo,data_dir] = read_info_from_ExpLog(ExpID,0);
        aux_files=ExpInfo.aux_files;
    end
catch me
    fprintf('Could not load analyzed data (%s)\n',me.message);
    return;
end

if ~is_z_stack
    try
        [ExpInfo,data_dir] = read_info_from_ExpLog(ExpID,0);
        fnames = ExpInfo.fnames;
        if load_2P_sec
            sec_fnames = ExpInfo.sec_fnames;
        end
    end
end

if just_behave==0
    try
        nbr_piezo_layers=readini([ fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
    catch
        nbr_piezo_layers=1;
        disp('ATTENTION - could not read nbr of piezo layers from ini file')
    end
    
    try
        fpga_frames_zstep=readini([fnames{1}(1:end-3) 'ini'],'FPGA.framesperzstep');
        if fpga_frames_zstep > 0
            nbr_piezo_layers=1;  % more likely setting was forgotten to be set to 1
        end
        fpga_frames_layer=readini([fnames{1}(1:end-3) 'ini'],'FPGA.framesperlayer');
    catch
        disp('ATTENTION - could not read z step details from ini file')
        fpga_frames_zstep=0;
        fpga_frames_layer=1;
    end
end

if fpga_frames_zstep>0
    mean_data_fname=[adata_dir userID '\' mouse_id '\' adata_file];
    disp('This is a Z stack');
    load_2P = 0;
    load_2P_sec = 0;
    load(mean_data_fname);
    vars_to_assigin_base = {vars_to_assigin_base{:},'mean_data'};
end

if is_z_stack==0
    if ~exist([aux_files{1}(1:end-4) '.ach'],'file')
        [ExpInfo,data_dir] = read_info_from_ExpLog(ExpID,0);
        aux_files = ExpInfo.aux_files;
    end
end

if load_ach
    ach=readini([aux_files{1}(1:end-4) '.ach']);
    vars_to_assigin_base = {vars_to_assigin_base{:},'ach'};
end

if load_aux
    % load the aux data - first try loading the data from the data
    % directory
    aux_data=[];
    for ind=1:length(aux_files)
        if exist([aux_files{ind}],'file');
            disp(['loading file ' aux_files{ind} ' from data directory']);
            curr_load_path=[aux_files{ind}];
        else
            error(['File ' aux_files{ind} ' does not exist in data directory']);
        end
        
        tmp_data=load_lvd(curr_load_path);
        
        if just_behave==0
            if strcmp(mouse_id,'PZ_110818_a')
                tmp_frames=get_frame_times(tmp_data(3,:));
            else
                tmp_frames=get_frame_times(tmp_data(2,:));
            end
            
            if nbr_frames(ind)~=length(tmp_frames)
                if tmp_frames == 1
                    disp('probably no bin file')
                elseif max(diff(tmp_frames))/median(diff(tmp_frames))<1.5 && length(tmp_frames)>nbr_frames(ind)
                    disp('NC WARNING! Probably scanning too fast for FPGA to stop in the same frame')
                    disp(['--- ' num2str(length(tmp_frames)-nbr_frames(ind)) ' frame(s) too many ---'])
                    tmp_data(2,tmp_frames(nbr_frames(ind)+1):end)=0;
                elseif max(diff(tmp_frames))/median(diff(tmp_frames))<1.5 && length(tmp_frames)<nbr_frames(ind)
                    critwarn='CRITICAL WARNING! looks like a crashed stack where line galvo stopped running';
                    writeErrorLog(ExpID,critwarn);
                    disp(['--- ' num2str(nbr_frames(ind)-length(tmp_frames)) ' frame(s) too few ---'])
                    if nbr_piezo_layers>1
                        nbr_frames(ind)=nbr_piezo_layers*floor(length(tmp_frames)/nbr_piezo_layers);
                        tmp_data(2,tmp_frames(nbr_frames(ind))+median(diff(tmp_frames)):end)=0;
                    else
                        nbr_frames(ind)=length(tmp_frames);
                    end
                    resave_data=1;
                elseif length(tmp_frames)>nbr_frames(ind)
                    critwarn='CRITICAL WARNING! This looks like a HD full crash file - careful this is a hack that only rarely works';
                    writeErrorLog(ExpID,critwarn);
                    disp(['--- ' num2str(length(tmp_frames)-nbr_frames(ind)) ' frame(s) too many ---'])
                    tmp_data(2,tmp_frames(nbr_frames(ind)+1):end)=0;
                else
                    critwarn='CRITICAL WARNING! - aux data longer than it should be.';
                    writeErrorLog(ExpID,critwarn);
                    [~,last_bad_frame]=max(diff(tmp_frames));
                    tmp_data=tmp_data(:,ceil(mean([tmp_frames(last_bad_frame) tmp_frames(last_bad_frame+1)])):end);
                end
            end
        else
            nbr_frames(ind)=size(tmp_data,2);
        end
        aux_data(1:size(tmp_data,1),end+1:end+length(tmp_data))=tmp_data;
    end
    
    if strcmp(mouse_id,'PZ_110818_a')
        frame_times=get_frame_times(aux_data(3,:));
    else
        frame_times=get_frame_times(aux_data(2,:));
    end
    vars_to_assigin_base={vars_to_assigin_base{:}, 'aux_data', 'frame_times'};
end

% load the 2P data
if load_2P
    % if resave data - adapt dx dy
    if resave_data
        corr_stacks_ind=find(nbr_frames-nbr_frames_infile);
        for ind=1:length(corr_stacks_ind)
            if nbr_piezo_layers>1
                for knd=1:nbr_piezo_layers
                    dx{knd}(sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1)-1))/nbr_piezo_layers+nbr_frames(corr_stacks_ind(end-ind+1))/nbr_piezo_layers+1:sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1)))/nbr_piezo_layers)=[];
                    dy{knd}(sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1)-1))/nbr_piezo_layers+nbr_frames(corr_stacks_ind(end-ind+1))/nbr_piezo_layers+1:sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1)))/nbr_piezo_layers)=[];
                end
            else
                dx(sum(nbr_frames(1:corr_stacks_ind(end-ind+1)))+1:sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1))))=[];
                dy(sum(nbr_frames(1:corr_stacks_ind(end-ind+1)))+1:sum(nbr_frames_infile(1:corr_stacks_ind(end-ind+1))))=[];
            end
        end
    end
    
    % pre-allocate space for data
    if nbr_piezo_layers>1
        data=cell(1,nbr_piezo_layers);
        for knd=1:nbr_piezo_layers
            data{knd}=zeros(size(template{1},1),size(template{1},2),sum(nbr_frames)/nbr_piezo_layers,'int16');
        end
    else
        data=zeros(size(template,1),size(template,2),sum(nbr_frames),'int16');
    end
    
    % load the data
    for ind=1:length(fnames)
        if exist([fnames{ind}],'file');
            disp(['loading file ' fnames{ind} ' from data directory']);
            curr_load_path=[fnames{ind}];
        else
            error(['File ' fnames{ind} ' does not exist in data directory']);
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
    
    if ~load_noregister
        disp(['Now registering data on dx dy values and correcting line shift']);
        if ~isa(dx,'cell')
            data=shift_data(data,dx,dy);
            data=correct_line_shift(data,mean(data,3));
        else
            for rnd=1:length(dx)
                data{rnd}=shift_data(data{rnd},dx{rnd},dy{rnd});
                data{rnd}=correct_line_shift(data{rnd},mean(data{rnd},3));
            end
        end
    else
        warning('loaded data without registration')
    end
    vars_to_assigin_base={vars_to_assigin_base{:}, 'data', 'act_map_sec'};
end


% load the second channel 2P data
if load_2P_sec
    
    % pre-allocate space for data
    if nbr_piezo_layers>1
        sec_data=cell(1,nbr_piezo_layers);
        for knd=1:nbr_piezo_layers
            sec_data{knd}=zeros(size(template{1},1),size(template{1},2),sum(nbr_frames)/nbr_piezo_layers,'int16');
        end
    else
        sec_data=zeros(size(template,1),size(template,2),sum(nbr_frames),'int16');
    end
    
    % load the data
    for ind=1:length(sec_fnames)
        if exist([sec_fnames{ind}],'file');
            disp(['loading file ' sec_fnames{ind} ' from data directory']);
            curr_load_path=[sec_fnames{ind}];
        else
            error(['File ' sec_fnames{ind} ' does not exist in data directory']);
        end
        
        fi=fopen(curr_load_path,'r');
        x_res=fread(fi,1,'int16=>double');
        y_res=fread(fi,1,'int16=>double');
        
        if nbr_piezo_layers>1
            for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
                sec_data{rem(knd-1,nbr_piezo_layers)+1}(:,:,floor((knd-1)/nbr_piezo_layers)+1)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
            end
        else
            for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
                sec_data(:,:,knd)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
            end
        end
        fclose(fi);
    end
    
    if ~load_noregister
        disp(['Now registering data on dx dy values and correcting line shift']);
        if ~isa(dx,'cell')
            sec_data=shift_data(sec_data,dx,dy);
            sec_data=correct_line_shift(sec_data,mean(sec_data,3));
        else
            for rnd=1:length(dx)
                sec_data{rnd}=shift_data(sec_data{rnd},dx{rnd},dy{rnd});
                sec_data{rnd}=correct_line_shift(sec_data{rnd},mean(sec_data{rnd},3));
            end
        end
    else
        warning('loaded data without registration')
    end
    vars_to_assigin_base={vars_to_assigin_base{:}, 'sec_data', 'act_map'};
end

if load_run
    rdata=zeros(0,0,0,'int16');
    rmeta_data=[];
    no_run_data=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.run'],'file')
            disp(['loading file ' aux_files{ind}(1:end-4) '.run' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.run'];
        else
            disp('No run data found!')
            no_run_data=1;
            break
        end
        [tmp_rdata, tmp_rmeta_data] = load_vid_data(curr_load_path,'int16');
        nbr_rframes(ind)=length(tmp_rmeta_data);
        if ind==1||sum(size(rdata(:,:,1))==size(tmp_rdata(:,:,1)))==2
            rdata(:,:,end+1:end+size(tmp_rdata,3))=tmp_rdata;
        else
            disp('Idata sizes don''t match - will improvise');
            rdata(1:size(tmp_rdata,1),1:size(tmp_rdata,2),end+1:end+size(tmp_rdata,3))=tmp_rdata;
        end
        rmeta_data(:,end+1:end+length(tmp_rmeta_data))=tmp_rmeta_data;
    end
    
    if ~no_run_data
        rframe_times=get_iframe_times(rmeta_data,aux_data(1,:),nbr_rframes);
        vars_to_assigin_base={vars_to_assigin_base{:}, 'rdata', 'rmeta_data','rframe_times', 'nbr_rframes'};
    end
end


if load_vid
    vdata=zeros(0,0,0,'int16');
    vmeta_data=[];
    no_vid_data=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.vid'],'file')
            disp(['loading file ' aux_files{ind}(1:end-4) '.vid' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.vid'];
        else
            disp('No vid data found!')
            no_vid_data=1;
            break
        end
        [tmp_vdata, tmp_vmeta_data] = load_vid_data(curr_load_path,'int16');
        nbr_vframes(ind)=length(tmp_vmeta_data);
        if ind==1||sum(size(vdata(:,:,1))==size(tmp_vdata(:,:,1)))==2
            vdata(:,:,end+1:end+size(tmp_vdata,3))=tmp_vdata;
        else
            disp('Idata sizes don''t match - will improvise');
            vdata(1:size(tmp_vdata,1),1:size(tmp_vdata,2),end+1:end+size(tmp_vdata,3))=tmp_vdata;
        end
        vmeta_data(:,end+1:end+length(tmp_vmeta_data))=tmp_vmeta_data;
    end
    
    if ~no_vid_data
        vframe_times=get_iframe_times(vmeta_data,aux_data(1,:),nbr_vframes);
        vars_to_assigin_base={vars_to_assigin_base{:}, 'vdata', 'vmeta_data','vframe_times', 'nbr_vframes'};
    end
end

if load_vid2
    v2data=zeros(0,0,0,'int16');
    v2meta_data=[];
    no_vid2_data=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.vid2'],'file')
            disp(['loading file ' aux_files{ind}(1:end-4) '.vid2' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.vid2'];
        else
            disp('No run data found!')
            no_vid2_data=1;
            break
        end
        [tmp_v2data, tmp_v2meta_data] = load_vid_data(curr_load_path,'int16');
        nbr_v2frames(ind)=length(tmp_v2meta_data);
        if ind==1||sum(size(v2data(:,:,1))==size(tmp_v2data(:,:,1)))==2
            v2data(:,:,end+1:end+size(tmp_v2data,3))=tmp_v2data;
        else
            disp('vid2 data sizes don''t match - will improvise');
            v2data(1:size(tmp_v2data,1),1:size(tmp_v2data,2),end+1:end+size(tmp_v2data,3))=tmp_v2data;
        end
        v2meta_data(:,end+1:end+length(tmp_v2meta_data))=tmp_v2meta_data;
    end
    
    if ~no_vid2_data
        v2frame_times=get_iframe_times(v2meta_data,aux_data(1,:),nbr_v2frames);
        vars_to_assigin_base={vars_to_assigin_base{:}, 'v2data', 'v2meta_data','v2frame_times', 'nbr_v2frames'};
    end
end

if load_eye
    idata=zeros(0,0,0,'uint8');
    imeta_data=[];
    no_eye_data=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.eye'],'file');
            disp(['loading file ' aux_files{ind}(1:end-4) '.eye' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.eye'];
        else
            disp('No eye data found!')
            no_eye_data=1;
            break
        end
        [tmp_idata, tmp_imeta_data] = load_eye_monitor_data(curr_load_path,load_eye);
        
        if isempty(tmp_imeta_data)
            disp('Warning: idata unfixably corrupt for this experiment - skipping!')
            idata=zeros(0,0,0,'uint8');
            imeta_data=[];
            no_eye_data=1;
            break
        end
        
        nbr_iframes(ind)=length(tmp_imeta_data);
        if ind==1||sum(size(idata(:,:,1))==size(tmp_idata(:,:,1)))==2
            idata(:,:,end+1:end+size(tmp_idata,3))=tmp_idata;
        else
            disp('Idata sizes don''t match - will improvise');
            idata(1:size(tmp_idata,1),1:size(tmp_idata,2),end+1:end+size(tmp_idata,3))=tmp_idata;
        end
        
        imeta_data(:,end+1:end+length(tmp_imeta_data))=tmp_imeta_data;
    end
    if ~no_eye_data
        [iframe_times]=get_iframe_times(imeta_data,aux_data(1,:),nbr_iframes);
        
        vars_to_assigin_base={vars_to_assigin_base{:}, 'idata', 'imeta_data','iframe_times', 'nbr_iframes'};
    end
end

if load_eyeR
    idataR=zeros(0,0,0,'uint8');
    imeta_dataR=[];
    no_eye_dataR=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.eyeR'],'file');
            disp(['loading file ' aux_files{ind}(1:end-4) '.eyeR' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.eyeR'];
        else
            disp('No eyeR data found!')
            no_eye_dataR=1;
            break
        end
        [tmp_idataR, tmp_imeta_dataR] = load_eye_monitor_data(curr_load_path,load_eyeR);
        nbr_iframesR(ind)=length(tmp_imeta_dataR);
        if ind==1||sum(size(idataR(:,:,1))==size(tmp_idataR(:,:,1)))==2
            idataR(:,:,end+1:end+size(tmp_idataR,3))=tmp_idataR;
        else
            disp('IdataR sizes don''t match - will improvise');
            idataR(1:size(tmp_idataR,1),1:size(tmp_idataR,2),end+1:end+size(tmp_idataR,3))=tmp_idataR;
        end
        imeta_dataR(:,end+1:end+length(tmp_imeta_dataR))=tmp_imeta_dataR;
    end
    if ~no_eye_dataR
        [iframe_timesR]=get_iframe_times(imeta_dataR,aux_data(1,:),nbr_iframesR);
        vars_to_assigin_base={vars_to_assigin_base{:}, 'idataR', 'imeta_dataR','iframe_timesR', 'nbr_iframesR'};
    end
end

if load_ton
    ldata=zeros(0,0,0,'uint8');
    lmeta_data=[];
    no_lick_data=0;
    for ind=1:length(aux_files)
        if exist([aux_files{ind}(1:end-4) '.ton'],'file');
            disp(['loading file ' aux_files{ind}(1:end-4) '.ton' ' from data directory']);
            curr_load_path=[aux_files{ind}(1:end-4) '.ton'];
        else
            disp('No lick data found!')
            no_lick_data=1;
            break
        end
        [tmp_ldata, tmp_lmeta_data] = load_vid_data(curr_load_path);
        nbr_lframes(ind)=length(tmp_lmeta_data);
        if ind==1||sum(size(ldata(:,:,1))==size(tmp_ldata(:,:,1)))==2
            ldata(:,:,end+1:end+size(tmp_ldata,3))=tmp_ldata;
        else
            disp('ldata sizes does not match - will improvise');
            ldata(1:size(tmp_ldata,1),1:size(tmp_ldata,2),end+1:end+size(tmp_ldata,3))=tmp_ldata;
        end
        lmeta_data(:,end+1:end+length(tmp_lmeta_data))=tmp_lmeta_data;
    end
    if ~no_lick_data
        [lframe_times]=get_iframe_times(lmeta_data,aux_data(1,:),nbr_lframes);
        vars_to_assigin_base={vars_to_assigin_base{:}, 'ldata', 'lmeta_data','lframe_times', 'nbr_lframes'};
    end
end

vars_to_assigin_base={vars_to_assigin_base{:}, 'dx', 'dy', 'fnames', 'aux_files', 'nbr_frames', 'template', 'mouse_id','userID','adata_dir'};

% assign the variables in base
for ind=1:length(vars_to_assigin_base)
    try
        eval(['assignin(''' ws ''',vars_to_assigin_base{ind},' vars_to_assigin_base{ind} ');']);
    end
end

if resave_data & load_2P
    disp('---- resaving data due to acquisition crash corruption ----');
    if nbr_piezo_layers>1
        if isfield(ROIs{1},'activity')
            for ind=1:nbr_piezo_layers
                ROIs{ind}=rmfield(ROIs{ind},'activity');
            end
        end
    else
        if isfield(ROIs,'activity')
            ROIs=rmfield(ROIs,'activity');
        end
    end
    save_adata(adata_dir,ROIs,bv,np,template,dx,dy,aux_files,fnames,nbr_frames,mouse_id,userID,act_map,template_sec,act_map_sec);
end

disp('----Done loading Exp!----');
%EOF