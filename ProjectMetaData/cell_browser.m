function cell_browser(proj_meta,cdisp)
%[] = CELL_BROWSER(proj_meta,cdisp) Browser for project meta data
% 
% -------------------------------------
% proj_meta:     project_meta data file
% cdisp (optional):   display template of ROI (0 - off, 1 - for cells, 2 - for axons 
% Plot cell activity 
% Press 'right arrow' and 'left arrow' to scroll through ROIs
% Press 'alt' - right or left arrow to scroll through sites
% Press 'shift' - right or left arrow to scroll through layers
% Press up or down -arrow to scroll between timepoints
% Select a time & channel window with the mouse and press 'space' to make a
% selection
% s?
% 
%
% "A man who lives in a glass house must dress in the basement"
%                                                  - Confucius
%
% "Man who walkes through a sliding door sideways is going to Bangkok."
%                                                  - Aris
%
% "Only if it is of substantial size"
%                                                  - Anders
% Doc edited by AA, 11.06.14



if nargin < 2
    cbh.cdisp = 1;
else
    cbh.cdisp = cdisp;
end

if ~exist('proj_meta','var'), proj_meta=evalin('base','proj_meta;'); warning('fetching proj_meta from base workspace for you'); end

ExpLog=getExpLog;
adata_dir=set_lab_paths;

cbh.proj_id=ExpLog.project{find(cell2mat(ExpLog.expid)==proj_meta(1).ExpGroup(1),1,'first')};
cbh.acode=num2str(ExpLog.analysiscode{find(cell2mat(ExpLog.expid)==proj_meta(1).ExpGroup(1),1,'first')});
cbh.cba_path=[adata_dir '_CBannotations\'];

cbh.mf=figure('color','k','menubar','none');

cbh.cba_filepath=[cbh.cba_path cbh.proj_id '_' cbh.acode '-cba.mat'];

params.nzlay=4;

cnt_tmp=0;
for ind=1:length(proj_meta)
    tp_tmp(ind)=size(proj_meta(ind).rd,2);
    for knd=1:proj_meta(ind).nbr_piezo_layers
        cnt_tmp=cnt_tmp+1;
        nbrc_tmp(cnt_tmp)=size(proj_meta(ind).rd(knd,1).act,1);
    end
end

cbh.max_nbr_tp=max(tp_tmp);
cbh.max_nbr_cells=max(nbrc_tmp);

if exist(cbh.cba_filepath,'file')==2
    load(cbh.cba_filepath);
else
    params.win_pos=get(gcf,'position');
    
    params.cell_ind=1;
    params.site_id=1;
    params.tp=1;
    params.zl=1;
    params.zon=0;
    
    params.rdfields=fields(proj_meta(params.site_id).rd);
    params.rdfields(strcmp(params.rdfields,'template'))=[];
    params.rdfields(strcmp(params.rdfields,'act_map'))=[];
    params.rdfields(strcmp(params.rdfields,'ROIinfo'))=[];
    params.rdfields(strcmp(params.rdfields,'timepoint'))=[];
    params.rdfields(strcmp(params.rdfields,'piezo_layer'))=[];
    params.rdfields(strcmp(params.rdfields,'fnames'))=[];
    params.rdfields(strcmp(params.rdfields,'nbr_frames'))=[];
    
    params.cell_annotations=cell(length(proj_meta),params.nzlay,cbh.max_nbr_cells);
    params.site_annotations=cell(length(proj_meta),1);
    
    params.chansToPlot=cell(5,1);
    params.chansToPlot{1}=[1];
    params.chansToPlot{2}=[2];
    params.chansToPlot{3}=[3];
    params.chansToPlot{4}=[4];
    params.chansToPlot{5}=[5];

    params.ta_win=50;
end

if ~isfield(params,'colors')
    colors = colormap(hsv);
    colors = colors(1:6:end,:);
    params.colors = colors;
end
params.nzlay=4;

set(cbh.mf,'position',params.win_pos);

cbh.ta=axes('position',[0.95 0.85 0.05 0.15],'color','none');
colormap gray
tmp_im=zeros(2*params.ta_win+1);
imagesc(tmp_im);


cbh.ma=axes('position',[0.06 0 0.94 0.85],'color','k');
ylim([0 5])
hold on

for ind=1:5
    cbh.sel(ind)=uicontrol('style','listbox',...
        'string',params.rdfields,...
        'units','normalized',...
        'value',params.chansToPlot{ind},...
        'position',[0.005 (ind-1)*0.85/5 0.05 0.85/5-0.005],...
        'BackgroundColor',[1 1 1]*0.1,...
        'ForegroundColor','g',...
        'HorizontalAlignment','left',...
        'Min',1,'Max',10);
end

cbh.animal_label=uicontrol('style','text',...
    'string','Animal ID:',...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.075 0.95 0.075 0.05],...
    'HorizontalAlignment','right',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.animal=uicontrol('style','text',...
    'string',proj_meta(params.site_id).animal,...
    'units','normalized',...
    'fontsize',12,...
    'fontweight','bold',...
    'position',[0.16 0.95 0.1 0.05],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.site_label=uicontrol('style','text',...
    'string','Site:',...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.075 0.925 0.075 0.05],...
    'HorizontalAlignment','right',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.site=uicontrol('style','text',...
    'string',params.site_id,...
    'units','normalized',...
    'fontsize',12,...
    'fontweight','bold',...
    'position',[0.16 0.925 0.1 0.05],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.site_anno=uicontrol('style','edit',...
    'string',params.site_annotations{params.site_id},...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.25 0.95 0.3 0.025],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.cell_label=uicontrol('style','text',...
    'string','Cell nbr:',...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.075 0.9 0.075 0.05],...
    'HorizontalAlignment','right',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.cell=uicontrol('style','text',...
    'units','normalized',...
    'fontsize',12,...
    'fontweight','bold',...
    'position',[0.16 0.9 0.1 0.05],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');
if  isfield(proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind),'type')
    set(cbh.cell,'string',[num2str(params.cell_ind) ' / ' num2str(size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1)) ' - layer ' ...
        num2str(params.zl) ' - ' num2str(proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind).type)]);
else
    set(cbh.cell,'string',[num2str(params.cell_ind) ' / ' num2str(size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1)) ' - layer ' ...
        num2str(params.zl)]);
end

cbh.cell_anno=uicontrol('style','edit',...
    'string',params.cell_annotations{params.site_id,params.zl,params.cell_ind},...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.25 0.925 0.3 0.025],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.tp_label=uicontrol('style','text',...
    'string','Time point:',...
    'units','normalized',...
    'fontsize',12,...
    'position',[0.075 0.875 0.075 0.05],...
    'HorizontalAlignment','right',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.tp=uicontrol('style','text',...
    'string',[num2str(params.tp) ' / ' num2str(size(proj_meta(params.site_id).rd,2))],...
    'units','normalized',...
    'fontsize',12,...
    'fontweight','bold',...
    'position',[0.16 0.875 0.1 0.05],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','w');

cbh.save=uicontrol('style','pushbutton',...
    'string','save',...
    'units','normalized',...
    'position',[0.005 0.94 0.05 0.03],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'callback',{@cba_save,cbh});


cbh.update=uicontrol('style','pushbutton',...
    'string','update',...
    'units','normalized',...
    'position',[0.005 0.9 0.05 0.03],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'callback',{@plot_all,cbh,proj_meta});

tempstr = sprintf('Navigation: \n< >   btw cells\nSHIFT + < >   btw layers\nALT + < >   btw sites\n^ v   btw timepoints\nSPACE   selection');
cbh.help_label=uicontrol('style','text',...
    'string',tempstr,...
    'units','normalized',...
    'fontsize',8,...
    'position',[0.6 0.9 0.2 0.1],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','g');

set(cbh.site_anno,'callback',{@site_anno_cb,cbh})
set(cbh.cell_anno,'callback',{@cell_anno_cb,cbh})
set(cbh.mf,'userdata',params,'keypressfcn',{@cb_kpf,cbh,proj_meta},'resizefcn',{@cb_rsf,cbh});
plot_all(0,0,cbh,proj_meta);

function plot_all(hf,e,cbh,proj_meta)

params=get(cbh.mf,'userdata');
for ind=1:5
    params.chansToPlot{ind}=get(cbh.sel(ind),'value');
end

if cbh.cdisp > 0
    ts=size(proj_meta(params.site_id).rd(params.zl,params.tp).template);
    [cx,cy]=ind2sub(ts,proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind).indices);
    if cbh.cdisp == 1
        cx=round(mean(cx));
        cy=round(mean(cy));
        
        % correct if window around the cell is too close to the edge of template
        tmp_im=zeros(2*params.ta_win+1);
        tmp_im(2-min(1,cx-params.ta_win):2*params.ta_win+1+min(0,ts(1)-(cx+params.ta_win)), ...
            2-min(1,cy-params.ta_win):2*params.ta_win+1+min(0,ts(2)-(cy+params.ta_win)))= ...
            proj_meta(params.site_id).rd(params.zl,params.tp).template(max(1,cx-params.ta_win):min(ts(1),cx+params.ta_win), ...
            max(1,cy-params.ta_win):min(ts(2),cy+params.ta_win));
    else
        ROItemp.indices=proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind).indices;
        im=(ROIs2image(ROItemp,ts,'template',proj_meta(params.site_id).rd(params.zl,params.tp).template,'type','fill','singlecolor',[1 0 0]));
        tmp_im=im(min(cx):max(cx),min(cy):max(cy),:);
    end
    set(get(cbh.ta,'children'),'cdata',tmp_im);
    set(cbh.ta,'Color','none')
end
cla
if params.zon
    xlim(sort(params.zxlim));
else
    xlim([0 sum(proj_meta(params.site_id).rd(params.zl,params.tp).nbr_frames)]);
end

for ind=1:5
    for knd=1:length(params.chansToPlot{ind})
        if strcmp(params.rdfields{params.chansToPlot{ind}(knd)},'act')
            cbh.act=plot(ntzo(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:))+ind-1,'w');
        else
            eval(['tmp_trace=proj_meta(' num2str(params.site_id) ').rd(' num2str(params.zl) ',' num2str(params.tp) ').' params.rdfields{params.chansToPlot{ind}(knd)} ';']);
            if size(tmp_trace,1) > 10 
                tmp_trace = tmp_trace';
            end
            if size(tmp_trace,1)==1
                plot(ntzo(tmp_trace)+ind-1,'Color',params.colors(min(ind*2-1+knd-1,10),:))
            elseif size(tmp_trace,1)==2
                plot(ntzo(tmp_trace(1,:))+ind-1,'r')
                plot(ntzo(tmp_trace(2,:))+ind-1,'b')
            end
        end
    end
end

set(cbh.site,'string',params.site_id);
set(cbh.animal,'string',proj_meta(params.site_id).animal);
if isfield(proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind),'type')
    set(cbh.cell,'string',[num2str(params.cell_ind) ' / ' num2str(size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1)) ' - layer ' ...
        num2str(params.zl) ' - ' num2str(proj_meta(params.site_id).rd(params.zl,params.tp).ROIinfo(params.cell_ind).type)]);
