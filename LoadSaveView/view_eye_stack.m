function view_eye_stack(data, imeta_info, map)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% eye stack viewer
% view_eye_stack(data, imeta_info, map)
%
% data - our stack
% map - optional change of colormap, default gray
%
% key control:
% arrow up/down - adjust movie speed
% space tab: pause movie
% s: scale to square
% m: make movie
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    map = 'gray';
end

NOP=100;
THETA=linspace(0,2*pi,NOP);
pupil=zeros(NOP,2,size(imeta_info,2));
for ind=1:length(imeta_info)
    RHO=ones(1,NOP)*imeta_info(9,ind);
    [X,Y] = pol2cart(THETA,RHO);
    pupil(:,1,ind)=X+imeta_info(8,ind);
    pupil(:,2,ind)=Y+imeta_info(7,ind);
end


hf=figure;
clf;
params.button_down=0;
params.movie_status=0;
params.frame_pause=0.01; % pause in seconds between frames in playback
params.playback_spacing=1; % only every n-th frame is shown during playback default=1 (every frame)

set(hf,'UserData',params);
dimensions = size(data);
offset = 200;

set(hf,'Position',[offset offset dimensions(2)+offset 1.03*dimensions(1)+offset]);
frame_ind=1;

template=mean(data,3);
low_contrast_lim=prctile(reshape(template,numel(template),1),0.01);
high_contrast_lim=prctile(reshape(template,numel(template),1),99.99);

clim=[low_contrast_lim high_contrast_lim];


h_f_ax=axes('position',[0 0.03 1 0.97],'color','k','clim',clim);
h_im_data=imagesc(data(:,:,frame_ind));
hold on
h_pupil=plot(pupil(:,1,frame_ind),pupil(:,2,frame_ind),'r');

% set(h_im_data,'CDataMapping','direct');

yl=ylim;xl=xlim;
h_txt=text(xl(2)/20,yl(2)/20,'1','fontsize',12,'color','y','fontweight','bold');
colormap(map);
h_sl_ax=axes('position',[0 0 1 0.03],'color','k');
xlim([0 1]);
ylim([0 1]);
hold on;
sl_x_pos=0;
h_sl_bar=plot([1 1]*sl_x_pos,[0 1],'r','linewidth',20);

set(hf,'windowbuttondownfcn',@view_stack_buttdofcn);
set(hf,'windowbuttonupfcn',@view_stack_buttupfcn);
set(hf,'windowbuttonmotionfcn',{@view_stack_winmotfcn,h_sl_ax,h_sl_bar,h_im_data,h_pupil,h_txt,data,pupil});
set(hf,'KeyPressFcn' ,{@view_stack_keypress,h_sl_bar,h_im_data,h_pupil,h_txt,data,pupil});
set(hf,'menubar','none','color','k');
set(h_f_ax,'clim',clim,'Visible','off');



function view_stack_winmotfcn(hf,e,h_sl_ax,h_sl_bar,h_im_data,h_pupil,h_txt,data,pupil)
params=get(hf,'UserData');
if params.button_down
    cp=get(h_sl_ax,'currentpoint');
    cp=cp(1);
    cp=min(cp,1);
    cp=max(cp,0);
    set(h_sl_bar,'Xdata',[1 1]*cp);
    set(h_im_data,'CData',data(:,:,round(cp*(size(data,3)-1))+1));
    set(h_pupil,'Xdata',pupil(:,1,round(cp*(size(data,3)-1))+1));
    set(h_pupil,'Ydata',pupil(:,2,round(cp*(size(data,3)-1))+1));
    set(h_txt,'string',num2str(round(cp*(size(data,3)-1))+1));
end

function view_stack_buttdofcn(hf,e)
params=get(hf,'UserData');
params.button_down=1;
set(hf,'UserData',params);

function view_stack_buttupfcn(hf,e)
params=get(hf,'UserData');
params.button_down=0;
set(hf,'UserData',params);

