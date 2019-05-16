function set_adata_code_batch(projID)
%set_adata_code_batch(projID)
% batch update of Acode in db based on excel MetaInfo file
% ML

adata_dir=set_lab_paths;

fn=[adata_dir '_metaInfo\MetaInfo-' projID '.xlsx'];
if exist(fn,'file')==2
    [~,~,raw] = xlsread(fn);
else
    return
end
if ~isempty(find(strcmp(raw(1,:),'ExpID')))
    ExpIDCol = find(strcmp(raw(1,:),'ExpID'));
else
    return
end
if ~isempty(find(strcmp(raw(1,:),'Acode')))
    AcodeCol = find(strcmp(raw(1,:),'Acode'));
else
    return
end

ExpIds = cell2mat(raw(2:end,ExpIDCol));
Acode = cell2mat(raw(2:end,AcodeCol));
Acode = cellstr(num2str(Acode));
Acode = strrep(Acode,'NaN','');


ButtonName = questdlg(['Going to update all Acode for project ''' projID ''', this will lead to actual changes in the Database?']);

if strcmp(ButtonName,'Yes')

    DB=connectToExpLog;
    
    for ind=1:length(ExpIds)
        sql=['UPDATE Experiments SET Experiments.AnalysisCode = ''' strtrim(cell2mat(Acode(ind))) ''' WHERE Experiments.ExpID = ' num2str(ExpIds(ind))];
        ExpLog = adodb_query(DB, sql);
    end
    
else
    disp('Aborted - nothing was changed');
end