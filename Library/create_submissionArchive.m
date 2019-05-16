function create_submissionArchive(ProjID,meta_data_ver,submissionNumber)
% creates a zip file containing the meta file and all code necessary to
% generate the figures of a submission
% requires a generate_ProjID_figures function (or m-file) that generates 
% all figures of a project
%
% GK - 10.07.2014

main_fig_function=['generate_' ProjID '_figures'];

if ~exist(main_fig_function,'file')
    disp('ERROR - please generate a generate_ProjID_figures.m function that generates');
    disp('all your figures for the submission before running this function');
    return
end

adata_dir=set_lab_paths;

meta_file=[adata_dir '_metaData\' ProjID '_' num2str(meta_data_ver) '_meta.mat'];

disp('Compiling list of dependent functions - this will take a few minutes')

%list_of_funs=depfun(main_fig_function,'-quiet');

list_of_funs=matlab.codetools.requiredFilesAndProducts(main_fig_function);


for ind=1:length(list_of_funs)
    if strcmp(list_of_funs{ind}(1:8),'C:\Code\');
        isnot_builtin(ind)=1;
    else
        isnot_builtin(ind)=0;
    end
end

list_of_funs=list_of_funs(find(isnot_builtin));
list_of_funs{end+1}=meta_file;

target_folder=[adata_dir '_submissionArchive\' ProjID '_archive_submission_' num2str(submissionNumber) '\'];

disp('----------------------------')
disp('Creating submission archive:')
disp(target_folder)
disp('----------------------------')
disp('containing the following files:')
disp(list_of_funs)
disp('----------------------------')
go_on=input('do you want to proceed? (1/0): ');

if go_on
    if exist('target_folder','dir')
        disp('Folder already exists! Aborting');
        return
    end
    mkdir(target_folder)
    for ind=1:length(list_of_funs)
        copyfile(list_of_funs{ind},target_folder);
    end

end

