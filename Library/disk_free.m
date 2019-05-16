function [free_bytes,total_bytes,usable_bytes] = disk_free( path )
%DISK_FREE return free disk space for specified folder in bytes (double)
% INPUT ARGUMENTS:
% * path - string, existing file or folder path.
% 
% USAGE:
% * disk_free('C:\temp');       % regular usage 
% * disk_free('C:\temp\1.txt'); % path points to a file 
% * disk_free('\\?\C:\temp');   % UNC path 
% * disk_free('\\\\C:\temp');   % UNC path with with java-style prefix
% * disk_free('\\IMP\Ctemp');   % samba share folder
% 
% INVALID USAGE:
% * disk_free('\\IMP');         % samba share root 
% * disk_free('C');             % should use 'C:' instead
% 
% NOTE:
% Would result in an error for an empty DVD-rom drive (disk not inserted).
% And similar cases.


assert(...
          ischar(path) && ndims(path)<=2 && size(path,1)==1,...
          'disk_free:NotString',...
          '%s','Provided input is not a sting'....
       );

   
exist_code = exist(path,'file');
assert(...
          exist_code==2 || exist_code==7 ,...
          'disk_free:BadPath',...
          '%s',['Path "' path '" is invalid or does not exist']...
      );


if length(path)>=4 && strcmp(path(1:4),'\\?\')
    path(1:4)='\\\\';
end

% It's NOT OK to use strrep, since if UNC prefix is not in the beginning 
% of the 'path' string, the path is invalid, and it may become 'valid'.
% path = strrep(path,'\\?\','\\\\');

FileObj = java.io.File(path);
free_bytes = FileObj.getFreeSpace;
total_bytes = FileObj.getTotalSpace;
usable_bytes = FileObj.getUsableSpace;


end