function save_check_registration_figure(adata_dir,ExpInfo)

im_files=dir([adata_dir '_AnimalData\' ExpInfo.userID '\' ExpInfo.mouse_id '\2P_Registration\CheckReg-' num2str(ExpInfo.site_id) '*']);

if ~isempty(im_files)
    for ind=1:length(im_files)
        file_ind(ind)=str2num(im_files(ind).name(length(['CheckReg-' num2str(ExpInfo.site_id)])+3));
    end
    new_file_ind=max(file_ind)+1;
else
    new_file_ind=0;
end

try
    if ~isdir([adata_dir '_AnimalData\' ExpInfo.userID '\' ExpInfo.mouse_id '\2P_Registration'])
        mkdir([adata_dir '_AnimalData\' ExpInfo.userID '\' ExpInfo.mouse_id '\'], '2P_Registration')
    end
    saveas(9876,[adata_dir '_AnimalData\' ExpInfo.userID '\' ExpInfo.mouse_id '\2P_Registration\CheckReg-' num2str(ExpInfo.site_id) '_v' num2str(new_file_ind) '.png']);
    close(9876);
catch
    disp('Something went wrong with autosaving your check registration figure');
end