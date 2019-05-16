function [] = register_exp_downsample(ExpID,fta,template_frames)
% [] = register_exp_downsample(ExpID,fta,template_frames)
% register_exp_downsample function registers 2P imaging data. 
% fixes registration where normal registration fails due to too low signal.
% Works by averaging over 'fta' frames as an input argument.
% When specifying frame numbers to register against, always use
% frames after 10, as due to instability of mirrors, galvos,..., frames 1 to
% 10 are unstable and not suitable for registration (e.g. 11-21, or 21-30).
%
%
% documented by DM - 08.05.2014
% modified by ML 2014-06-23

adata_dir=set_lab_paths;

ExpInfo = read_info_from_ExpLog(ExpID,1);
[adata_file,mouse_id,userID] = find_adata_file(ExpID,adata_dir);
if ~isempty(adata_file)
    fname = [adata_dir ExpInfo.userID '\' ExpInfo.mouse_id '\' adata_file];
    curr_file_struct = load(fname);
    AFileExist=1;
else
    temp = strsplit(ExpInfo.fnames{1},'\');
    fn = temp{end};
    fn = fn(1:strfind(fn,'_')-1);
    fname = [adata_dir ExpInfo.userID '\' ExpInfo.mouse_id '\Adata-' fn];

    curr_file_struct.fnames = ExpInfo.fnames;
    curr_file_struct.aux_files = ExpInfo.aux_files;
    curr_file_struct.mouse_id = ExpInfo.mouse_id;
    curr_file_struct.userID = ExpInfo.userID;
    AFileExist=0;
end

if ~exist('template_frames','var')
    template_frames=11:30;
end

try
    nbr_piezo_layers=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
catch
    nbr_piezo_layers=1;
    disp('ATTENTION - could not read nbr of piezo layers from ini file')
end

% save registration correaction log
path_to_curr_file = eval(['which(''' mfilename ''')']);
[~,svn_revision_nbr]=system(['svn info --show-item revision "' path_to_curr_file '"']);
arg_input_str = ['fta: ' num2str(fta) ', template_frames: ' num2str(template_frames(1)) ':' num2str(template_frames(end))];
reg_log_str = [datestr(now) ' - SVN revision nbr: ' num2str(str2num(svn_revision_nbr)) ' : register_exp_downsample - ' arg_input_str ' EOL'];

if ~isfield(curr_file_struct,'registration_log')
   curr_file_struct.registration_log{1}=reg_log_str;
else
   curr_file_struct.registration_log{end+1}=reg_log_str;
end

% % load the 2P data
[data,curr_file_struct.nbr_frames]=load_bin(ExpInfo.fnames,nbr_piezo_layers);

% % pre-allocate space for data
% for knd=1:length(ExpInfo.fnames)
%     finfo=dir([ExpInfo.fnames{knd}]);
%     fi=fopen([ExpInfo.fnames{knd}],'r');
%     x_res=fread(fi,1,'int16=>double');
%     y_res=fread(fi,1,'int16=>double');
%     nbr_frames(knd)=round(finfo.bytes/x_res/y_res/2);
%     nbr_frames(knd)=nbr_frames(knd)-rem(nbr_frames(knd),nbr_piezo_layers);
%     fclose(fi);
% end
% number_of_frames_total=sum(nbr_frames);
% if nbr_piezo_layers>1
%     data=cell(1,nbr_piezo_layers);
%     for knd=1:nbr_piezo_layers
%         data{knd}=zeros(x_res,y_res,round(number_of_frames_total/4),'int16');
%     end
% else
%     data=zeros(x_res,y_res,number_of_frames_total,'int16');
% end
% 
% % load the data
% for ind=1:length(ExpInfo.fnames)
%     if exist([ExpInfo.fnames{ind}],'file');
%         disp(['loading file ' ExpInfo.fnames{ind} ' from local tmpdata directory']);
%         curr_load_path=[ExpInfo.fnames{ind}];
%     end
%     
%     fi=fopen(curr_load_path,'r');
%     x_res=fread(fi,1,'int16=>double');
%     y_res=fread(fi,1,'int16=>double');
%     
%     if nbr_piezo_layers>1
%         for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
%             data{rem(knd-1,nbr_piezo_layers)+1}(:,:,floor((knd-1)/nbr_piezo_layers)+1)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
%         end
%     else
%         for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
%             data(:,:,knd)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
%         end
%     end
%     fclose(fi);
% end



if nbr_piezo_layers<2
    disp(['Now registering the data on frames ' num2str(template_frames(1)) ':' num2str(template_frames(end))]);
    data_length=size(data,3);
    if ceil(data_length/fta)>floor(data_length/fta)
        data_ds=zeros(size(data,1),size(data,2),floor(data_length/fta)+1);
    else
        data_ds=zeros(size(data,1),size(data,2),floor(data_length/fta)+1);
    end
    for knd=1:floor(data_length/fta)
        data_ds(:,:,knd)=mean(data(:,:,fta*(knd-1)+1:(fta)*knd),3);
    end
    if ceil(data_length/fta)>floor(data_length/fta)
        data_ds(:,:,knd+1)=mean(data(:,:,end-fta+1:end),3);
    end
    [dx_ds,dy_ds]=register_frames(data_ds,mean(data_ds(:,:,template_frames),3));
    dx=reshape(repmat(dx_ds,1,fta)',length(dx_ds)*fta,1);
    dy=reshape(repmat(dy_ds,1,fta)',length(dy_ds)*fta,1);
    dx=dx(1:data_length);
    dy=dy(1:data_length);
    clear data_ds;
    
elseif nbr_piezo_layers > 1
    dx_ds={};
    dy_ds={};
    data_ds={};
    data_length=size(data{1},3);
    for jnd=1:nbr_piezo_layers
        disp(['Now registering the data on frames ' num2str(template_frames(1)) ':' num2str(template_frames(end)) ' ' 'z-plane:' ' ' num2str(jnd)]);
        if ceil(data_length/fta)>floor(data_length/fta)
            data_ds{jnd}=zeros(size(data{jnd},1),size(data{jnd},2),floor(data_length/fta)+1);
        else
            data_ds{jnd}=zeros(size(data{jnd},1),size(data{jnd},2),floor(data_length/fta));
        end
        for knd=1:floor(data_length/fta)
            data_ds{jnd}(:,:,knd)=mean(data{jnd}(:,:,fta*(knd-1)+1:fta*knd),3);
        end
        if ceil(data_length/fta)>floor(data_length/fta)
            data_ds{jnd}(:,:,end+1)=mean(data{jnd}(:,:,end-fta+1:end),3);
        end
        figure;imagesc(mean(data_ds{jnd}(:,:,template_frames),3));colormap gray
        [dx_ds{jnd},dy_ds{jnd}]=register_frames(data_ds{jnd},mean(data{jnd}(:,:,template_frames),3));
        dx{jnd}=reshape(repmat(dx_ds{jnd},1,fta)',length(dx_ds{jnd})*fta,1);
        dy{jnd}=reshape(repmat(dy_ds{jnd},1,fta)',length(dy_ds{jnd})*fta,1);
        dx{jnd}=dx{jnd}(1:data_length);
        dy{jnd}=dy{jnd}(1:data_length);
        
        dx_check=find(abs(dx{jnd}-mean(dx{jnd}))>4*std(dx{jnd}));
        dy_check=find(abs(dy{jnd}-mean(dy{jnd}))>4*std(dy{jnd}));
        if ~isempty(dx_check) || ~isempty(dy_check)
            display(['ATTENTION: Large dx or dy shift detected in z-layer ' num2str(jnd) ' - correcting'])
            figure;subplot(2,1,1);plot(dx{jnd},'k');hold on;plot(dy{jnd},'r');legend('dx','dy')
            text(.1,.05,['Exp: ' num2str(ExpID)],'units','normalized','color','k','fontweight','bold','Interpreter','none')
            text(.1,.95,['z-layer: ' num2str(jnd)],'units','normalized','color','k','fontweight','bold','Interpreter','none')
            ftc=unique([dx_check;dy_check]');
            onsets=[ftc(1) ftc(find(diff(ftc)>1)+1);ftc(find(diff(ftc)>1)) ftc(end)]';
            dx_cor_first=[];
            dy_cor_first=[];
            dx_cor_last=[];
            dy_cor_last=[];
            if onsets(1,1)==1
                onsets(1,1)=2;
                dx_cor_first=dx{jnd}(onsets(1,2)+1);
                dy_cor_first=dy{jnd}(onsets(1,2)+1);
            end
            if onsets(end,2)==size(dx{jnd},1)
                onsets(end,2)=size(dx{jnd},1)-1;
                dx_cor_last=dx{jnd}(onsets(end,1)-1);
                dy_cor_last=dy{jnd}(onsets(end,1)-1);
            end
            dx_cor=round(mean([dx{jnd}(onsets(:,1)-1) dx{jnd}(onsets(:,2)+1)],2));
            dy_cor=round(mean([dy{jnd}(onsets(:,1)-1) dy{jnd}(onsets(:,2)+1)],2));
            if ~isempty(dx_cor_first)
                dx_cor(1)=dx_cor_first;
                dy_cor(1)=dy_cor_first;
                onsets(1,1)=1;
            end
            if ~isempty(dx_cor_last)
                dx_cor(end)=dx_cor_last;
                dy_cor(end)=dy_cor_last;
                onsets(end,2)=size(dx{jnd},1);
            end
            for xnd=1:size(onsets,1)
                dx{jnd}(onsets(xnd,1):onsets(xnd,2))=dx_cor(xnd,1);
                dy{jnd}(onsets(xnd,1):onsets(xnd,2))=dy_cor(xnd,1);
            end
            subplot(2,1,2);plot(dx{jnd},'k');hold on;plot(dy{jnd},'r')
            drawnow
        end
        clear data_ds;
    end
end

disp('Now registering data on dx dy values and correcting line shift');

if ~isa(dx,'cell')
    data=shift_data(data,dx,dy);
    data=correct_line_shift(data,mean(data,3));
    act_map=calc_act_map(data);
    template=mean(data,3);
else
    act_map={};
    template={};
    for rnd=1:length(dx)
        data{rnd}=shift_data(data{rnd},dx{rnd},dy{rnd});
        data{rnd}=correct_line_shift(data{rnd},mean(data{rnd},3));
        act_map{rnd}=calc_act_map(data{rnd});
        template{rnd}=mean(data{rnd},3);
    end
end

check_registration(dx,dy,template)

if ~AFileExist
    if nbr_piezo_layers<2
        curr_file_struct.ROIs=struct;
        curr_file_struct.bv=struct;
        curr_file_struct.np=struct;
    else
        curr_file_struct.ROIs=cell(1,nbr_piezo_layers);
        curr_file_struct.bv=cell(1,nbr_piezo_layers);
        curr_file_struct.np=cell(1,nbr_piezo_layers);
        for wnd=1:nbr_piezo_layers
            curr_file_struct.ROIs{wnd}=struct;
            curr_file_struct.bv{wnd}=struct;
            curr_file_struct.np{wnd}=struct;
        end
    end
    if ~isdir([adata_dir ExpInfo.userID '\' ExpInfo.mouse_id])
        mkdir([adata_dir ExpInfo.userID], ExpInfo.mouse_id);
    end
end

curr_file_struct.dx=dx;
curr_file_struct.dy=dy;
curr_file_struct.act_map=act_map;
curr_file_struct.template=template;
save(fname,'-struct','curr_file_struct','-v7.3');

disp('----Done fixing your registration...----');
if ~AFileExist
    disp('---- NO AData file was found. Generated new one. ----');
end
%EOF