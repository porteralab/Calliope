function []=check_siteROIs(siteID,Acode,show_figs)
% check_siteROIs(siteID,Acode,show_figs)
% checks the alignment of the ROIs of one site across different time points
% siteID: the site ID as in the ExpLog database
% Acode: the analysis code as entered in ExpLog, default is 0
% GK - 22.04.2013
% modified PZ 2015-12-14 restricted adata load to relevant subfields
% modified FW 2018-03-12 added calliope-window interaction

if (nargin==0 || isempty(siteID) || siteID==0) && ishandle(1001) %load siteID directly from open calliope window
    siteID=str2double((regexp(handle(1001).Children(15).String{handle(1001).Children(15).Value},'(?<= - )[0-9]*','match','once')));
    warning('loading siteID (%d) from open calliope window',siteID);
end

if nargin<2 || isempty(Acode)
    Acode = 0;
end
if nargin<3
    show_figs=1;
end

adata_dir=set_lab_paths;
rd_dir = get_data_path(siteID);

ExpLog = getExpLog;

cur_exps=unique(cell2mat(ExpLog.expid(cell2mat(ExpLog.siteid)==siteID)));

if isempty(cur_exps)
    disp('Site ID not found in DB')
    return
end

use_exps=zeros(length(cur_exps),1);

if Acode~=0
    for jnd=1:length(cur_exps)
        try
            if str2num(ExpLog.analysiscode{find(cell2mat(ExpLog.expid)==cur_exps(jnd),1,'first')})==Acode
                use_exps(jnd)=1;
            end
        end
    end
    cur_exps(~logical(use_exps))=[];
end


if isempty(cur_exps)
    disp('Site found, but no experiments with this Adata code')
    return
end

ExpIDs=cur_exps;

animalIDtxt=ExpLog.animalid{min(find(cell2mat(ExpLog.siteid)==siteID))};
regionIDtxt=ExpLog.comment{min(find(cell2mat(ExpLog.siteid)==siteID))};

for ind=1:length(ExpIDs)
    stackDates{ind}=ExpLog.stackdate{min(find(cell2mat(ExpLog.expid)==ExpIDs(ind)))};
end

disp('--------------------------------------------------------------------')
disp(sprintf('Animal %s  -  site %i  -  %s',animalIDtxt,siteID,regionIDtxt));
disp('--------------------------------------------------------------------')

