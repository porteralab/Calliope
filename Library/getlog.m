function [CStr]=getlog()
% outputs current console output text
% 16.01.2018 FW
doc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;
Str = doc.getText(1, doc.getLength);
CStr=regexp( Str.toCharArray', '\n', 'split')';
CStr=CStr(cellfun(@(x) ~isempty(regexprep(x,' +','')),CStr));
end