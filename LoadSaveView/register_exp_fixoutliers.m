function [] = register_exp_fixoutliers(ExpID)
% fixes registration where normal registration fails due to too low signal.
% Function uses the ExpID as input argument.
% replaces missing values with mean of values surrounding outliers
% e.g. register_exp_fixoutliers(24790);
%
%
% documented by DM - 08.05.2014
% modified by ML 2014-06-23


adata_dir=set_lab_paths;
std_thresh=5;

ExpInfo = read_info_from_ExpLog(ExpID,1);
[adata_file,mouse_id,userID] = find_adata_file(ExpID,adata_dir);
fname=[adata_dir userID '\' mouse_id '\' adata_file];
curr_file_struct = load(fname);

try
    nbr_piezo_layers=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
catch
    nbr_piezo_layers=1;
    disp('ATTENTION - could not read nbr of piezo layers from ini file')
end

% check if it should load secondary channels for this expID
if ~isempty(ExpInfo.sec_fnames)
    process_sec=true;
else
    process_sec=false;
end


% save registration correaction log
path_to_curr_file = eval(['which(''' mfilename ''')']);
[~,svn_revision_nbr]=system(['svn info --show-item revision "' path_to_curr_file '"']);
reg_log_str = [datestr(now) ' - SVN revision nbr: ' num2str(str2num(svn_revision_nbr)) ' : register_exp_fixoutliers - EOL'];

if ~isfield(curr_file_struct,'registration_log')
   curr_file_struct.registration_log{1}=reg_log_str;
else
   curr_file_struct.registration_log{end+1}=reg_log_str;
end

go_on=zeros(nbr_piezo_layers,1);

if nbr_piezo_layers<2
    dx=curr_file_struct.dx;
    dy=curr_file_struct.dy;
    dx = {dx};
    dy = {dy};
   
elseif nbr_piezo_layers > 1
    dx=curr_file_struct.dx;
    dy=curr_file_struct.dy;
end
    
for jnd=1:nbr_piezo_layers
    disp(['Now processing z-plane: ' num2str(jnd)]);
    
    
    dx_check=find(abs(dx{jnd}-mean(dx{jnd}))>std_thresh*std(dx{jnd}));
    dy_check=find(abs(dy{jnd}-mean(dy{jnd}))>std_thresh*std(dy{jnd}));
    if ~isempty(dx_check) || ~isempty(dy_check)
        display(['ATTENTION: Large dx or dy shift detected in z-layer ' num2str(jnd) ' - correcting'])
        figure;
        subplot(211)
        plot(dx{jnd},'k');
        hold on;
        plot([1 length(dx{jnd})],[1 1]*(mean(dx{jnd})+std_thresh*std(dx{jnd})),'r--')
        plot([1 length(dx{jnd})],[1 1]*(mean(dx{jnd})-std_thresh*std(dx{jnd})),'r--')
        axis tight
        
        subplot(212)
        hold on;
        plot(dy{jnd},'k');
        plot([1 length(dy{jnd})],[1 1]*(mean(dy{jnd})+std_thresh*std(dy{jnd})),'r--')
        plot([1 length(dy{jnd})],[1 1]*(mean(dy{jnd})-std_thresh*std(dy{jnd})),'r--')
        axis tight
        
        go_on(jnd)=input('Do you want to correct? (1/0): ');
        
                    text(.1,.05,['Exp: ' num2str(ExpID)],'units','normalized','color','k','fontweight','bold','Interpreter','none')
                    text(.1,.95,['z-layer: ' num2str(jnd)],'units','normalized','color','k','fontweight','bold','Interpreter','none')
        
        if go_on(jnd)
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
            subplot(211)
            plot(dx{jnd},'r');
            subplot(212)
            plot(dy{jnd},'r');
        end
    end
end

if sum(go_on)>0
    % load the 2P data
    % pre-allocate space for data
    for knd=1:length(ExpInfo.fnames)
        finfo=dir([ExpInfo.fnames{knd}]);
        fi=fopen([ExpInfo.fnames{knd}],'r');
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
        data=cell(1,nbr_piezo_layers);
        for knd=1:nbr_piezo_layers
            data{knd}=zeros(x_res,y_res,round(number_of_frames_total),'int16');
        end
    end
    
    % load the data
    for ind=1:length(ExpInfo.fnames)
        if exist([ExpInfo.fnames{ind}],'file');
            disp(['loading file ' ExpInfo.fnames{ind} ' from local tmpdata directory']);
            curr_load_path=[ExpInfo.fnames{ind}];
        else
            disp(['loading file ' ExpInfo.fnames{ind} ' from the network RawData directory']);
            curr_load_path=[ExpInfo.fnames{ind}];
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
                data{1}(:,:,knd)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
            end
        end
        fclose(fi);
    end
    if process_sec
        sec_data=load_bin(ExpInfo.sec_fnames,nbr_piezo_layers);
    end

disp(['Now registering data on dx dy values and correcting line shift']);
    if ~isa(dx,'cell')
        data=shift_data(data,dx,dy);
        data=correct_line_shift(data,mean(data,3));
        act_map=calc_act_map(data);
        template=mean(data,3);
        
        if process_sec
            sec_data=shift_data(sec_data,dx,dy);
            sec_data=correct_line_shift(sec_data,mean(sec_data,3));
            act_map_sec=calc_act_map(sec_data);
            sta=1;
            sto=0;
            for pnd=1:size(nbr_frames,2) %for 2ndary channels: calculate template for every stack individually
                sto=sto+nbr_frames(pnd)/length(dx);
                template_sec(:,:,pnd)=mean(sec_data(:,:,sta:sto),3);
                sta=sta+nbr_frames(pnd)/length(dx);
            end
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
                act_map_sec{rnd}=calc_act_map(sec_data{rnd});
                sta=1;
                sto=0;
                for pnd=1:size(nbr_frames,2) %for 2ndary channels: calculate template for every stack individually
                    sto=sto+nbr_frames(pnd)/length(dx);
                    template_sec{rnd}(:,:,pnd)=mean(sec_data{rnd}(:,:,sta:sto),3);
                    sta=sta+nbr_frames(pnd)/length(dx);
                end
            end
        end
        
        
    end
    
    check_registration(dx,dy,template)
    
    try
        if nbr_piezo_layers == 1
            curr_file_struct.dx=cell2mat(dx);
            curr_file_struct.dy=cell2mat(dy);
            curr_file_struct.act_map=cell2mat(act_map);
            curr_file_struct.template=cell2mat(template);
            curr_file_struct.act_map_sec=cell2mat(act_map_sec);
            curr_file_struct.template_sec=cell2mat(template_sec);
        else
            curr_file_struct.dx=dx;
            curr_file_struct.dy=dy;
            curr_file_struct.act_map=act_map;
            curr_file_struct.act_map_sec=act_map_sec;
            curr_file_struct.template_sec=template_sec;
            curr_file_struct.template=template;
        end
    catch
        disp(['Check variable class dx dy'])
    end

    save(fname,'-struct','curr_file_struct','-v7.3');
    
    disp([ datestr(now) '----Done fixing your registration...----']);
else
    disp([ datestr(now) '----Done - no fixing necessary...----']);
end
%EOF