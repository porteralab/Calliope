function check_disk_space
% displays free and total disk space on temp and backup locations
% GK 14.01.2014


[tmp_paths,backup_paths,archive_path]=define_backup_paths;

sep_str='------------------------------------------------------';

disp(sep_str)
for ind=1:size(tmp_paths,1)
    try
        [free_bytes(ind),total_bytes(ind)] = disk_free(tmp_paths{ind,1});
        disp(sprintf(['---- ' tmp_paths{ind,2} ':\t\t' num2str(round(free_bytes(ind)/1e11)/10,3)...
            ' TB\t of \t' num2str(round(total_bytes(ind)/1e12)) ' TB free   \t(' num2str(round(100*free_bytes(ind)/total_bytes(ind))) ' %%)']))
    catch
        disp([tmp_paths{ind,2} ' is not available']);
    end
end

disp(sep_str)

for ind=1:size(backup_paths,1)
    try
        [free_bytes(ind),total_bytes(ind)] = disk_free(backup_paths{ind,1});
        disp(sprintf(['---- ' backup_paths{ind,2} ':\t\t' num2str(round(free_bytes(ind)/1e11)/10,3)...
            ' TB\t of \t' num2str(round(total_bytes(ind)/1e12)) ' TB free   \t(' num2str(round(100*free_bytes(ind)/total_bytes(ind))) ' %%)']))
    catch
        disp([backup_paths{ind,2} ' is not available']);
    end
end

disp(sep_str)

disp(sprintf(['---Total: \t\t' num2str(round(sum(free_bytes)/1e12))...
    ' TB\t of \t' num2str(round(sum(total_bytes)/1e12)) ' TB free \t(' num2str(round(100*sum(free_bytes)/sum(total_bytes))) ' %%)']))

disp(sep_str)