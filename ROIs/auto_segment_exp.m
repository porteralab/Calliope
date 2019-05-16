function [] = auto_segment_exp(ExpID)
% [] = auto_segment_exp(ExpID)

adata_dir=set_lab_paths;

ExpInfo = read_info_from_ExpLog(ExpID,1);
[adata_file,mouse_id,userID] = find_adata_file(ExpID,adata_dir);
fname = [adata_dir userID '\' mouse_id '\' adata_file];
curr_file_struct = load(fname);


try
    nbr_piezo_layers=readini([ExpInfo.fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
catch
    nbr_piezo_layers=1;
    disp('ATTENTION - could not read nbr of piezo layers from ini file')
end

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
    data=zeros(x_res,y_res,number_of_frames_total,'int16');
end

% load the data
for ind=1:length(ExpInfo.fnames)
    if exist([ExpInfo.fnames{ind}],'file');
        disp(['loading file ' ExpInfo.fnames{ind} ' from local tmpdata directory']);
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
        disp('Warning - function not implemented for single piezo layer data yet')
        return
        
        for knd=sum(nbr_frames(1:ind-1))+1:sum(nbr_frames(1:ind))
            data(:,:,knd)=reshape(fread(fi,y_res*x_res,'int16=>int16'),y_res,x_res)';
        end
    end
    fclose(fi);
end

if nbr_piezo_layers<2
    % not implemented yet
    
elseif nbr_piezo_layers > 1
    
    % use ICA (Schnitzer) to estimate ROIs
    ROIs = auto_segmentation(data,curr_file_struct.dx,curr_file_struct.dy,[],[],[],[],[],[]);
end


curr_file_struct.ROIs=ROIs;
save(fname,'-struct','curr_file_struct','-v7.3');

disp('----Done auto segmenting...----');
%EOF