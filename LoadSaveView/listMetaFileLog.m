function varargout=listMetaFileLog(searchstr)
% lists all project meta logs
% usage:
% listMetaFileLog('stringtosearch')
% FW2019
mylog=getExpLogMetaDataFiles; tmp=[];
tmp=(table2cell(struct2table(mylog)));
if exist('searchstr','var') && ~isempty(searchstr)
    tmp=tmp(any(~cellfun('isempty',regexpi(tmp,searchstr)),2),:,:);
    d=cell2table(tmp,'VariableNames',fieldnames(mylog)');
else
    d=struct2table(mylog);
end
disp(d);

if nargout>0, varargout{1}=tmp; varargout{2} = mylog; end
end