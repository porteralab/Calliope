function [CStr]=getlog(el)
% outputs current console output text
% [el] can be used to index the log output
%
% e.g. 
% getlog(1)     % displays last output
% getlog(1:5)   % displays last 5 outputs
%
% 16.01.2018 FW

doc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;
Str = doc.getText(1, doc.getLength);
CStr=regexp( Str.toCharArray', '\n', 'split')';
CStr=CStr(cellfun(@(x) ~isempty(regexprep(x,' +','')),CStr));

if exist('el','var') && ~isempty(el)
    CStr=CStr(end-el(el<numel(CStr) & el>0)); 
end
end