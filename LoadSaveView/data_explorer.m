function data_explorer(aux_data,ROIs,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data explorer
%
% input is always in pairs
% data_explorer(aux_data,ROIs,data1,frame_times1,data2,frame_times2,...), where 
% data: MxNxT image stack
% frame_times: frame times of data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


n_stacks = (nargin-2)/2;

for ind = 1:n_stacks
    stacks{ind} = varargin{2*ind-1};
    frametimes{ind} = varargin{2*ind};
   disp([' size ' num2str(ind) ' ' num2str(size(frametimes{ind}))]);
end

n_cells = length(ROIs);
% act_mat = zeros(length(ROIs(1).activity),n_cells);
% for ind = 1:n_cells
%     act_mat(:,ind) = ROIs(ind).activity;
% end

subsample_factor=10;

aux_data_plot = aux_data(:,1:subsample_factor:end);


for ind = 1:n_stacks
    
    hf(ind) = figure;
    clf;
    params(ind).button_down = 0;
    params(ind).movie_status = 0;
    params(ind).frame_pause = 0.01; % pause in seconds between frames in playback
    params(ind).playback_spacing = 1; % only every n-th frame is shown during playback default = 1 (every frame)
    params(ind).as_ind = 0; % index over area-selected for plotting activity
    params(ind).nbr_avg_frames = 1;
    params(ind).sup_fig_h = -1;
    params(ind).sup_fig2_h = -1;
    params(ind).roish = [];
    
    dimensions(ind+1,:) = size(stacks{ind});
    
    mon_pos = get(0,'monitorpositions');

    offset = 100;
    
    set(hf(ind),'Position',[offset+mon_pos(end,1)+sum(dimensions(1:ind,2))+ind*20 3*offset dimensions(ind+1,2) 1.03*dimensions(ind+1,1)]);
    frame_ind = 1;
    
    template = stacks{ind}(:,:,round(size(stacks{ind},3)/2));
    low_contrast_lim = prctile(reshape(template,numel(template),1),10);
    high_contrast_lim = prctile(reshape(template,numel(template),1),99.99);
    
    params(ind).clim = [low_contrast_lim high_contrast_lim];
    params(ind).h_f_ax = axes('position',[0 0.03 1 0.97],'color','k','clim',params(ind).clim);
    params(ind).h_im_data = imagesc(stacks{ind}(:,:,frame_ind));
    
    yl = ylim;xl = xlim;
    params(ind).h_txt = text(xl(2)/20,yl(2)/20,'1','fontsize',12,'color','w','fontweight','bold');
    
    colormap(gray);
    
    h_sl_ax(ind) = axes('position',[0 0 1 0.03],'color','k');
    xlim([0 1]);
    ylim([0 1]);
    hold on;
    sl_x_pos = 0;
    h_sl_bar(ind) = plot([1 1]*sl_x_pos,[0 1],'r','linewidth',20);
end

hf(n_stacks+1) = figure('position',[min(mon_pos(:,1))+20 250 3700 500],'color','k');
% params(n_stacks+1).roi_ax = axes('position',[0 0 1 0.5],'color','k');
% imagesc(act_mat')
% axis off
params(n_stacks+1).aux_ax = axes('position',[0 0 1 1],'color','k');


hold on
mxa = max(aux_data_plot');
mia = min(aux_data_plot');
cnt = 0;
for ind = [4 5 3]
    cnt = cnt+1;
    plot((aux_data_plot(ind,:)-mia(ind))/(mxa(ind)-mia(ind))+cnt+3);
end
params(n_stacks+1).pos_ind = plot([1 1],[0 10],'w--','linewidth',1);

xtimes = frametimes{min(length(frametimes),2)}/subsample_factor;
params(n_stacks+1).rat1 = plot(xtimes,zeros(length(xtimes),1)+3,'w');

ud.zoom = 0;
ud.xmax = max(xtimes);
ud.xtimes = xtimes;
ud.params = params;
ud.hf = hf;
ud.h_sl_ax = h_sl_ax;
ud.h_sl_bar = h_sl_bar;
ud.stacks = stacks;
ud.frametimes = frametimes;
set(params(n_stacks+1).aux_ax,'UserData',ud);

historyCursor = cursors(params(n_stacks+1).aux_ax,'r');
addlistener(historyCursor,'onStartDrag',@myevent_cursor_onStartDrag);
addlistener(historyCursor,'onDrag'     ,@myevent_cursor_onDrag);
addlistener(historyCursor,'onReleased' , @myevent_cursor_onReleased);
addlistener(historyCursor,'progMove', @myevent_cursor_progMove);
% assignin('base','historyCursor', historyCursor);

% Remove all cursors if exist
if ~isempty(historyCursor.Positions)
    historyCursor.remove([]);
end

% Add cursor
historyCursor.add(1);

axis tight
ylim([0 10])
axis off


for ind = 1:n_stacks
    set(hf(ind),'windowbuttondownfcn',@view_stack_buttdofcn);
    set(hf(ind),'windowbuttonupfcn',@view_stack_buttupfcn);
    set(hf(ind),'windowbuttonmotionfcn',{@view_stack_winmotfcn,hf,h_sl_ax,h_sl_bar,stacks,frametimes,historyCursor,subsample_factor});
    set(hf(ind),'KeyPressFcn' ,{@view_stack_keypress,hf,h_sl_bar,stacks,frametimes,historyCursor,subsample_factor});
    set(hf(ind),'CloseRequestFcn',@close_fcn);
    set(hf(ind),'menubar','none','color','k');
    set(params(ind).h_f_ax,'clim',params(ind).clim);
    set(hf(ind),'UserData',params(ind));
end

set(hf(n_stacks+1),'UserData',params(n_stacks+1));
set(hf(n_stacks+1),'KeyPressFcn' ,{@view_stack_keypress,hf,h_sl_bar,stacks,frametimes,historyCursor,subsample_factor});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function view_stack_winmotfcn(cf,e,hf,h_sl_ax,h_sl_bar,stacks,frametimes,historyCursor,subsample_factor)

for ind = 1:length(hf)
    params(ind) = get(hf(ind),'UserData');
end
cf_ind = find(cf == hf);
if params(cf_ind).button_down
    cp = get(h_sl_ax(cf_ind),'currentpoint');
    cp = cp(1);
    cp = min(cp,1);
    cp = max(cp,0);
    cframe = round(cp*(size(stacks{cf_ind},3)-1))+1;
    set(h_sl_bar(cf_ind),'Xdata',[1 1]*cp);
    if params(cf_ind).nbr_avg_frames == 1
        set(params(cf_ind).h_im_data,'CData',stacks{cf_ind}(:,:,cframe));
    else
        set(params(cf_ind).h_im_data,'CData',mean(stacks{cf_ind}(:,:,cframe:min(cframe+params(cf_ind).nbr_avg_frames-1,size(stacks{cf_ind},3))),3));
    end
    set(params(cf_ind).h_txt,'string',num2str(round(cp*(size(stacks{cf_ind},3)-1))+1));
    for ind = setdiff(1:length(stacks),cf_ind)
        [~,secframe] = min(abs(frametimes{ind}-frametimes{cf_ind}(cframe)));
        cp = secframe/length(frametimes{ind});
        set(h_sl_bar(ind),'Xdata',[1 1]*cp);
        set(params(ind).h_im_data,'CData',stacks{ind}(:,:,secframe));
        set(params(ind).h_txt,'string',num2str(secframe));
    end
    
    set(params(length(stacks)+1).pos_ind,'xdata',[1 1]*frametimes{cf_ind}(cframe)/subsample_factor);
    xpos = historyCursor.Positions;
    xpos(1) = frametimes{cf_ind}(cframe)/subsample_factor;
    historyCursor.newpos(xpos);
end

function view_stack_buttdofcn(cf,e)
params = get(cf,'UserData');
params.button_down = 1;
set(cf,'UserData',params);

function view_stack_buttupfcn(cf,e)
params = get(cf,'UserData');
params.button_down = 0;
set(cf,'UserData',params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function view_stack_keypress(cf,event,hf,h_sl_bar,stacks,frametimes,historyCursor,subsample_factor)
for ind = 1:length(hf)
    params(ind) = get(hf(ind),'UserData');
end

cf_ind = find(cf == hf);
if cf_ind<(length(stacks)+1)
    nFrames = size(stacks{cf_ind},3);
    spacing = 1/nFrames;
else
    event.Key ='';
    if strcmp(event.Character,'w')==0
        event.Character = '';
    end
end

switch event.Character
    case 's'  % scale
        temp = get(cf);
        figLength = temp.Position(3);
        set(cf,'Position',[temp.Position(1) temp.Position(2) figLength 1.03*figLength*size(data,1)/size(data,2)]);
        
%     case 'm' % make a movie
%         [avi_fname,avi_path] = uiputfile('tiff_stack.avi','save stack as');
%         mov = VideoWriter([avi_path avi_fname],'Uncompressed AVI');
%         mov.FrameRate = 23;
%         speed_factor = input('Select speed to save movie at: ');
%         frame_bounds = input('Select [start_frame stop_fram], 0 for all frames: ');
%         open(mov);
%         if frame_bounds == 0
%             frame_bounds = [0 nFrames];
%         end
%         for cp = frame_bounds(1)/nFrames:spacing*speed_factor:(frame_bounds(2)+1)/nFrames-spacing*speed_factor
%             set(h_sl_bar,'Xdata',[1 1]*cp);
%             set(params.h_im_data,'CData',mean(data(:,:,round(cp*(nFrames-1)+1):min(size(data,3),round(cp*(nFrames-1))+speed_factor)),3));
%             set(params.h_txt,'string',num2str(round(cp*(nFrames-1))+1));
%             frame = getframe(gcf);
%             writeVideo(mov,frame);
%         end
%         close(mov);

    case 'a' % show activity of selected area
        params(cf_ind).as_ind = params(cf_ind).as_ind+1;
        color_ind = 'mgycrbw';
        as = ginput(2);
        hold on
        plot([as(2) as(2) as(1) as(1) as(2)],[as(4) as(3) as(3) as(4) as(4)],color_ind(mod(params(cf_ind).as_ind-1,length(color_ind))+1));
        as_x = round(sort([as(3) as(4)]));
        as_y = round(sort([as(1) as(2)]));
        fig_pos = get(gcf,'position');
        if isfield(params(cf_ind),'sup_fig_h') && ishandle(params(cf_ind).sup_fig_h)
            set(params(cf_ind).sup_fig_h,'position',[fig_pos(1) fig_pos(2)-100-33 fig_pos(3) 100]);
        else
            params(cf_ind).sup_fig_h = figure('position',[fig_pos(1) fig_pos(2)-100-33 fig_pos(3) 100],'menubar','none','color','k');
            axes('position',[0 0 1 1],'color','k');
            hold on
        end
        prev_fig_handle = gcf;
        figure(params(cf_ind).sup_fig_h);
        try
            raw_act_trace = squeeze(mean(mean(stacks{cf_ind}(as_x(1):as_x(2),as_y(1):as_y(2),:),2),1));
            plot(raw_act_trace,color_ind(params(cf_ind).as_ind));
            assignin('base','raw_act_trace',raw_act_trace);
        catch
            disp('try again - selection not valid');
        end
        axis tight;
        maxrat = prctile(raw_act_trace,99);
        minrat = prctile(raw_act_trace,1);
%         set(params(length(hf)).rat1,'ydata',(raw_act_trace-minrat)/(maxrat-minrat)+3);
        set(0, 'currentfigure', hf(length(hf)));
%         disp([' indice ' num2str(cf_ind)]);
        hold on;
        roihf = plot((frametimes{cf_ind}/subsample_factor),((raw_act_trace-minrat)/(maxrat-minrat)+ 2),color_ind(params(cf_ind).as_ind));
        hold off
        figure(prev_fig_handle);
        params(cf_ind).roish = [params(cf_ind).roish roihf];
        set(hf(cf_ind),'UserData',params(cf_ind));
    case 'f' % mark line in figure
        as = ginput(2);
        hold on
        plot([as(1) as(2)],[as(3) as(4)],'r','linewidth',2)
        
    case 't' % show template
        fig_pos = get(gcf,'position');
        prev_fig_handle = gcf;
        if isfield(params(cf_ind),'sup_fig2_h') && ishandle(params(cf_ind).sup_fig2_h)
            set(params(cf_ind).sup_fig2_h,'position',[fig_pos(1)+fig_pos(3) fig_pos(2) fig_pos(3) fig_pos(4)]);
            figure(params(cf_ind).sup_fig2_h);
        else
            params(cf_ind).sup_fig2_h = figure('position',[fig_pos(1)+fig_pos(3) fig_pos(2) fig_pos(3) fig_pos(4)],'menubar','none');
        end
        axes('position',[0 0 1 1]);
        imagesc(mean(stacks{cf_ind},3));colormap gray;
        %         set(gca,'clim',params.clim)
        axis off
        figure(prev_fig_handle);
        set(hf(cf_ind),'UserData',params(cf_ind));
    case 'c' % clear
        hold off
        cp = get(h_sl_bar(cf_ind),'Xdata');
        cp = cp(1);
        axes(params(cf_ind).h_f_ax);
        params(cf_ind).h_im_data = imagesc(stacks{cf_ind}(:,:,round(cp*(size(stacks{cf_ind},3)-1))+1));
        set(params(cf_ind).h_f_ax,'clim',params(cf_ind).clim,'xtick',[]);
        yl = ylim;xl = xlim;
        params(cf_ind).h_txt = text(xl(2)/20,yl(2)/20,num2str(round(cp*(size(stacks{cf_ind},3)-1))+1),'fontsize',12,'color','w','fontweight','bold');
        if isfield(params(cf_ind),'sup_fig_h') && ishandle(params(cf_ind).sup_fig_h)
            close(params(cf_ind).sup_fig_h);
        end
        if isfield(params(cf_ind),'sup_fig2_h') && ishandle(params(cf_ind).sup_fig2_h)
            close(params(cf_ind).sup_fig2_h);
        end
        for roind = 1:length(params(cf_ind).roish)
            if ishandle(params(cf_ind).roish(roind))
                delete(params(cf_ind).roish(roind));
            end
        end
        params(cf_ind).roish = [];
        params(cf_ind).as_ind = 0;
        set(hf(cf_ind),'UserData',params(cf_ind));
    case 'u' % make all windows visible
        for hfig = 1: length(hf)
            uistack(hf(hfig), 'top');
        end
            
    case 'v' % set number of frames to average
        params(cf_ind).nbr_avg_frames = input('How many frames do you want to average: ');
        set(hf(cf_ind),'UserData',params(cf_ind));
        figure(hf(cf_ind));
    case 'w' % set window to zoom in 
        ud = get(historyCursor.HdlAxes, 'UserData');
        delta= round(length(ud.xtimes)/20);
        cursorPositions = historyCursor.Positions;
        cpIdx = find(cursorPositions(1) <= ud.xtimes,1,'first');
        if (cpIdx > length(ud.xtimes)) 
            delta=delta*(-1);
        end 
        if ud.zoom==0
            disp ('zoom in');
            ud.zoom=1;
            set(0, 'currentfigure', hf(length(stacks)+1));
            uistack(hf(length(stacks)+1), 'top');
            historyCursor.add(ud.xtimes(cpIdx+delta));
        else
            disp ('zoom out');
            ud.zoom = 0;
            n=length(historyCursor.Positions);
            while n>1
                historyCursor.remove(n);
                n=n-1;
            end
            xlim(historyCursor.HdlAxes,[ud.xtimes(1),ud.xmax]);
        end
        set(historyCursor.HdlAxes, 'UserData',ud);
end

switch event.Key
    case 'rightarrow'
        if strcmp(event.Modifier,'shift')
            params(cf_ind).clim(1) = params(cf_ind).clim(1)*1.1;
            set(params(cf_ind).h_f_ax,'clim',params(cf_ind).clim)
            set(hf(cf_ind),'UserData',params(cf_ind));
        else
            cp = get(h_sl_bar(cf_ind),'Xdata');
            cp = cp(1);
            cp = cp + spacing;
            if cp > 1, cp = 1; end;
            cframe = round(cp*(size(stacks{cf_ind},3)-1))+1;
            set(h_sl_bar(cf_ind),'Xdata',[1 1]*cp);
            if params(cf_ind).nbr_avg_frames == 1
                set(params(cf_ind).h_im_data,'CData',stacks{cf_ind}(:,:,cframe));
            else
                set(params(cf_ind).h_im_data,'CData',mean(stacks{cf_ind}(:,:,cframe:min(cframe+params(cf_ind).nbr_avg_frames-1,size(stacks{cf_ind},3))),3));
            end
            set(params(cf_ind).h_txt,'string',num2str(round(cp*(size(stacks{cf_ind},3)-1))+1));
            for ind = setdiff(1:length(stacks),cf_ind)
                [~,secframe] = min(abs(frametimes{ind}-frametimes{cf_ind}(cframe)));
                cp = secframe/length(frametimes{ind});
                set(h_sl_bar(ind),'Xdata',[1 1]*cp);
                set(params(ind).h_im_data,'CData',stacks{ind}(:,:,secframe));
                set(params(ind).h_txt,'string',num2str(secframe));
            end
            set(params(length(stacks)+1).pos_ind,'xdata',[1 1]*frametimes{cf_ind}(cframe)/subsample_factor);
        end
    case 'leftarrow'
        if strcmp(event.Modifier,'shift')
            params(cf_ind).clim(1) = params(cf_ind).clim(1)*0.9;
            set(params(cf_ind).h_f_ax,'clim',params(cf_ind).clim)
            set(hf(cf_ind),'UserData',params(cf_ind));
        else
            cp = get(h_sl_bar(cf_ind),'Xdata');
            cp = cp(1);
            cp = cp - spacing;
            if cp < 0, cp = 0; end;
            cframe = round(cp*(size(stacks{cf_ind},3)-1))+1;
            set(h_sl_bar(cf_ind),'Xdata',[1 1]*cp);
            if params(cf_ind).nbr_avg_frames == 1
                set(params(cf_ind).h_im_data,'CData',stacks{cf_ind}(:,:,cframe));
            else
                set(params(cf_ind).h_im_data,'CData',mean(stacks{cf_ind}(:,:,cframe:min(cframe+params(cf_ind).nbr_avg_frames-1,size(stacks{cf_ind},3))),3));
            end
            set(params(cf_ind).h_txt,'string',num2str(round(cp*(size(stacks{cf_ind},3)-1))+1));
            for ind = setdiff(1:length(stacks),cf_ind)
                [~,secframe] = min(abs(frametimes{ind}-frametimes{cf_ind}(cframe)));
                cp = secframe/length(frametimes{ind});
                set(h_sl_bar(ind),'Xdata',[1 1]*cp);
                set(params(ind).h_im_data,'CData',stacks{ind}(:,:,secframe));
                set(params(ind).h_txt,'string',num2str(secframe));
            end
            set(params(length(stacks)+1).pos_ind,'xdata',[1 1]*frametimes{cf_ind}(cframe)/subsample_factor);
        end
    case 'uparrow'
        if strcmp(event.Modifier,'shift')
            params(cf_ind).clim(2) = params(cf_ind).clim(2)*1.1;
            set(params(cf_ind).h_f_ax,'clim',params(cf_ind).clim)
        else
            params(cf_ind) = get(hf(cf_ind),'UserData');
            if params(cf_ind).frame_pause<= 0.01
                params(cf_ind).playback_spacing = params(cf_ind).playback_spacing*2;
            else
                params(cf_ind).frame_pause = params(cf_ind).frame_pause*0.5;
            end
        end
        set(hf(cf_ind),'UserData',params(cf_ind));
        
    case 'downarrow'
        if strcmp(event.Modifier,'shift')
            params(cf_ind).clim(2) = params(cf_ind).clim(2)*0.9;
            set(params(cf_ind).h_f_ax,'clim',params(cf_ind).clim)
        else
            params(cf_ind) = get(hf(cf_ind),'UserData');
            if params(cf_ind).playback_spacing>1
                params(cf_ind).playback_spacing = params(cf_ind).playback_spacing/2;
            else
                params(cf_ind).frame_pause = params(cf_ind).frame_pause*2;
            end
        end 
        set(hf(cf_ind),'UserData',params(cf_ind));
    case 'space'   % play as movie
        
        for ind = 1:length(stacks)
            params(ind).movie_status = ~params(ind).movie_status;
            set(hf(ind),'UserData',params(ind));
        end
        
        cursorPositions = historyCursor.Positions;
        if size(cursorPositions)==1
            cp = get(h_sl_bar(cf_ind),'Xdata');
            cp = cp(1);
            cpmax = 1;
            cpmin = 0;
        else
            xnew = cursorPositions;
            cp = sort(cursorPositions)';
                        
            ud = get(historyCursor.HdlAxes, 'UserData');
            cp = cp/ud.xmax;
            cpmax = cp(2);
            cpmin = cp(1);
            cp = cp(1);
        end
            
        
        while params(cf_ind).movie_status
            params(cf_ind) = get(hf(cf_ind),'UserData');
            cp = cp + spacing*params(cf_ind).playback_spacing;
            if cp > cpmax
                cp = cpmin;
            end;
            cframe = round(cp*(size(stacks{cf_ind},3)-1))+1;
            set(h_sl_bar(cf_ind),'Xdata',[1 1]*cp);
            if params(cf_ind).nbr_avg_frames == 1
                set(params(cf_ind).h_im_data,'CData',stacks{cf_ind}(:,:,cframe));
            else
                set(params(cf_ind).h_im_data,'CData',mean(stacks{cf_ind}(:,:,cframe:min(cframe+params(cf_ind).nbr_avg_frames-1,size(stacks{cf_ind},3))),3));
            end
            set(params(cf_ind).h_txt,'string',num2str(cframe));
            for ind = setdiff(1:length(stacks),cf_ind)
                [~,secframe] = min(abs(frametimes{ind}-frametimes{cf_ind}(cframe)));
                seccp = secframe/length(frametimes{ind});
                set(h_sl_bar(ind),'Xdata',[1 1]*seccp);
                set(params(ind).h_im_data,'CData',stacks{ind}(:,:,secframe));
                set(params(ind).h_txt,'string',num2str(secframe));
            end
            xnew(1) = frametimes{cf_ind}(cframe)/subsample_factor;
            set(params(length(stacks)+1).pos_ind,'xdata',[1 1]*xnew(1));
            historyCursor.newpos(xnew);
            pause(params(cf_ind).frame_pause);
        end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function myevent_cursor_onStartDrag(eventSrc,eventData) 
%     disp(' ')
%     disp('Started Drag ');
    cursorPos = sort(eventData.Positions)';
%     disp(['xstart = ' num2str(cursorPos')]);
 

  function myevent_cursor_onDrag(eventSrc,eventData) 
    ud = get(eventSrc.HdlAxes, 'UserData');
    params = ud.params;  
    if ud.zoom==0  % if not in "zoom in" mode
        cp = sort(eventData.Positions)';
            currPos = cp(1);
        %     disp(['xend = ' num2str(cp')]);
        %     disp('Drag released ');
            currPos = currPos/ud.xmax;
        %      disp(['cp %' num2str(cp)]);

            for ind = 1:length(ud.stacks)
                secframe = round(currPos*(size(ud.stacks{ind},3)-1))+1;
                currPos = secframe/length(ud.frametimes{ind});
                set(ud.h_sl_bar(ind),'Xdata',[1 1]*currPos);
                set(params(ind).h_im_data,'CData',ud.stacks{ind}(:,:,secframe));
                set(params(ind).h_txt,'string',num2str(secframe));
            end
        if length(cp) > 1 
            % zoom in
            % Find indices of the 2 cursors position in the xData serie
            I1 = find(cp(1) >= ud.xtimes,1,'last')-10;
            I1 = max(I1,1);
            I2 = find(cp(2) <= ud.xtimes,1,'first');
            xlim(eventSrc.HdlAxes,[ud.xtimes(I1), ud.xtimes(I2)]);
        end
    end
    
    
  function myevent_cursor_onReleased(eventSrc,eventData)
    ud = get(eventSrc.HdlAxes, 'UserData');
    params = ud.params;  
      
    cp = sort(eventData.Positions)';
        currPos = cp(1);
    %     disp(['xend = ' num2str(cp')]);
    %     disp('Drag released ');
        currPos = currPos/ud.xmax;
    %      disp(['cp %' num2str(cp)]);

        for ind = 1:length(ud.stacks)
            secframe = round(currPos*(size(ud.stacks{ind},3)-1))+1;
            currPos = secframe/length(ud.frametimes{ind});
            set(ud.h_sl_bar(ind),'Xdata',[1 1]*currPos);
            set(params(ind).h_im_data,'CData',ud.stacks{ind}(:,:,secframe));
            set(params(ind).h_txt,'string',num2str(secframe));
        end
    if length(cp) > 1 
        % zoom in
        % Find indices of the 2 cursors position in the xData serie
        I1 = find(cp(1) >= ud.xtimes,1,'last')-10;
        if isempty(I1)
            I1=1;
        end
        I1 = max(I1,1);
        I2 = find(cp(2) <= ud.xtimes,1,'first');
        xlim(eventSrc.HdlAxes,[ud.xtimes(I1), ud.xtimes(I2)]);
    end

 function myevent_cursor_progMove(eventSrc,eventData)
    cursorPos = sort(eventData.Positions)';
%     disp(['xend = ' num2str(cursorPos') ' ' num2str(cp1)]);
%     disp('progMove ');

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function close_fcn(hf,e)
params = get(hf,'UserData');
if isfield(params,'sup_fig_h') && ishandle(params.sup_fig_h)
    close(params.sup_fig_h);
end
if isfield(params,'sup_fig2_h') && ishandle(params.sup_fig2_h)
    close(params.sup_fig2_h);
end

delete(hf)


    