else
    set(cbh.cell,'string',[num2str(params.cell_ind) ' / ' num2str(size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1)) ' - layer ' ...
        num2str(params.zl)]);
end
set(cbh.tp,'string',[num2str(params.tp) ' / ' num2str(size(proj_meta(params.site_id).rd,2))]);

set(cbh.site_anno,'string',params.site_annotations{params.site_id});
set(cbh.cell_anno,'string',params.cell_annotations{params.site_id,params.zl,params.cell_ind});

set(cbh.mf,'userdata',params)

function cb_kpf(e,hf,cbh,proj_meta)
do_plot=0;
params=get(cbh.mf,'userdata');
% params.site_id
switch hf.Key
    case 'rightarrow'
        do_plot=1;
        if strcmp('alt',hf.Modifier)
            if params.site_id<length(proj_meta)
                params.site_id=params.site_id+1;
                params.zl=1;
                params.tp=1;
                params.cell_ind=1;
            end
        elseif strcmp('shift',hf.Modifier)
            if params.zl<params.nzlay
                params.zl=params.zl+1;
                params.cell_ind=1;
            end
        else
            params.cell_ind=params.cell_ind+1;
            if params.cell_ind>size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1)
                if params.zl<params.nzlay
                    params.cell_ind=1;
                    params.zl=params.zl+1;
                else
                    params.cell_ind=params.cell_ind-1;
                end
            end
        end
    case 'leftarrow'
        do_plot=1;
        if strcmp('alt',hf.Modifier)
            if params.site_id>1
                params.site_id=params.site_id-1;
                params.zl=1;
                params.tp=1;
                params.cell_ind=1;
            end
        elseif strcmp('shift',hf.Modifier)
            if params.zl>1
                params.zl=params.zl-1;
                params.cell_ind=1;
            end
        else
            params.cell_ind=params.cell_ind-1;
            if params.cell_ind<1
                if params.zl>1
                    params.zl=params.zl-1;
                    params.cell_ind=size(proj_meta(params.site_id).rd(params.zl,params.tp).act,1);
                else
                    params.cell_ind=params.cell_ind+1;
                end
            end
        end
    case 'uparrow'
        do_plot=1;
        if params.tp<size(proj_meta(params.site_id).rd,2)
            params.tp=params.tp+1;
        end
    case 'downarrow'
        do_plot=1;
        if params.tp>1
            params.tp=params.tp-1;
        end
        
    case 'space'
        do_plot=1;
        params.zon=~params.zon;
        if params.zon
            params.zxlim=ginput(2);
            params.zxlim=params.zxlim(:,1)';
        end
    case 's'
        act=proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:);
        sid=proj_meta(params.site_id).rd(params.zl,params.tp).stim_id;
        
        sid=round(10*sid)/10;
        conds=setdiff(unique(sid),0);
        
        win_l=20;
        win_r=30;
        
        for ind=1:length(conds)
            cond_ons{ind}=find(diff(sid==conds(ind))==1);
        end
        
        figure(10)
        clf
        for ind=1:length(conds)
            subplot(1,length(conds),ind)
            hold on
            for knd=1:length(cond_ons{ind})
                plot(act(cond_ons{ind}(knd)-win_l:cond_ons{ind}(knd)+win_r));
            end
            axis tight
            ylim([0.9 max(act)])
        end
        
    case 'v'
        cb_plugin_VML(params,cbh,proj_meta);
       
    case 'm'
        [act_onsets] = cb_plugin_turning(params,cbh,proj_meta);
        
    case 'g'
        cb_plugin_screenshot(params,cbh,proj_meta);
    case 'l'
        cb_plugin_LFM(params,cbh,proj_meta);
    case 'a'
        cb_plugin_ACX(params,cbh,proj_meta);
    case 't'
        % plot activity by traversal as a fct of distance in corridor
        cb_plugin_trav(params,cbh,proj_meta);

    figure(cbh.mf);
end

if do_plot
    set(cbh.mf,'userdata',params)
    plot_all(hf,e,cbh,proj_meta)
end

function cb_rsf(e,hf,cbh)
params=get(cbh.mf,'userdata');
params.win_pos=get(cbh.mf,'position');
set(cbh.mf,'userdata',params)

function cba_save(e,hf,cbh)
params=get(cbh.mf,'userdata');
save(cbh.cba_filepath,'params')
disp(['Saved params to CB annotations file ' cbh.cba_filepath])

function site_anno_cb(e,hf,cbh)
params=get(cbh.mf,'userdata');
params.site_annotations{params.site_id}=get(cbh.site_anno,'string');
set(cbh.mf,'userdata',params)

function cell_anno_cb(e,hf,cbh)
params=get(cbh.mf,'userdata');
params.cell_annotations{params.site_id,params.zl,params.cell_ind}=get(cbh.cell_anno,'string');
set(cbh.mf,'userdata',params)























