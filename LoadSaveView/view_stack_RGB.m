function view_stack_RGB(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tiff viewer for RGB stacks
%
% data - our RGB stack in the format M x N x 3 x P
%
% key control:
% 'SHIFT+arrow up/down/right/left'  - adjust brightness for RED
% 'CTRL+arrow up/down/right/left'   - adjust brightness for GREEN
% 'ALT+arrow up/down/right/left'    - adjust brightness for BLUE
% 'arrow up/down'                   - adjust movie speed
% 'space'                           - play/pause movie
% 't'                               - create average image of stack
% 'v'                               - set no. frames to average
% 'a'                               - select ROI and show activity
% 'A'                               - select channel for 'a' (default is 2)
% 'm'                               - make avi movie
% 'h'                               - show this help section
%
% 2014 ML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% check the data input for correctness
if length(size(data)) ~= 4 || size(data,3) ~= 3
    error ('stack has wrong format. Correct M x N x 3 x P')
end

% check if data is already normalized
if min(reshape(data(:,:,3,1:2),1,[])) < 0 || max(reshape(data(:,:,3,1:2),1,[])) > 1
    for ii = 1:3
        data(:,:,ii,:) = ntzo(data(:,:,ii,:));
    end
end

hf=figure;
clf;
params.button_down = 0;
params.movie_status = 0;
params.frame_pause = 0; % pause in seconds between frames in playback
params.playback_spacing = 1; % only every n-th frame is shown during playback default=1 (every frame)
params.as_ind = 0; % index over area-selected for plotting activity
params.nbr_avg_frames = 1;
params.ac_channel = 2;

colors = colormap(hsv);
colors = colors(1:6:end,:);
colors = colors(randperm(11),:);
params.colors = colors;

set(hf,'UserData',params);
dimensions = size(data);
params.dimensions = dimensions;
params.temp = double(zeros([params.dimensions(1:2) 3]));

offset = 200;
set(hf,'Position',[offset offset dimensions(2) 1.03*dimensions(1)]);

frame_ind=1;

params.climfactor = [0.95 1.05];
for ii = 1:3
    template=data(:,:,ii,round(size(data,4)/2));
    low_contrast_lim=prctile(reshape(template,numel(template),1),10);
    high_contrast_lim=prctile(reshape(template,numel(template),1),99);
    if high_contrast_lim > low_contrast_lim
        params.ch_enable(ii) = 1;
        params.clim(1,ii) = low_contrast_lim;
        params.clim(2,ii) = high_contrast_lim;
    elseif low_contrast_lim == high_contrast_lim
        params.ch_enable(ii) = 0;
        params.clim(1,ii) = 0;
        params.clim(2,ii) = 1;
    else
        params.ch_enable(ii) = 1;
        params.clim(1,ii) = low_contrast_lim;
        params.clim(2,ii) = low_contrast_lim * 2;
    end
end


params.h_f_ax=axes('position',[0 0.03 1 0.97],'color','k');
params.h_im_data=image(squeeze(adjustTruecolorImage2(data(:,:,:,frame_ind),params.clim(1,:),params.clim(2,:))));


hold on

yl=ylim;xl=xlim;
params.h_txt=text(xl(2)/20,yl(2)/20,'1','fontsize',12,'color','w','fontweight','bold');

h_sl_ax=axes('position',[0 0 1 0.03],'color','k');
xlim([0 1]);
ylim([0 1]);
hold on
sl_x_pos=0;
h_sl_bar=plot([1 1]*sl_x_pos,[0 1],'r','linewidth',20);

set(hf,'windowbuttondownfcn',@view_tiff_stack_buttdofcn);
set(hf,'windowbuttonupfcn',@view_tiff_stack_buttupfcn);
set(hf,'windowbuttonmotionfcn',{@view_tiff_stack_winmotfcn,h_sl_ax,h_sl_bar,data});
set(hf,'KeyPressFcn' ,{@view_tiff_stack_keypress,h_sl_bar,data});
set(hf,'CloseRequestFcn',@close_fcn);
set(hf,'menubar','none','color','k');
set(params.h_f_ax,'TickLength',[0 0]);
set(hf,'UserData',params);


function view_tiff_stack_winmotfcn(hf,e,h_sl_ax,h_sl_bar,data)
params=get(hf,'UserData');
if params.button_down
    cp=get(h_sl_ax,'currentpoint');
    cp=cp(1);
    cp=min(cp,1);
    cp=max(cp,0);
    draw_frame(cp,h_sl_bar,params,data);
end

function view_tiff_stack_buttdofcn(hf,e)
params=get(hf,'UserData');
params.button_down=1;
set(hf,'UserData',params);

function view_tiff_stack_buttupfcn(hf,e)
params=get(hf,'UserData');
params.button_down=0;
set(hf,'UserData',params);

function view_tiff_stack_keypress(hf,event,h_sl_bar,data)
params=get(hf,'UserData');
nFrames = size(data,4);
spacing = 1/nFrames;
switch event.Character
    case 's'  % scale
        temp = get(hf);
        figLength = temp.Position(3);
        set(hf,'Position',[temp.Position(1) temp.Position(2) figLength 1.03*figLength*size(data,1)/size(data,2)]);
        
    case 'h' % help
        help view_stack_RGB
    case 'm' % make a movie
        [avi_fname,avi_path]=uiputfile('tiff_stack.avi','save stack as');
        mov=VideoWriter([avi_path avi_fname],'uncompressed AVI');
        mov.FrameRate = 23;
        speed_factor=input('Select speed to save movie at: ');
        frame_bounds=input('Select [start_frame stop_fram], 0 for all frames: ');
        open(mov);
        if frame_bounds==0
            frame_bounds=[0 nFrames];
        end
        for cp=frame_bounds(1)/nFrames:spacing*speed_factor:(frame_bounds(2)+1)/nFrames-spacing*speed_factor
            set(h_sl_bar,'Xdata',[1 1]*cp);
            
            for ii = 1:3
                if params.ch_enable(ii) > 0
                    params.temp(:,:,ii) = squeeze(mean(data(:,:,ii,...
                        round(cp*(nFrames-1)+1):min(size(data,4),round(cp*(nFrames-1))+speed_factor+params.nbr_avg_frames)),4));
                end
            end
            params.temp = adjustTruecolorImage2(params.temp,params.clim(1,:),params.clim(2,:));

            set(params.h_im_data,'CData',params.temp);
            set(params.h_txt,'string',num2str(round(cp*(nFrames-1))+1));
            drawnow;
            frame = getframe(gcf);
            writeVideo(mov,frame);
        end
        close(mov);
    case 'A' % set channel for activity traces
        params.ac_channel=input('Which channel should be used for activity measurements? [red(1), green(2) or blue(3)] ');
        if isempty(params.ac_channel)
            params.ac_channel = 2;
        elseif params.ac_channel < 1 || params.ac_channel > 3
            params.ac_channel = 2;
        end
        disp(['Channel for activity measurements set to ' num2str(params.ac_channel) '.']);
        set(hf,'UserData',params);
        figure(hf);
    case 'a' % show activity of selected area
        params.as_ind=params.as_ind+1;
        as=ginput(2);
        hold on
        plot([as(2) as(2) as(1) as(1) as(2)],[as(4) as(3) as(3) as(4) as(4)],'Color',params.colors(params.as_ind,:));
        as_x=round(sort([as(3) as(4)]));
        as_y=round(sort([as(1) as(2)]));
        fig_pos=get(gcf,'position');
        if isfield(params,'sup_fig_h') && ishandle(params.sup_fig_h)
            hold off
            set(params.sup_fig_h,'position',[fig_pos(1) fig_pos(2)-100-33 fig_pos(3) 100]);
        else
            params.sup_fig_h=figure('position',[fig_pos(1) fig_pos(2)-100-33 fig_pos(3) 100],'menubar','none','color','k');
            axes('position',[0 0 1 1],'color','k');
            hold on
        end
        prev_fig_handle=gcf;
        figure(params.sup_fig_h);
        try            
            axes('position',[0 0 1 1],'color','k');
            hold on
            params.raw_act_trace(:,params.as_ind)=squeeze(mean(mean(squeeze(data(as_x(1):as_x(2),as_y(1):as_y(2),params.ac_channel,:)),2),1));
            [~,temp] = specTraces(params.raw_act_trace,'plot',0);
            for ind = 1:params.as_ind
                plot(temp(:,ind),'Color',params.colors(ind,:));
            end
            assignin('base','raw_act_trace',params.raw_act_trace);
        catch
            disp('try again - selection not valid');
        end
        axis tight;
        figure(prev_fig_handle);
        set(hf,'UserData',params);
    case 'f' % mark line in figure
        as=ginput(2);
        hold on
        plot([as(1) as(2)],[as(3) as(4)],'r','linewidth',2)
        
    case 't' % show template
        fig_pos=get(gcf,'position');
        prev_fig_handle=gcf;
        if isfield(params,'sup_fig2_h') && ishandle(params.sup_fig2_h)
            set(params.sup_fig2_h,'position',[fig_pos(1)+fig_pos(3) fig_pos(2) fig_pos(3) fig_pos(4)]);
            figure(params.sup_fig2_h);
        else
            params.sup_fig2_h=figure('position',[fig_pos(1)+fig_pos(3) fig_pos(2) fig_pos(3) fig_pos(4)],'menubar','none');
        end
        axes('position',[0 0 1 1]);
        
        aaa = zeros([params.dimensions(1:2) 3]);
        for ii = 1:3
            if params.ch_enable(ii) > 0
                aaa(:,:,ii) = squeeze(mean(data(:,:,ii,:),4));
            end
        end
        aaa = adjustTruecolorImage2(aaa,params.clim(1,:),params.clim(2,:));
        image(aaa)

        axis off
        figure(prev_fig_handle);
        set(hf,'UserData',params);
    case 'c' % clear
        hold off
        cp=get(h_sl_bar,'Xdata');
        cp=cp(1);
        axes(params.h_f_ax);
        params.h_im_data=image(squeeze(adjustTruecolorImage2(data(:,:,:,round(cp*(nFrames-1))+1),params.clim(1,:),params.clim(2,:))));

        yl=ylim;xl=xlim;
        params.h_txt=text(xl(2)/20,yl(2)/20,num2str(round(cp*(size(data,3)-1))+1),'fontsize',12,'color','w','fontweight','bold');
        if isfield(params,'sup_fig_h') && ishandle(params.sup_fig_h)
            close(params.sup_fig_h);
        end
        if isfield(params,'sup_fig2_h') && ishandle(params.sup_fig2_h)
            close(params.sup_fig2_h);
        end
        params.as_ind=0;
        params.raw_act_trace = [];
        set(hf,'UserData',params);
    case 'v' % set number of frames to average
        params.nbr_avg_frames=input('How many frames do you want to average: ');
        set(hf,'UserData',params);
        figure(hf);
end

switch event.Key
    case 'rightarrow'
        if strcmp(event.Modifier,'shift')   % clim for RED
            params.clim(1,1)=params.clim(1,1)*params.climfactor(1);
            set(params.h_f_ax,'clim',params.clim)
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'control')% clim for GREEN
            params.clim(1,2)=params.clim(1,2)*params.climfactor(1);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'alt')% clim for BLUE
            params.clim(1,3)=params.clim(1,3)*params.climfactor(1);
            set(hf,'UserData',params);
        else
            cp=get(h_sl_bar,'Xdata');
            cp=cp(1);
            cp = cp + spacing;
            if cp > 1, cp = 1; end;
            draw_frame(cp,h_sl_bar,params,data);
        end
        
    case 'leftarrow'
        if strcmp(event.Modifier,'shift')   % clim for RED
            params.clim(1,1)=params.clim(1,1)*params.climfactor(2);
            set(params.h_f_ax,'clim',params.clim)
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'control')% clim for GREEN
            params.clim(1,2)=params.clim(1,2)*params.climfactor(2);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'alt')% clim for BLUE
            params.clim(1,3)=params.clim(1,3)*params.climfactor(2);
            set(hf,'UserData',params);
        else
            cp=get(h_sl_bar,'Xdata');
            cp=cp(1);
            cp = cp - spacing;
            if cp < 0, cp = 0; end;
            draw_frame(cp,h_sl_bar,params,data);
        end
        
    case 'uparrow'
        if strcmp(event.Modifier,'shift')   % clim for RED
            params.clim(2,1)=params.clim(2,1)*params.climfactor(1);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'control')% clim for GREEN
            params.clim(2,2)=params.clim(2,2)*params.climfactor(1);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'alt')% clim for BLUE
            params.clim(2,3)=params.clim(2,3)*params.climfactor(1);
            set(hf,'UserData',params);
        else
            params=get(hf,'UserData');
            if params.frame_pause<=0.01
                params.playback_spacing=params.playback_spacing*2;
            else
                params.frame_pause=params.frame_pause*0.5;
            end
        end
        set(hf,'UserData',params);
        
    case 'downarrow'
        if strcmp(event.Modifier,'shift')   % clim for RED
            params.clim(2,1)=params.clim(2,1)*params.climfactor(2);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'control')% clim for GREEN
            params.clim(2,2)=params.clim(2,2)*params.climfactor(2);
            set(hf,'UserData',params);
        elseif strcmp(event.Modifier,'alt')% clim for BLUE
            params.clim(2,3)=params.clim(2,3)*params.climfactor(2);
            set(hf,'UserData',params);
        else
            params=get(hf,'UserData');
            if params.playback_spacing>1
                params.playback_spacing=params.playback_spacing/2;
            else
                params.frame_pause=params.frame_pause*2;
            end
        end
        set(hf,'UserData',params);
        
    case 'space'   % play as movie
        params.movie_status=~params.movie_status;
        set(hf,'UserData',params);
        cp=get(h_sl_bar,'Xdata');
        cp=cp(1);
        while params.movie_status
            params=get(hf,'UserData');
            cp = cp + spacing*params.playback_spacing;
            if cp > 1
                cp = 0;
            end;
            draw_frame(cp,h_sl_bar,params,data);
            drawnow
            pause(params.frame_pause);
        end
