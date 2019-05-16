function unpack_struct(this_struct,ws,msg)
% unpacks structure and assigns fields as variables in workspace
% outputs indicator messeage unless otherwise specified
% usage:
% unpack_struct(proj_meta);
% unpack_struct(proj_meta,[],0);
%
% FW 04.04.2018

if ~exist('ws','var') || isempty(ws), ws='base'; end
if ~exist('msg','var') || isempty(msg), msg=1; end

%convert struct2cell, then assign struct fieldnames as variable names
cellfun(@(x,y) assignin(ws,x,y),fieldnames(this_struct),struct2cell(this_struct));

if msg
    fprintf('assigned vars in %s:\n%s\n',ws,strtrim(strjoin(fieldnames(this_struct),', '))); 
end

end