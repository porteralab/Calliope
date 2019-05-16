function check_registration(dx,dy,template)
% CHECK_REGISTRATION(dx,dy,template) Plot dx and dy values, as well as template image calculated from registration
%
% CHECK_REGISTRATION() Plot dx and dy values from current workspace
% ------------------------------------------------------------------------
% Each row in the plot corresponds to a z layer in the ExpID
% doc edited by AF, 08.05.2014
% doc and code edited by AA, 19.05.2014

if nargin == 0
    dx=evalin('base','dx');
    dy=evalin('base','dy');
    template=evalin('base','template');
    figure
elseif nargin == 1
    %assume that its expid
    ExpID = dx;
    [adata_file,mouse_id,userID] = get_adata_filename(ExpID);
    adata_dir=set_lab_paths;
    adata = load([adata_dir userID '\' mouse_id '\' adata_file]);
    dx = adata.dx;
    dy = adata.dy;
    template = adata.template;
    figure('Name',['Exp ' num2str(ExpID)])

end

if isempty(findobj('type','figure','number',9876))
    activefigure = false;
else
    activefigure = true;
end
figure(9876)
clf
    
if ~isa(dx,'cell')
    im=ntzo(template);
    fac = mean(im(:)) + 4*std(im(:));
    im(im>fac)=fac;
    subplot2(1,2,1,[0.005,0.005]),imagesc(im); colormap gray, axis off, axis tight;
    subplot2(1,2,2,[0.02,0.07]),plot([dx dy]);
    if activefigure
        figpos = get(gcf, 'Position');
        set(gcf, 'Position',[figpos(1:2) 680 160]);
    else
        set(gcf, 'Position',[8 48 680 160]);
    end
    legend('dx','dy','Orientation','hor','Location','northwest')
    legend('boxoff')
else
    nolayers = length(dx);
    
    for ind = 1:nolayers
        im=ntzo(template{ind});
        fac = mean(im(:)) + 4*std(im(:));
        im(im>fac)=fac;
        subplot2(nolayers,2,ind*2-1,[0.005,0.005]),imagesc(im); colormap gray, axis off, axis tight;
        subplot2(nolayers,2,ind*2,[0.02,0.07]),hold on,
        plot(dx{ind});
        plot(dy{ind},'g');
        if ind == 1
            legend('dx','dy','Orientation','hor','Location','northwest')
            legend('boxoff')
        end
    end
    set(gcf, 'Position',[8 48 680 160*nolayers]);
end