function oii_eval2(movie,fs,centerFreq)
  
    ud = struct();
    ud.maxFreq = fs/2;
        
    ud.center = centerFreq;
    ud.width = (0.05);
    
    ud.nFrames = size(movie,3);
    ud.log = 0;
    mov = double(movie);
    %xdft(1:N/2+1);
    MOV = fft(mov,[],3);
    ud.MOV = abs(MOV(:,:,1:ud.nFrames/2+1)).^2;
    ud.phase = angle(MOV(:,:,1:ud.nFrames/2+1));
    ud.maxBin = size(ud.MOV,3);
    
    % Create a figure and an axes to contain a 3-D surface plot.
    h.f=figure('menubar','none','color','k','Position', [100, 100, 800, 800]);
    h.a1=axes('position',[-.1 0.2 1 0.6],'Units','pixels');
    axis off
    
    

    
    % Add a slider uicontrol to control the vertical scaling of the
    % surface object. Position it under the Clear button.
    f=uicontrol('Style', 'slider',...
        'Min',0,'Max',ud.maxFreq,'Value',ud.center,...
        'Position', [100 20 100 20],...
        'Callback', {@center_cb, h},...
        'SliderStep',[1/ud.maxBin .1]/(1)); 
					% Slider function handle callback
          % Implemented as a local function
   
    % Add a text uicontrol to label the slider.
    ud.lLabel = uicontrol('Style','text',...
        'Position',[100 45 120 20],...
        'String',sprintf('Center Frequency Hz: %.03f',ud.center));
    
    uicontrol('Style', 'slider',...
        'Min',0,'Max',ud.maxFreq/2,'Value',ud.width,...
        'Position', [250 20 130 20],...
        'Callback', {@width_cb, h},...
        'SliderStep',[.0005 .01]/(.5)); 
    
    % Add a text uicontrol to label the slider.
    ud.hLabel = uicontrol('Style','text',...
        'Position',[250 45 120 20],...
        'String',sprintf('Bin width Hz: %.03f',2*ud.width));
   set(h.f,'userdata',ud); 
   set(h.f,'keypressfcn',{@keypressfcn,h});
   redraw(h);
  
end

function redraw(h)
    ud_loc = get(h.f,'userdata');
    im = getIm(ud_loc,[400,400]);
    imshow(im,[],'Parent',h.a1);colormap(jet())
    set(ud_loc.lLabel,'String',sprintf('Center Frequency: %.03f Hz',ud_loc.center))
    set(ud_loc.hLabel,'String',sprintf('Bin Width: %.03f Hz',2*ud_loc.width))
    
    
    [idx,c] = getIdx(ud_loc);
    [y,i_sorted]=max(ud_loc.MOV(:,:,idx),[],3);
    idx = i_sorted+idx(1)-1;
    
    f_idx = reshape(idx,[],1);

    
    npix = numel(ud_loc.MOV(:,:,1));
    pixIDX = (1:npix)';
    fullidx = pixIDX+npix*(f_idx-1);
    imphase = ud_loc.phase(fullidx);
    imphase = reshape(imphase,size(ud_loc.MOV(:,:,1)));
     imphaseCenter = ud_loc.phase(:,:,c);
     %imphaseCenter = mat2gray(imphaseCenter);
     imphase = imresize(imphase,[400,NaN]);
     imphaseCenter = imresize(imphaseCenter,[400,NaN]);
    figure(12)
    imshow([imphase]);colormap(hsv());caxis([-pi,pi]);colorbar;
    title('Summed Bins')
    figure(13)
    imshow([imphaseCenter]);colormap(hsv());caxis([-pi,pi]);colorbar;
    title('Center Bin Only')

    %imshow(imphase,'Parent',h.a2);colormap(hsv());freezeColors(h.a2);cbfreeze(colorbar);
    
    set(h.f,'userdata',ud_loc);
    
end

function [idx,c] = getIdx(ud)
    %% get the index calculated from center frequency and width
    c = round(ud.center*ud.maxBin/ud.maxFreq)+1;
    width = round(ud.width*ud.maxBin/ud.maxFreq);
 
    idx = c+[-width:width];
    idx = idx(idx>0);
    idx = idx(idx<=ud.maxBin);
end

function iml = getIm(ud,size)
%% get the sum along the frequency axis for the freq range specified in ud
    if nargin == 1
        size = [];
    end

    [idx,center] = getIdx(ud);
    iml = sum(ud.MOV(:,:,idx),3);
    if ud.log
        iml = log(iml);
    end
    iml = mat2gray(iml);
    if ~isempty(size)
        iml = imresize(iml,[600,NaN]);
    end
end


function keypressfcn(hObj,event,h)
    ud_loc = get(h.f,'userdata');
    switch event.Key
        case 'p'
            s=sprintf('Amin = %d;\n Amax = %d; \n Vmin = %.3g;\n Vmax = %.3g;\n Vstep = %.3g; ',ud_loc.amin,ud_loc.amax,ud_loc.vmin,ud_loc.vmax,ud_loc.vstep);
            disp(s)
        case 's'
             im = getIm(ud_loc);
             assignin('base','image',im);
        case 'l'
            ud_loc.log = ~ud_loc.log;
            ud_loc.log
   

    end
    redraw(h);
    set(h.f,'userdata',ud_loc);
end









function center_cb(hObj,event,h) %#ok<INUSL>
    % Called to set zlim of surface in figure axes
    % when user moves the slider control 
    ud_loc = get(h.f,'userdata');
    val = get(hObj,'Value');
  
   ud_loc.center = val;
      
    set(h.f,'userdata',ud_loc);
     redraw(h)
    
     
end

function width_cb(hObj,event,h) %#ok<INUSL>
    % Called to set zlim of surface in figure axes
    % when user moves the slider control 
    ud_loc = get(h.f,'userdata');
    val = get(hObj,'Value');
    
        ud_loc.width = val;
    set(h.f,'userdata',ud_loc);
        redraw(h);
   
     
end