for ind=1:length(ExpIDs)
    [adata_file,mouse_id,userID]=get_adata_filename(ExpIDs(ind),adata_dir,ExpLog);
    if ~isempty(adata_file) && isempty(strfind(adata_file,'mean_data'))
        tmp=load([adata_dir userID '\' mouse_id '\' adata_file],'ROIs','template','act_map','fnames');
        tmpadata.ROIs=tmp.ROIs;
        tmpadata.template=tmp.template;
        tmpadata.act_map=tmp.act_map;
        tmpadata.fnames=tmp.fnames;
        tmpadata.acode=ExpLog.analysiscode{find([ExpLog.expid{:}]==ExpIDs(ind))};
        if ~iscell(tmpadata.ROIs)
            tmp=tmpadata.ROIs;
            tmpadata=rmfield(tmpadata,'ROIs');
            tmpadata.ROIs=cell(4,1);
            tmpadata.ROIs{1}=tmp;
            tmp=tmpadata.template;
            tmpadata=rmfield(tmpadata,'template');
            tmpadata.template=cell(4,1);
            tmpadata.template{1}=tmp;
            tmp=tmpadata.act_map;
            tmpadata=rmfield(tmpadata,'act_map');
            tmpadata.act_map=cell(4,1);
            tmpadata.act_map{1}=tmp;
        end
        adata(ind)=tmpadata;
        fprintf('t: %2i \t expID: %i \t %s \t # ROIs: %2i %2i %2i %2i - %2i - ''%3s'' - ''%s'' \n',ind,ExpIDs(ind),datetime(stackDates{ind},'Format','dd.MM.yyyy'),length(adata(ind).ROIs{1}),length(adata(ind).ROIs{2}),length(adata(ind).ROIs{3}),length(adata(ind).ROIs{4}),isfield(adata(ind).ROIs{1},'activity'),adata(ind).acode,cell2mat(getfield({ExpLog.comment{[ExpLog.expid{:}]==ExpIDs(ind)}}',{1})));
    else
        disp([num2str(ExpIDs(ind)) ' has not been registerd yet or is a zstack']);
    end
end

try
    nbr_piezo_layers=readini([rd_dir userID '\' mouse_id '\' adata(1).fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
catch err
    if strcmp(err.identifier,'MATLAB:FileIO:InvalidFid')
        %this error might be due to new/old path management
        try
            nbr_piezo_layers=readini([adata(1).fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
        catch err
            if  strcmp(err.identifier,'MATLAB:FileIO:InvalidFid') %this error is probably when adata is old and new data is located in a different location
                data_dir=get_data_path(siteID);
                fnames=regexprep((adata(1).fnames),'.*RawData\\',strrep(data_dir,'\','\\'),'ignorecase'); %replace data_dir with dir get_data_path
                nbr_piezo_layers=readini([fnames{1}(1:end-3) 'ini'],'piezo.nbrlayers');
            else
                error('couldn''t open *ini file.')
            end
        end
    else
        nbr_piezo_layers=4;
        disp(['ATTENTION - could not read nbr of piezo layers from ini file -- ' userID '\' mouse_id])
    end
end

if length(ExpIDs)<3
    num_rows=1;
elseif length(ExpIDs)<9
    num_rows=2;
else
    num_rows=3;
end
num_cols=ceil(length(ExpIDs)/num_rows);

if show_figs
    for jnd=1:nbr_piezo_layers
        
        figure;
        set(gcf,'color','k')
        colormap gray
        cnt=0;
        
        for knd=num_rows:-1:1
            for ind=1:num_cols
                cnt=cnt+1;
                try
                    axes('position',[1/num_cols*(ind-1) 1/num_rows*(knd-1) 1/num_cols 1/num_rows],'color','k');
                    if length(adata(cnt).ROIs{jnd}) > 1
                        imgout=ROIs2image(adata(cnt).ROIs{jnd},size(adata(cnt).template{jnd}),'template',adata(cnt).template{jnd},'type','perim','singlecolor',[1 0 0]);
                        imagesc(imgout);
                    else
                        fakeROIs.indices=1;
                        imgout=ROIs2image(fakeROIs,size(adata(cnt).template{jnd}),'template',adata(cnt).template{jnd},'type','perim','singlecolor',[1 0 0]);
                        imagesc(imgout);
                    end
                    if cnt==1
                        text(.1,.125,'Template','units','normalized','color','w','fontweight','bold','Interpreter','none')
                        text(.1,.05,[animalIDtxt ' ' num2str(jnd)],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    end
                    text(.1,.95,[stackDates{cnt}],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    text(.8,.95,num2str(cur_exps(cnt)),'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    axis off
                end
            end
        end
        
        
        figure;
        set(gcf,'color','k')
        colormap gray
        cnt=0;
        
        for knd=num_rows:-1:1
            for ind=1:num_cols
                try
                    cnt=cnt+1;
                    axes('position',[1/num_cols*(ind-1) 1/num_rows*(knd-1) 1/num_cols 1/num_rows],'color','k');
                    if length(adata(cnt).ROIs{jnd}) > 1
                        imgout=ROIs2image(adata(cnt).ROIs{jnd},size(adata(cnt).act_map{jnd}),'template',adata(cnt).act_map{jnd},'type','perim','singlecolor',[1 0 0]);
                        imagesc(imgout);
                    else
                        fakeROIs.indices=1;
                        imgout=ROIs2image(fakeROIs,size(adata(cnt).act_map{jnd}),'template',adata(cnt).act_map{jnd},'type','perim','singlecolor',[1 0 0]);
                        imagesc(imgout);
                    end
                    if cnt==1
                        text(.1,.125,['Activity Map'],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                        text(.1,.05,[animalIDtxt ' ' num2str(jnd)],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    end
                    text(.1,.95,[stackDates{cnt}],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    text(.8,.95,num2str(cur_exps(cnt)),'units','normalized','color','w','fontweight','bold','Interpreter','none')
                    axis off
                end
            end
        end
        if length(adata(1).ROIs{1})>1
            figure;
            set(gcf,'menubar','none')
            set(gcf,'color','k')
            cnt=0;
            cntall=0;
            tmpall=zeros(size(adata(1).act_map{1}));
            for knd=num_rows:-1:1
                for ind=1:num_cols
                    try
                        cnt=cnt+1;
                        axes('position',[1/num_cols*(ind-1) 1/num_rows*(knd-1) 1/num_cols 1/num_rows],'color','k');
                        
                        tmp=zeros(size(adata(cnt).act_map{jnd}));
                        
                        for lnd=1:length(adata(cnt).ROIs{jnd})
                            cntall=cntall+1;
                            tmp(adata(cnt).ROIs{jnd}(lnd).indices)=lnd;
                            tmpall(adata(cnt).ROIs{jnd}(lnd).indices)=cnt;
                        end
                        
                        imagesc(tmp);
                        
                        
                        if cnt==1
                            text(.1,.125,['ROIs'],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                            text(.1,.05,[animalIDtxt ' ' num2str(jnd)],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                        end
                        text(.1,.95,[stackDates{cnt}],'units','normalized','color','w','fontweight','bold','Interpreter','none')
                        text(.8,.95,num2str(cur_exps(cnt)),'units','normalized','color','w','fontweight','bold','Interpreter','none')
                        axis off
                    end
                end
            end
            figure;
            set(gcf,'menubar','none')
            axes('position',[0 0 1 1],'color','k');
            imagesc(tmpall)
        end
        
    end
    
end
disp('Done checking site ROIs.')