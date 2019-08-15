function check_disk_usage
% displays free and total disk space on temp and backup locations
% GK 14.01.2014


[~,backup_paths]=define_backup_paths;

sep_str='------------------------';

user_data{1,1}='kellgeor';
user_data{1,2}=0;

wbh=waitbar(0,'Collecting disk usage by user');

for ind=1:size(backup_paths,1)
    user_dirs=dir(backup_paths{ind,1});
    for knd=3:size(user_dirs,1)
         [~,output]=system(['powershell -noprofile -command "ls -Path "' backup_paths{ind,1} '\' user_dirs(knd).name '" -r|measure -s Length"']);
         start_ind=regexp(output,'Sum      : ','end');
         stop_ind=regexp(output,'Maximum  :');
         curr_size=str2num(output(start_ind+1:stop_ind-2));
         if isempty(curr_size)
             curr_size=0;
         end
         
         user_data_ind=strcmp(user_dirs(knd).name,user_data(:,1));
         
         if sum(user_data_ind)>0
             user_data{find(user_data_ind),2}=user_data{find(user_data_ind),2}+curr_size;
         else
             user_data{end+1,1}=user_dirs(knd).name;
             user_data{end,2}=curr_size;
         end
    end
    waitbar(ind/size(backup_paths,1),wbh);
end

close(wbh);

user_data(:,1)= pad(user_data(:,1));
[~,sort_ind]=sort(user_data(:,1));

disp(sep_str)
disp('Total disk usage by user')
disp(sep_str)

for ind=sort_ind'
    disp(sprintf([user_data{ind,1} '\t' num2str(round(user_data{ind,2}/1e11)/10) ' TB']))
end
disp(sep_str)
