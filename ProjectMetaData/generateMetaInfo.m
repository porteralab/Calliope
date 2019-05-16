function generateMetaInfo(projID,newfile)
%generateMetaInfo(projID,newfile)
% generates MetaInfo excel file for a project
% projID is the project identifier, e.g. 'OMM'
% newfile (optional): 0 or 1, possibility to append, 0 appends 
%
% ML - 15.06.2015
% GK - 30.12.2014

if nargin<2
    newfile = 1; 
end
ExpLog=getExpLog;
adata_dir=set_lab_paths;
fn=[adata_dir '_metaInfo\MetaInfo-' projID '.xlsx'];

if exist(fn,'file') == 2 && ~newfile 
    [~,~,raw] = xlsread(fn);
    OldExpIds = cell2mat(raw(2:end,1));
    newfile = 0;
else
    newfile = 1;
end

projExps=unique(cell2mat(ExpLog.expid(strcmp(ExpLog.project,projID))));

if ~newfile
    projExps = setdiff(projExps,OldExpIds);
    if isempty(projExps)
        disp('No new ExpID found to append.');
        return
    end
end

for ind=1:length(projExps)
    ExpLogInd(ind)=find(cell2mat(ExpLog.stackid)==projExps(ind));
end


data_to_write{1,1}='ExpID';
data_to_write{1,2}='SiteID';
data_to_write{1,3}='AnimalID';
data_to_write{1,4}='Date';
data_to_write{1,5}='timepoint';
data_to_write{1,6}='Acode';
data_to_write{1,9}='comment';

data_to_write(2:length(ExpLogInd)+1,1)=ExpLog.expid(ExpLogInd);
data_to_write(2:length(ExpLogInd)+1,2)=ExpLog.siteid(ExpLogInd);
data_to_write(2:length(ExpLogInd)+1,3)=ExpLog.animalid(ExpLogInd);
data_to_write(2:length(ExpLogInd)+1,4)=ExpLog.stackdate(ExpLogInd);
data_to_write(2:length(ExpLogInd)+1,5)=mat2cell(zeros(length(projExps),1),ones(length(projExps),1),1);
data_to_write(2:length(ExpLogInd)+1,6)=ExpLog.analysiscode(ExpLogInd);
data_to_write(2:length(ExpLogInd)+1,9)=ExpLog.analysiscode(ExpLogInd);

if ~newfile
    data_to_write(2:end,size(data_to_write,2)+1:size(raw,2)) = {'N/A'};   
    raw = vertcat(raw,data_to_write(2:end,:));
    xlswrite(fn,raw);
elseif newfile && exist(fn,'file')==2
    disp('file already exists - please delete manually first if you really want to overwrite')
    return
else
    xlswrite(fn,data_to_write);
end




