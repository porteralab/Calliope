function ori_temp(ExpID)
% displays template image of given expid. Useful for chronic realignement
% and comparison with an average image of show_last_stack
adata_dir=set_lab_paths;
[adata_file,mouse_id,userID]=find_adata_file(ExpID,adata_dir);

if isempty(adata_file)
    disp('No Adata file found')
    return
end

curr=load([adata_dir userID '\' mouse_id '\' adata_file],'template');

lims=[];
for knd=1:4
    lims(knd,:)=[min(curr.template{knd}(:)) max(curr.template{knd}(:))];
end
lims=min(lims);
lims(1,2)=lims(1,2)-abs(diff(lims))*0.2;

h=figure;
set(gcf,'pos',[10         598        1902         388])
hold on
for knd=1:4
    axes('position',[0+(0.25*(knd-1)) 0 0.25 1]);
    imagesc(curr.template{knd})
    axis off
    colormap gray
    set(gca,'clim',lims)
end
set(h, 'MenuBar', 'none');
set(h, 'ToolBar', 'none');

