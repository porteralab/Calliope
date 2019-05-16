function resave_adata(username)

% Obsolete?
adata_dir=set_lab_paths;

[xls_num,xls_txt]=xlsread('\\argon.fmi.ch\keller.g\ExpLog\Stacks.xlsx');
expIDs=[];
cnt=1;
for ynd=1:size(xls_num,1)
    if ~isempty(strfind(xls_txt{ynd+1,10},username))
        expIDs(ynd)=xls_num(ynd,2);
    end
end
expIDs(expIDs==0)=[];
expIDs=unique(expIDs);
for hnd=1:length(expIDs)
    display([num2str(expIDs(hnd))])
    [adata_file,mouse_id,userID]=find_adata_file(expIDs(hnd),adata_dir);
    if expIDs(hnd)>3800
        if ~isempty(adata_file)
            orig=load([adata_dir userID '\' mouse_id '\' adata_file]);
            save_adata2(adata_dir,orig.ROIs,orig.bv,orig.np,orig.template,orig.dx,orig.dy,orig.aux_files,orig.fnames,orig.nbr_frames,orig.mouse_id,userID,orig.act_map)
        else
            display(['no adata file found for exp ' num2str(expIDs(hnd))])
        end
    end
end