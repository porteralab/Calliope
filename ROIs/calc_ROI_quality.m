function calc_ROI_quality(ExpID,adata_dir,cah,calc_on_ch)
% calculates and saves ROI quality (defined as mean pair-wise pixel acttivity correlation)
% FW 2019

evalin('base','load_noregister=0;') %to avoid accidental loading without registration

ud = get(cah.hf,'UserData');
data_dir=get_data_path(ExpID);
ExpInfo = read_info_from_ExpLog(ExpID,1);

if nargin<4
    calc_on_ch=1;
end

% find the adata file
[adata_file,mouse_id,userID]=find_adata_file(ExpID,adata_dir);

if isempty(adata_file)
    disp('Found no Adata file - register data and select ROIs first');
    return
end

if ~strcmp('Adata',adata_file(1:5))
    disp('This is probably a Z stack - aborting calc act.')
    return;
end

% load the analyzed data
load([adata_dir '\' userID '\' mouse_id '\' adata_file]);

if isa(ROIs,'cell')
    
    for ynd=1:length(ROIs)
        nROIs(ynd)=size(ROIs{ynd},2);
    end
    if sum(nROIs==1)==length(nROIs)
        disp('No ROIs selected - select ROIs before calculating ROI quality')
        return;
    end
    nL=length(ROIs);
    calculated = false(1,nL);
    for iLayer=1:nL
        calculated(iLayer)=isfield(ROIs{iLayer},'quality');
    end
    if nnz(calculated)==nL
        disp('ROI quality already calculated');
%         return;
    end
else
    if length(ROIs)==1
        disp('No ROIs selected - select ROIs before calculating ROI quality')
        return;
    elseif isfield(ROIs,'quality')
        disp('ROI quality already calculated');
%         return;
    end
end

ExpLog=getExpLog;
[adata_file,mouse_id,userID,projID]=get_adata_filename(ExpID,adata_dir,ExpLog);
[pdef]=getProjDef(projID);

if calc_on_ch==1
    ftypes={'.lvd' [pdef.main_channel(3:end) '.bin']};
else
    ftypes={'.lvd' [pdef.secondary_channels{1}(3:end) '.bin']};
end

load_exp(ExpID,adata_dir,ftypes,ExpLog,'caller');

disp('Calculating ROI quality');
if isa(ROIs,'cell')
    for qnd=1:length(ROIs)
        if isfield(ROIs{qnd},'indices')
            if calc_on_ch==1
                ROIs_qual=ROI_quality(data{qnd},ROIs{qnd});
                data{qnd}=[];
            else
                ROIs_qual=ROI_quality(sec_data{qnd},ROIs{qnd});
                data{qnd}=[];
            end
            ROIs{qnd}=ROIs_qual;
        end
    end
else
    ROIs=ROI_quality(data,ROIs);
end

save([adata_dir '\' userID '\' mouse_id '\Adata-S1-T' num2str(ExpID)],'ROIs','bv','np','-append');

disp('----Done calculating ROI quality of Exp!----');
%EOF