function corrupt_files=check_mat_files(dir_to_check)
% checks if mat files load


adata_dir=set_lab_paths;
%dir_to_check=[adata_dir '_metaData\'];

if nargin<1
    dir_to_check=[adata_dir 'fisearis\'];
end

   

%files_to_check={'A1V1_3_popeye2.mat','A1V1_RsC_axons_v4.mat','A1V1_axons_4_eye.mat','ARWnoEye.mat','HTM_4_meta.mat','LOA_2_meta.mat','M1_151_meta.mat','M1_L23_meta.mat','M1_Rbp4_meta.mat','NKO_1_meta.mat','PSN_1_meta.mat','PVI_14_meta.mat','PVI_77_meta.mat','PVI_7_meta.mat'};


dirs=dir(dir_to_check);
corrupt_files={};

cnt=0;

for ind=3:length(dirs)
    files=dir([dir_to_check dirs(ind).name]);
    
    for knd=3:length(files)
        if strcmp(files(knd).name(end-3:end),'.mat')
            lastwarn('')
            %if sum(strcmp(dirs(ind).name,files_to_check))
%             disp([num2str(ind) ' - ' dirs(ind).name ' - ' files(knd).name]);
            S=whos('-file',[dir_to_check dirs(ind).name '\' files(knd).name]);
            %end
            if ~isempty(lastwarn)
                cnt=cnt+1;
                disp([num2str(ind) ' - ' dirs(ind).name ' - ' files(knd).name]);
                corrupt_files{cnt}=[dir_to_check dirs(ind).name '\' files(knd).name];
            end
        end
        
    end
end

