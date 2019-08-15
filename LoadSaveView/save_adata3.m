function save_adata3(ExpID,varargin)
% save any variable from workspace to adata file. uses qexp.
%
% FW 2019

q=qexp(ExpID);
[adata_dir,userID,mouse_id,fn]=deal(set_lab_paths,q.pi{1},q.animalid{1},['Adata-S1-T' num2str(ExpID) '.mat']);

%make dir if it doesn't exist
if ~isdir([adata_dir userID '\' mouse_id])
    mkdir([adata_dir userID], mouse_id);
end

path = [adata_dir userID filesep mouse_id filesep fn];

%get variables from 'base' workspace
cellfun(@(x) assignin('caller',x,evalin('base',x)),varargin(logical(cell2mat({cellfun(@(x) evalin('base',['exist(''' x ''',''var'')']),varargin)}))),'uni',0);

save(path,varargin{:},'-append');

%saved message
fprintf('Saved variables {'); fprintf('''%s'', ',varargin{:}); fprintf('\b\b} to Adata file\n')