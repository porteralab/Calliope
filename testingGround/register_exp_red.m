function [] = register_exp_red(ExpID,adata_dir)
% register_exp function registers 2P imaging data.
%
%This function is used to register raw 2P imaging data. 
%The function is mainly called via the calliope GUI. Follow on screen
%instrutions. When specifying frame numbers to register against, always use
%frames after 10, as due to instability of mirrors, galvos,..., frames 1 to
%10 are unstable and not suitable for registration (e.g. 11-21, or 21-30).
%
%
%documented by DM - 08.05.2014

data_dir=get_data_path(ExpID);
template_frames = 11:30;

[adata_file]=find_adata_file(ExpID,adata_dir);

try
    registermode = evalin('base','registermode');
catch
    registermode = 1;
end

if ~isempty(adata_file)
    disp('Adata file already exists. Aborting.')
    return
end

[ExpInfo,data_dir] = read_info_from_ExpLog(ExpID,1);

% quick patch for taking the red channels ML
for ii = 1: size(ExpInfo.fnames,2)
   ExpInfo.fnames(ii) = regexprep(ExpInfo.fnames(ii),'525','610');
end

try
    nbr_piezo_layers=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
catch
    nbr_piezo_layers=1;
    disp('ATTENTION - could not read nbr of piezo layers from ini file')
end

try
    fpga_frames_zstep=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'FPGA.framesperzstep');
    if fpga_frames_zstep > 0
        nbr_piezo_layers=1;  % more likely setting was forgotten to be set to 1
    end
    fpga_frames_layer=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'FPGA.framesperlayer');
catch
    disp('ATTENTION - could not read z step details from ini file')
    fpga_frames_zstep=0;
    fpga_frames_layer=1;
end

% load the 2P data
% pre-allocate space for data
if registermode==1
    [data,nbr_frames]=load_bin(ExpInfo.fnames,nbr_piezo_layers);
elseif registermode == 2
    [data,nbr_frames]=load_bin(ExpInfo.fnames,1);
end

% check if it should load secondary channels for this expID
if ~isempty(ExpInfo.sec_fnames)
    sec_data=load_bin(ExpInfo.sec_fnames,nbr_piezo_layers);
    process_sec=true;

else
    process_sec=false;
end
    
% if so, do it now
template_sec = {};


if fpga_frames_zstep>0
    disp('Now registering Z stack');
    mean_data=register_multilayer(data,fpga_frames_layer);
    mean_data_fname=[adata_dir ExpInfo.userID '\' ExpInfo.mouse_id '\mean_data-' num2str(ExpID) '.mat'];
    if ~isdir([adata_dir ExpInfo.userID '\' ExpInfo.mouse_id])
        mkdir([adata_dir ExpInfo.userID], ExpInfo.mouse_id);
    end
    if ~isempty(ExpInfo.sec_fnames)
        disp('Now regisering Z stack channel 2')
        mean_data_sec=register_multilayer(sec_data,fpga_frames_layer);
        save(mean_data_fname,'mean_data','mean_data_sec');
    else
        save(mean_data_fname,'mean_data');
    end
    return;
end



if nbr_piezo_layers<2
    disp(['Now registering the data on frames ' num2str(template_frames(1)) ':' num2str(template_frames(end))]);
    [dx,dy]=register_frames(data,mean(data(:,:,template_frames),3));
elseif nbr_piezo_layers > 1 && registermode == 1
    dx={};
    dy={};
    for ynd=1:nbr_piezo_layers
        disp(['Now registering the data on frames ' num2str(template_frames(1)) ':' num2str(template_frames(end)) ' ' 'z-plane:' ' ' num2str(ynd)]);
        [dx_tmp,dy_tmp]=register_frames(data{ynd},mean(data{ynd}(:,:,template_frames),3));
        dx{ynd}=dx_tmp;
        dy{ynd}=dy_tmp;
    end
elseif nbr_piezo_layers > 1 && registermode == 2
    dx={};
    dy={};
    disp(['Now registering the data (layer avg) on frames ' num2str(template_frames(1)) ':' num2str(template_frames(end))]);
    [dx_tmp,dy_tmp]=register_frames(avgStack(data,nbr_piezo_layers),mean(data(:,:,template_frames),3));
    for ynd=1:nbr_piezo_layers
        dx{ynd}=dx_tmp;
        dy{ynd}=dy_tmp;
    end
end



disp(['Now registering data on dx dy values and correcting line shift']);   
if ~isa(dx,'cell')
    data=shift_data(data,dx,dy);
    data=correct_line_shift(data,mean(data,3));
    act_map=calc_act_map(data);
    template=mean(data,3);
    
    %if secondary, calc template
    if process_sec
        sec_data=shift_data(sec_data,dx,dy);
        sec_data=correct_line_shift(sec_data,mean(sec_data,3));
        template_sec=mean(sec_data,3);
    end
    
elseif registermode == 2
    act_map = {};
    template = {};
    data = shift_data(data,expmat(dx_tmp,nbr_piezo_layers),expmat(dy_tmp,nbr_piezo_layers));
    data = correct_line_shift(data,mean(data,3));
    for rnd=1:nbr_piezo_layers
        act_map{rnd}=calc_act_map(data(:,:,1:nbr_piezo_layers:end));
        template{rnd}=mean(data(:,:,1:nbr_piezo_layers:end),3);
    end
else
    act_map={};
    template={};
    for rnd=1:length(dx)
        data{rnd}=shift_data(data{rnd},dx{rnd},dy{rnd});
        data{rnd}=correct_line_shift(data{rnd},mean(data{rnd},3));
        act_map{rnd}=calc_act_map(data{rnd});
        template{rnd}=mean(data{rnd},3);
        
        if process_sec
           sec_data{rnd}=shift_data(sec_data{rnd},dx{rnd},dy{rnd});
            sec_data{rnd}=correct_line_shift(sec_data{rnd},mean(sec_data{rnd},3));
            
            template_sec{rnd}=mean(sec_data{rnd},3);
        end
        
    end
end

% write adata file
if nbr_piezo_layers<2
    ROIs=struct;
    bv=struct;
    np=struct;
    save_adata(adata_dir,ROIs,bv,np,template,dx,dy,ExpInfo.aux_files,ExpInfo.fnames,nbr_frames,ExpInfo.mouse_id,ExpInfo.userID,act_map,template_sec);
else
    ROIs=cell(1,nbr_piezo_layers);
    bv=cell(1,nbr_piezo_layers);
    np=cell(1,nbr_piezo_layers);
    for wnd=1:nbr_piezo_layers
        ROIs{wnd}=struct;
        bv{wnd}=struct;
        np{wnd}=struct;
    end
    save_adata(adata_dir,ROIs,bv,np,template,dx,dy,ExpInfo.aux_files,ExpInfo.fnames,nbr_frames,ExpInfo.mouse_id,ExpInfo.userID,act_map,template_sec);
end

disp('----Done registering Exp!----');
%EOF