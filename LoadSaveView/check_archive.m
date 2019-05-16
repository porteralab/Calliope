function check_archive
% displays archive storage usage by user


arc_dirs=folderSizeTree('\\argon.fmi.ch\gkeller.archive\RawData');
cnt=0;
main_dirs=[];

for ind=1:size(arc_dirs.level,2)
    if arc_dirs.level{ind}==1
        cnt=cnt+1;
        main_dirs(cnt)=ind;
    end
end
disp(' ')
disp('-----------------------------------')
disp('Total space used in archive by user')
disp('-----------------------------------')
disp(' ')

for ind=1:length(main_dirs)
    ds=round(arc_dirs.size{main_dirs(ind)}/1e12*100)/100;
    uname=arc_dirs.name{main_dirs(ind)}(40:end);
    prct=round(arc_dirs.size{main_dirs(ind)}/arc_dirs.size{end}*100);
    disp(sprintf([uname ': \t ' num2str(ds) ' TB - ' num2str(prct) '%%']))
end
disp(' ')
disp('-----------------------------------')
disp(['Total: ' num2str(round(arc_dirs.size{end}/1e12*100)/100) ' TB or archive space used'])
disp(' ')