function view_stack_keypress(hf,event,h_sl_bar,h_im_data,h_pupil,h_txt,data,pupil)
params=get(hf,'UserData');
nFrames = size(data,3);
spacing = 1/nFrames;
switch event.Character
    case 's'  % scale
        temp = get(hf);
        figLength = temp.Position(3);
        set(hf,'Position',[temp.Position(1) temp.Position(2) figLength 1.03*figLength*size(data,1)/size(data,2)]);
        
    case 'm' % make a movie
        [avi_fname,avi_path]=uiputfile('tiff_stack.avi','save stack as');
        mov=VideoWriter([avi_path avi_fname],'Motion JPEG AVI');
        mov.FrameRate = 23;
        speed_factor=input('Select speed to save movie at: ');
        frame_bounds=input('Select [start_frame stop_fram], 0 for all frames: ');
        open(mov);
        if frame_bounds==0
            frame_bounds=[0 nFrames];
        end
        for cp=frame_bounds(1)/nFrames:spacing*speed_factor:frame_bounds(2)/nFrames
            set(h_sl_bar,'Xdata',[1 1]*cp);
            set(h_im_data,'CData',data(:,:,round(cp*(nFrames-1))+1));
            set(h_pupil,'Xdata',pupil(:,1,round(cp*(size(data,3)-1))+1));
            set(h_pupil,'Ydata',pupil(:,2,round(cp*(size(data,3)-1))+1));
            set(h_txt,'string',num2str(round(cp*(nFrames-1))+1));
            frame = getframe(gcf);
            writeVideo(mov,frame);
        end
        close(mov);
        
end

switch event.Key
    case 'rightarrow'
        cp=get(h_sl_bar,'Xdata');
        cp=cp(1);
        cp = cp + spacing;
        if cp > 1, cp = 1; end;
        set(h_sl_bar,'Xdata',[1 1]*cp);
        set(h_im_data,'CData',data(:,:,round(cp*(size(data,3)-1))+1));
        set(h_pupil,'Xdata',pupil(:,1,round(cp*(size(data,3)-1))+1));
        set(h_pupil,'Ydata',pupil(:,2,round(cp*(size(data,3)-1))+1));
        set(h_txt,'string',num2str(round(cp*(size(data,3)-1))+1));
        
    case 'leftarrow'
        cp=get(h_sl_bar,'Xdata');
        cp=cp(1);
        cp = cp - spacing;
        if cp < 0, cp = 0; end;
        set(h_sl_bar,'Xdata',[1 1]*cp);
        set(h_im_data,'CData',data(:,:,round(cp*(size(data,3)-1))+1));
        set(h_pupil,'Xdata',pupil(:,1,round(cp*(size(data,3)-1))+1));
        set(h_pupil,'Ydata',pupil(:,2,round(cp*(size(data,3)-1))+1));
        set(h_txt,'string',num2str(round(cp*(size(data,3)-1))+1));
        
    case 'uparrow'
        params=get(hf,'UserData');
        if params.frame_pause<=0.01
            params.playback_spacing=params.playback_spacing*2;
        else
            params.frame_pause=params.frame_pause*0.5;
        end
        set(hf,'UserData',params);
        
    case 'downarrow'
        params=get(hf,'UserData');
        if params.playback_spacing>1
            params.playback_spacing=params.playback_spacing/2;
        else
            params.frame_pause=params.frame_pause*2;
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
            if cp > 1, cp = 0; end;
            set(h_sl_bar,'Xdata',[1 1]*cp);
            set(h_im_data,'CData',data(:,:,round(cp*(size(data,3)-1))+1));
            set(h_pupil,'Xdata',pupil(:,1,round(cp*(size(data,3)-1))+1));
            set(h_pupil,'Ydata',pupil(:,2,round(cp*(size(data,3)-1))+1));
            set(h_txt,'string',num2str(round(cp*(size(data,3)-1))+1));
            pause(params.frame_pause);
        end
end






