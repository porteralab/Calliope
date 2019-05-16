function clean_svn_mathpath
 % clean matlabpath for temporary svn folders
 
 % get path as long string
 p=path;

 % divide string to directories, don't
 % forget the first or the last...
 delim=[0 strfind(p, ';') length(p)+1];

 for i=2:length(delim)
     direc = p(delim(i-1)+1:delim(i)-1);
     if ~isempty(regexp(direc,'.svn'))
         rmpath(direc);
     end
 end