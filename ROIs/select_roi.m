function [ROIs]=select_roi(template,ROIs)
% this function proviedes a graphical user interface for selecting regions
% of interest in an image. the function returns a structure ROIs containing
% both indices and polygon vertices of the selected ROIs.


if nargin<2
    ROIs={};
end

start_ind=length(ROIs);

hf=figure(2);
clf;
set(hf,'menubar','none');
set(hf,'Userdata',ROIs);

ha=axes('position',[0 0 1 1]);
imagesc(template)
colormap gray
axis off
hold on

ht=text(size(template,1)/80,size(template,2)/40,'Press number to define ROI','color','white','fontweight','bold');
set(hf,'keypressfcn',{@select_roi_kpf,template,ht,start_ind});

go_on=1;

while go_on
    ROIs=get(hf,'Userdata');
    if isfield(ROIs,'done');
        if ROIs(1).done==1;
            go_on=0;
        end
    end
    pause(0.1);
end

ROIs = get(hf,'Userdata');
ROIs = rmfield(ROIs,'done');
ROIs = rmfield(ROIs,'h');
close(hf);

function select_roi_kpf(hf,e,template,ht,start_ind)

roi_colors='rgbycmrgbycmrgbycm';

ROIs=get(hf,'Userdata');
roi_nr=get(hf,'currentcharacter');
if ~isempty(str2num(roi_nr))
    set(ht,'string',['Please define ROI nr. ' roi_nr]);
    
    roi_nr=str2num(roi_nr)+start_ind;
    
    hpoly=imfreehand;
    tmp=get(hpoly,'Children');
    ROIs(roi_nr).vertices=get(tmp(5),'Vertices');
    ROIs(roi_nr).indices=find(poly2mask(ROIs(roi_nr).vertices(:,1),ROIs(roi_nr).vertices(:,2),size(template,1),size(template,1)));
    
    if isfield(ROIs,'h') & ishandle(ROIs(roi_nr).h)
        set(ROIs(roi_nr).h,'xdata',[ROIs(roi_nr).vertices(:,1);ROIs(roi_nr).vertices(1,1)],'ydata',[ROIs(roi_nr).vertices(:,2);ROIs(roi_nr).vertices(1,2)]);
    else        
        ROIs(roi_nr).h=plot([ROIs(roi_nr).vertices(:,1);ROIs(roi_nr).vertices(1,1)] ,[ROIs(roi_nr).vertices(:,2);ROIs(roi_nr).vertices(1,2)],'color',roi_colors(roi_nr-start_ind));
    end
    set(hpoly,'visible','off')
    
    set(hf,'Userdata',ROIs);
    set(ht,'string',['Press number to define next ROI, or space bar to end']);
    
elseif double(roi_nr)==32 % space bar
    
    ROIs(1).done=1;
    set(hf,'Userdata',ROIs);
end