end

function draw_frame(cp,h_sl_bar,params,data)
set(h_sl_bar,'Xdata',[1 1]*cp);

for ii = 1:3
    if params.ch_enable(ii) > 0
        params.temp(:,:,ii) = squeeze(mean(data(:,:,ii,round(cp*(size(data,4)-1))+1:min(round(cp*(size(data,4)-1))+1+params.nbr_avg_frames-1,size(data,4))),4));
    end
end
params.temp = adjustTruecolorImage2(params.temp,params.clim(1,:),params.clim(2,:));

set(params.h_im_data,'CData',params.temp)

% % %     set(params.h_im_data,'CData',...
% % %         squeeze(mean(data(:,:,:,round(cp*(size(data,4)-1))+1:min(round(cp*(size(data,3)-1))+1+params.nbr_avg_frames-1,size(data,4))),4)));

set(params.h_txt,'string',num2str(round(cp*(size(data,4)-1))+1));

function close_fcn(hf,e)
params=get(hf,'UserData');
if isfield(params,'sup_fig_h') && ishandle(params.sup_fig_h)
    close(params.sup_fig_h);
end
if isfield(params,'sup_fig2_h') && ishandle(params.sup_fig2_h)
    close(params.sup_fig2_h);
end
delete(hf)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = adjustTruecolorImage2(rgb,lIn,hIn)
lOut=zeros(1,length(lIn));
hOut=ones(1,length(hIn));
out = zeros(size(rgb), class(rgb));

for p = 1 : 3
    out(:,:,p) = adjustArray2(rgb(:,:,p), lIn(p),hIn(p), lOut(p), ...
        hOut(p));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = adjustArray2(img,lIn,hIn,lOut,hOut)
d=1;
lIn = double(lIn);
hIn = double(hIn);
%make sure img is in the range [lIn;hIn]
img(:) =  max(lIn(d,:), min(hIn(d,:),img));

out = ( (img - lIn(d,:)) ./ (hIn(d,:) - lIn(d,:)) );
out(:) = out .* (hOut(d,:) - lOut(d,:)) + lOut(d,:);






