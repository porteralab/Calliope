function []=find_cells_gui(template,ROIs,ROItrans,act_map,orig_template)
% this function semi automatically finds ROIs in a template image.
%
% key commands:
% up arrow: increase detection threshold (less ROIs)
% down arrow: decrease detection threshold (more ROIs)
% a: add currently highlighted areas to the ROIs struct
% c: correct ROIs
% d: delete region below mouse pointer from ROIs struct
% e: estimate rotation
% f: fine adjust single roi select
% g: toggle between red and gray
% n: show numbers
% o: toggle original template
% p: toogle activity map
% q: load autosaved ROIs
% r: rotate ROIs
% s: save ROIs struct to workspace
% u: delete duplicated ROIs
% 0..9: categorize ROIs (hover over ROIs and press number)
% backspace: undo delete roi
% space: show all ROIs
% esc: delete all ROIs
% click and drag: zoom in on a subregion to do simple thresholding
% middle-click: collect ROIs to delete from all timepoints
% double-middle-click: show prompt to delete ROIs from all timepoints
%
% 2018 modified FW

if nargin<4
    act_map=template;
    disp('not using act map')
end

if nargin<5
    orig_template=template;
end

ud.win_size = round(min(size(template))/20);
ud.selected_to_delete=[];
template=template-min(template(:));
orig_template=orig_template-min(orig_template(:));

local_average = filter2(ones(ud.win_size)/ud.win_size^2,orig_template);
ot_fil = orig_template./local_average;

local_average = filter2(ones(ud.win_size)/ud.win_size^2,template);
t_fil = template./local_average;
t_fil(isnan(t_fil)) = 0;
if size(ot_fil,2)>size(t_fil,2)
    ot_fil=ot_fil(:,1:size(t_fil,2));
elseif size(ot_fil,2)<size(t_fil,2)
    ot_fil(:,end+1:size(t_fil,2))=0;
end

h.f=figure('menubar','none','color','k');
h.a1=axes('position',[0 0 0.975 1]);
axis off
h.a2=axes('position',[0.975 0 0.025 1],'color','k');
axis off

set(h.f,'keypressfcn',{@fcg_kpf,h,t_fil,act_map,ot_fil})
set(h.f,'WindowButtonDownFcn',{@fcg_wbdf,h,t_fil});
set(h.f,'WindowButtonUpFcn',{@fcg_wbuf,h,t_fil});
set(h.f,'pointer','crosshair');
set(h.f,'windowbuttonmotionfcn','1;');

% if ~isempty(ROIs)
%     [dx,dy]=register_frames(t_fil,ot_fil,0.2);
%     ROItrans(1:2)=[dx,dy];
% end

ud.threshold=0.5;
ud.act_threshold=mean(act_map(:));
ud.curr_down_point=[1 1];
ud.curr_up_point=size(t_fil);
ud.show_orig=0;
ud.show_act_map=0;
ud.min_num_pix_per_cell=100;
ud.act_min_num_pix_per_cell=20;
ud.ROItrans=ROItrans;
ud.show_labels=0;
ud.nbrRin=0;
ud.roi_fine_adjust=0;
ud.gray = 0;
ud.display=1;
ud.displayImages={t_fil,ot_fil,act_map};
ud.thresholds=[0.5,0.5,mean(act_map(:))];
ud.hasStructImage=false;
ud.firstcall = 1;

W = evalin('base','whos'); %or 'base'
ud.doesBUexist = ismember('ROI_backup_fcg',{W(:).name});

if ismember('template_sec',{W(:).name});
    ud.hasStructImage=evalin('base','sum(size(template_sec))~=0;');
else
    ud.hasStructImage=0;
end

if ud.hasStructImage
    layer = evalin('caller','z_plane');
    if layer == 0
        layer = 1;
        ud.structImage = evalin('base',['template_sec;']);
    else
        tmp = evalin('base',['template_sec{' num2str(layer) '};']);
        if size(tmp,3)>0
            tmp = squeeze(mean(tmp,3));
        end
        ud.structImage = tmp;
    end
    
    struct_av = filter2(ones(ud.win_size)/ud.win_size^2,ud.structImage);
    struct_fil = ud.structImage./struct_av;
    ud.displayImages=[ud.displayImages {struct_fil}];
    ud.thresholds = [ud.thresholds, 0.5];
end



if nargin>1 && ~isempty(fieldnames(ROIs))
    % remove the activity field
    ROIfields=fieldnames(ROIs);
    for ind=1:length(ROIfields)
        if strcmp(ROIfields(ind),'activity')
            ROIs=rmfield(ROIs,ROIfields(ind));
        elseif strcmp(ROIfields(ind),'dff')
            ROIs=rmfield(ROIs,ROIfields(ind));
        end
        
    end
    if ~isfield(ROIs,'type')
        for ind=1:length(ROIs)
            ROIs(ind).type='c';
        end
    end
    ud.ROIs=ROIs;
    ud.potROIs=ROIs;
    ud.nbrRin=length(ROIs);
    set(h.f,'userdata',ud);
    plot_ROIs(h);
else
    set(h.f,'userdata',ud);
    find_bright_regions(t_fil,h,1);
end




function fcg_kpf(a,event,h,t_fil,act_map,ot_fil)
% curr_key=double(get(gcf,'currentcharacter'));
ud=get(h.f,'userdata');
do_find=0;
nbr = str2double(event.Key);
if isnan(nbr)
    eventKey= event.Key;
else
    eventKey='number';
end
switch eventKey
    case 'space' % show all ROIs
        ud.curr_down_point=[1 1];
        ud.curr_up_point=size(t_fil);
        do_find=2;
        if ~isfield(ud,'ROIs');
            ud.ROIs=ud.potROIs;
        end
    case 'backspace' % undo delete, will add last deleted ROI to potROIs
        if isfield(ud,'deletedROIs')
            if isfield(ud,'potROIs')
                ud.potROIs(end+1:end+length(ud.deletedROIs)) = ud.deletedROIs;
            else
                ud.potROIs = ud.deletedROIs;
            end
            ud.deletedROIs
            ud = rmfield(ud,'deletedROIs');
        end
        
        do_find=2;
    case 'q'
        %assign BU ROIs to ud.ROI
        if ud.doesBUexist
            s=input('Do you want to replace your ROIs (y/n)?','s');
            if strcmp(s,'y')
                temp = evalin('base','ROI_backup_fcg');
                ud.ROIs = temp;
                if isfield(ud,'potROIs')
                    ud = rmfield(ud,'potROIs');
                end
            end
            do_find=2;
        end
        
    case 'a' % a - add ROIs
        if isfield(ud,'ROIs') && isfield(ud,'potROIs');
            ud.ROIs(end+1:end+length(ud.potROIs))=ud.potROIs;
        elseif isfield(ud,'potROIs')
            
            ud.ROIs=ud.potROIs;
        end
        %now remove the potROIs
        if isfield(ud,'potROIs')
            ud = rmfield(ud,'potROIs');
        end
        assignin('base','ROI_backup_fcg',ud.ROIs);
        do_find=2;
    case 'n' % show numbers
        ud.show_labels=~ud.show_labels;
        do_find=2;
    case 's' % s - save ROIs
        for ind=1:length(ud.ROIs)-1
            for knd=ind+1:length(ud.ROIs)
                if length(intersect(ud.ROIs(ind).indices,ud.ROIs(knd).indices))>0
                    disp(['WARNING: ROI ' num2str(ind) ' and ROI ' num2str(knd) ' overlap']);
                end
            end
        end
        
        try
            z_plane=evalin('base','z_plane');
        catch
            z_plane = -1;
        end
        if z_plane>0
            assignin('base','ud_ROIs',ud.ROIs);
            evalin('base','ROIs{z_plane}=ud_ROIs;');
            assignin('base','ud_ROItrans',ud.ROItrans);
            evalin('base','ROItrans{z_plane}=ud_ROItrans;');
            evalin('base','bv{z_plane}=find_bv(template{z_plane},1);');
            evalin('base','np{z_plane}=find_np(template{z_plane},ROIs{z_plane},bv{z_plane});');
        else
            assignin('base','ROIs',ud.ROIs);
            assignin('base','ROItrans',ud.ROItrans);
            evalin('base','bv=find_bv(template,1);');
            evalin('base','np=find_np(template,ROIs,bv);');
        end
        
        disp('ROIs saved to workspace')
        
        
    case 'r' % r - rotate ROIs
        rot_angle=input('Rotate ROIs by what angle? (0 for undo prev rot.): ');
        for ind=1:length(ud.ROIs)
            ud.ROIs(ind).indices=ud.ROIs(ind).indices-ud.ROItrans(1)-ud.ROItrans(2)*size(act_map,1);
        end
        ud.ROItrans(1)=0;
        ud.ROItrans(2)=0;
        if rot_angle==0
            ud.ROIs=ud.ROIsBU;
            ud.ROItrans=ud.ROItransBU;
        else
            if ~isfield(ud,'ROIsBU')
                ud.ROIsBU=ud.ROIs;
                ud.ROItransBU=ud.ROItrans;
            end
            ud.ROIs=rotate_ROIs(ud.ROIs,rot_angle,size(act_map));
            ud.ROItrans(3)=ud.ROItrans(3)+rot_angle;
        end
        do_find=2;
        
    case 'e' % estimate roatation
        
        disp('Estimate rotation - select 1. origin, 2. ROI point, 3. template point');
        tmp_p=ginput(3);
        tmp_p(:,1)=tmp_p(:,1)/1.5;
        x1=tmp_p(2,:)-tmp_p(1,:);
        x2=tmp_p(3,:)-tmp_p(1,:);
        disp(['Estimated angle is : ' num2str(-acos(sum(x1.*x2)/norm(x1)/norm(x2))/pi*180)]);
        ud.curr_down_point=[1 1];
        ud.curr_up_point=size(t_fil);
        do_find=2;
    case 'h'
        help find_cells_gui
        
    case 'escape' % esc - clear all ROIs
        if strcmp(questdlg('clear all ROIs?'),'Yes')
            ud.curr_down_point=[1 1];
            ud.curr_up_point=size(t_fil);
            if isfield(ud,'ROIs');
                
                ud=rmfield(ud,'ROIs');
                ud.nbrRin=0;
                if isfield(ud,'potROIs')
                    ud = rmfield(ud,'potROIs');
                end
            end
            do_find=2;
        end
    case 'number'
        if strcmp(event.Modifier,'shift')
            for ind=1:length(ud.ROIs)
                ud.ROIs(ind).type=nbr;
            end
        else
            del_ind=get(h.a1,'currentpoint');
            del_ind=round(del_ind([3 1]));
            del_ind=sub2ind(size(t_fil),del_ind(1),del_ind(2));
            cnt=0;
            if isfield(ud,'ROIs')
                for ind=1:length(ud.ROIs)
                    if sum(ud.ROIs(ind).indices==del_ind)
                        cnt=cnt+1;
                        del_cnt(cnt)=ind;
                        break;
                    end
                end
            end
            % % %         if ~sum(del_cnt<=ud.nbrRin)
            if exist('del_cnt');
                ud.ROIs(del_cnt).type=nbr;
            end
        end
        
        do_find=2;
        
        
    case 'd' % d - delete ROIs
        
        %convert current mouse position to index
        del_ind=get(h.a1,'currentpoint');
        del_ind=round(del_ind([3 1]));
        if strcmp(event.Modifier,'shift')
            del_ind=sub2ind(size(t_fil),[del_ind(1)+[-20:20] del_ind(1)+zeros(1,41)],[del_ind(2)+[-20:20] del_ind(2)+zeros(1,41)]);
        else
            del_ind=sub2ind(size(t_fil),del_ind(1),del_ind(2));
        end
        cnt=0;
        if isfield(ud,'ROIs')
            for ind=1:length(ud.ROIs)
                %go through all ROIs and get the ones overlapping with the
                %del_ind
                if sum(ismember(del_ind,ud.ROIs(ind).indices))
                    cnt=cnt+1;
                    del_cnt(cnt)=ind;
                end
            end
        end
        if exist('del_cnt');
            %             if ~sum(del_cnt<=ud.nbrRin)
            %save deleted ROIs
            ud.deletedROIs = ud.ROIs(del_cnt);
            ud.ROIs=ud.ROIs(setdiff([1:length(ud.ROIs)],del_cnt));
            %             end
        else
            disp('Warning cannot delete loaded ROI')
        end
        
        do_find=2;
    case 'u' % u - delete duplicates
        del_cnt=[];
        for ind=1:length(ud.ROIs)-1
            for knd=ind+1:length(ud.ROIs)
                if length(intersect(ud.ROIs(ind).indices,ud.ROIs(knd).indices))>0
                    disp(['ROI ' num2str(ind) ' and ROI ' num2str(knd) ' overlap']);
                    del_cnt=[del_cnt knd];
                end
            end
        end
        disp(['Found ' num2str(length(del_cnt)) ' overlapping ROIs']);
        delete_duplicates=input('Delete all overlapping ROIs?: ');
        if delete_duplicates
            ud.ROIs=ud.ROIs(setdiff([1:length(ud.ROIs)],del_cnt));
            do_find=2;
        end
    case 'o' % o - toggle original template
        %ud.show_orig=~ud.show_orig;
        %ud.show_act_map=0;
        if ud.display ~=2
            ud.display = 2;
        else
            ud.display = 1;
        end
        do_find=2;
    case 'p' % p - toggle act map
        %         ud.show_act_map=~ud.show_act_map;
        %         ud.show_orig=0;
        if ud.display ~=3
            ud.display = 3;
        else
            ud.display = 1;
        end
        do_find=2;
    case 'l' % p - toggle act map
        %         ud.show_act_map=~ud.show_act_map;
        %         ud.show_orig=0;
        if ud.hasStructImage
            if ud.display ~=4
                ud.display = 4;
            else
                ud.display = 1;
            end
            do_find=2;
        end
    case 'c' % correct rois
        if strcmp(event.Modifier,'shift')
            [dxf,dyf,dxF,dyF]=fine_ROI_matching(ud.ROIs,t_fil,ot_fil,0,ud.ROItrans);
            dxF=0;
            dyF=0;
        else
            [dxf,dyf,dxF,dyF]=fine_ROI_matching(ud.ROIs,t_fil,ot_fil);
            ud.ROItrans(1:2)=[dxF dyF];
        end
        
        for ind=1:numel(ud.ROIs)
            ud.ROIs(ind).indices=ud.ROIs(ind).indices+(dyF+dyf(ind))*size(act_map,1);
            ud.ROIs(ind).indices=ud.ROIs(ind).indices+(dxF+dxf(ind));
            ud.ROIs(ind).shift=[dxf(ind) dyf(ind)];
        end
        
        do_find=3;
        
    case 'f' % fine adjust single roi select
        if strcmp(event.Modifier,'shift')
            ud.roi_fine_adjust=input('Which ROI would you like to fine adjust: ');
        else
            del_ind=get(h.a1,'currentpoint');
            del_ind=round(del_ind([3 1]));
            del_ind=sub2ind(size(t_fil),del_ind(1),del_ind(2));
            if isfield(ud,'ROIs')
                for ind=1:length(ud.ROIs)
                    if any(ud.ROIs(ind).indices==del_ind)
                        ud.roi_fine_adjust=ind;
                        break;
                    end
                end
            end
        end
        disp(['Now fine adjusting ROI nbr. ' num2str(ud.roi_fine_adjust)]);
        
    case 'rightarrow'
        if length(event.Modifier)==1 && strcmp(event.Modifier,'shift')
            for ind=1:length(ud.ROIs)
                ud.ROIs(ind).indices=ud.ROIs(ind).indices+size(act_map,1);
            end
            do_find=2;
            ud.ROItrans(2)=ud.ROItrans(2)+1;
        elseif length(event.Modifier)==1 && strcmp(event.Modifier,'control')
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices+size(act_map,1);
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift+[0 1];
            do_find=3;
        elseif length(event.Modifier)==2
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices+10*size(act_map,1);
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift+[0 10];
            do_find=3;
        else
            ud.min_num_pix_per_cell=ud.min_num_pix_per_cell+10
        end
    case 'leftarrow'
        if length(event.Modifier)==1 && strcmp(event.Modifier,'shift')
            for ind=1:length(ud.ROIs)
                ud.ROIs(ind).indices=ud.ROIs(ind).indices-size(act_map,1);
            end
            do_find=2;
            ud.ROItrans(2)=ud.ROItrans(2)-1;
        elseif length(event.Modifier)==1 && strcmp(event.Modifier,'control')
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices-size(act_map,1);
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift-[0 1];
            do_find=3;
        elseif length(event.Modifier)==2
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices-10*size(act_map,1);
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift-[0 10];
            do_find=3;
        else
            ud.min_num_pix_per_cell=ud.min_num_pix_per_cell-10
        end
    case 'uparrow'
        if length(event.Modifier)==1 && strcmp(event.Modifier,'shift')
            for ind=1:length(ud.ROIs)
                ud.ROIs(ind).indices=ud.ROIs(ind).indices-1;
            end
            do_find=2;
            ud.ROItrans(1)=ud.ROItrans(1)-1;
        elseif length(event.Modifier)==1 && strcmp(event.Modifier,'control')
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices-1;
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift-[1 0];
            do_find=3;
        elseif length(event.Modifier)==2
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices-10;
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift-[10 0];
            do_find=3;
        else
            ud.thresholds(ud.display)=ud.thresholds(ud.display)+0.05;
            %             if ud.display==2%ud.show_act_map
            %                 ud.act_threshold = ud.act_threshold + 0.01;
            %             else
            %                 ud.threshold = ud.threshold + 0.05;
            %             end
            do_find=1;
        end
    case 'downarrow'
        if length(event.Modifier)==1 && strcmp(event.Modifier,'shift')
            for ind=1:length(ud.ROIs)
                ud.ROIs(ind).indices=ud.ROIs(ind).indices+1;
            end
            do_find=2;
            ud.ROItrans(1)=ud.ROItrans(1)+1;
        elseif length(event.Modifier)==1 && strcmp(event.Modifier,'control')
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices+1;
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift+[1 0];
            do_find=3;
        elseif length(event.Modifier)==2
            
            ud.ROIs(ud.roi_fine_adjust).indices=ud.ROIs(ud.roi_fine_adjust).indices+10;
            ud.ROIs(ud.roi_fine_adjust).shift=ud.ROIs(ud.roi_fine_adjust).shift+[10 0];
            do_find=3;
        else
            ud.thresholds(ud.display)=ud.thresholds(ud.display)-0.05;
            do_find=1;
        end
    case 'g'
        ud.gray = ~ud.gray;
        do_find = 2;
end

set(h.f,'userdata',ud);
if do_find==1
    %find bright regions
    if ud.curr_down_point(1)==1
        find_bright_regions(ud.displayImages{ud.display},h,1)
    else
        find_bright_regions(ud.displayImages{ud.display},h,0);
    end
elseif do_find==2
    plot_ROIs(h,0)
elseif do_find==3
    plot_ROIs(h,1);
end


function fcg_wbdf(a,b,h,t_fil)
ud=get(h.f,'userdata');
curr_down_point=get(gca,'currentpoint');
ud.curr_down_point=round(curr_down_point([3 1]));
persistent doubleclick
if strcmp(get(a,'selectiontype'),'extend') || (strcmp(get(a,'selectiontype'),'open')  && doubleclick~=0 )
    if isempty(doubleclick) || doubleclick==0
            del_ind=get(h.a1,'currentpoint');

        doubleclick = 1;
        pause(0.3); %delay to distinguish single from a double click
        if doubleclick == 1
            del_ind=round(del_ind([3 1]));
            del_ind=sub2ind(size(t_fil),del_ind(1),del_ind(2));
            if isfield(ud,'ROIs')
                for ind=1:length(ud.ROIs)
                    if any(ud.ROIs(ind).indices==del_ind)
                        thisROI=ind;
                        ud.ROIs(ind).type=8;
                        if ~ismember(thisROI, ud.selected_to_delete)
                            ud.selected_to_delete=[ud.selected_to_delete thisROI];
                            undeleteROI=0;
                        else
                            undeleteROI=1;
                        end
                        break;
                    end
                end
            end
            if exist('thisROI','var')
                if ~undeleteROI
                fprintf('selected ROI #%i to deletion queue\n', thisROI)
                else
                    ud.ROIs(ind).type=0;
                    ud.selected_to_delete(ud.selected_to_delete==thisROI)=[];
                    fprintf('selected ROI #%i removed from deletion queue\n', thisROI)
                end
                set(h.f,'userdata',ud);
                plot_ROIs(h,0);

            else
                set(h.f,'userdata',ud);
                
            end
            doubleclick = 0;
        end
    else
        if ~isempty(ud.selected_to_delete) && doubleclick~=2
            doubleclick=2;
            evalstr= ['delete_ROI([' regexprep(num2str(ud.selected_to_delete),'\s+',',') '],adata_dir,ExpGroup,z_plane,1)'];
            if strcmp(input([evalstr '\n\nevaluate this code in base workspace? [y|n] ' ],'s'),'y')
                doubleclick = 0;
                evalin('base',evalstr);
            else
                doubleclick = 0;
                [ud.ROIs(ud.selected_to_delete).type]=deal(0);
                ud.selected_to_delete=[];
                set(h.f,'userdata',ud);
                plot_ROIs(h,0);
            end
        end
    end
else
    set(h.f,'userdata',ud);
end

function fcg_wbuf(a,b,h,t_fil)
if  ~any(strcmp(get(a,'selectiontype'),{'extend','open'}))
    ud=get(h.f,'userdata');
    curr_up_point=get(gca,'currentpoint');
    ud.curr_up_point=round(curr_up_point([3 1]));
    set(h.f,'userdata',ud);
    if ud.curr_up_point~=ud.curr_down_point
        find_bright_regions(t_fil,h,0);
    end
end

function plot_ROIs(h,show_df)
%plot the current ROIs saved in ud
ud=get(h.f,'userdata');

if nargin<2
    show_df=0;
end
dispImage=ud.displayImages{ud.display};
masks=false([size(dispImage),10]);
t_mask_pot = false(size(dispImage));

if isfield(ud,'ROIs')
    for ind=1:length(ud.ROIs)
        tmp=false(size(dispImage));
        try
            %for compatibility
            tmp(ud.ROIs(ind).indices) = 1;
            if isempty(ud.ROIs(ind).type)
                ud.ROIs(ind).type=0;
            end
            if strcmp(ud.ROIs(ind).type,'c')
                masks(:,:,1)=masks(:,:,1) | tmp;
            elseif strcmp(ud.ROIs(ind).type,'d')
                masks(:,:,2)=masks(:,:,2) | tmp;
            else
                masks(:,:,ud.ROIs(ind).type+1) = masks(:,:,ud.ROIs(ind).type+1) | tmp;
            end
        catch exception
            exception.message
            disp(['ROI nbr. ' num2str(ind) ' has moved off of the frame'])
        end
    end
end

if isfield(ud,'potROIs')
    for ind=1:length(ud.potROIs)
        try
            if strcmp(ud.potROIs(ind).type,'c')
                t_mask_pot(ud.potROIs(ind).indices)=1;
            end
        catch
            disp(['ROI nbr. ' num2str(ind) ' has moved off of the frame'])
        end
    end
end
tmp=mat2gray(dispImage);
max_cont=mean(tmp(~isnan(tmp)))+2*std(tmp(~isnan(tmp)));
min_cont=mean(tmp(~isnan(tmp)))-2*std(tmp(~isnan(tmp)));
if max_cont >1
    max_cont=1;
end
if min_cont<0
    min_cont = 0;
end


set(h.f,'CurrentAxes',h.a1)
cla;
hold off

tmp = imadjust(tmp,[min_cont max_cont],[]);


if ~ud.gray
    overlay = zeros([size(tmp,1),size(tmp,2),3]);
    overlay(:,:,1)=tmp;
else
    overlay = tmp;
end
roiColors=jet(10);
roiColors(1,:)=[0 1 0];

if isfield(ud,'ROIs'), iis=unique([ud.ROIs.type])+1; else, iis=1:10; end
for ii = iis
    overlay = imoverlay(overlay,bwperim(masks(:,:,ii)),roiColors(ii,:));
end

overlay = imoverlay(overlay,bwperim(t_mask_pot),[1 0 0]);

imshow(overlay,[])
hold on
if isfield(ud,'ROIs') && ud.show_labels
    for ind=1:length(ud.ROIs)
        [txt_x,txt_y]=ind2sub(size(dispImage),min(ud.ROIs(ind).indices));
        text(txt_y,txt_x,num2str(ind),'color',[1 1 1]*0.75,'fontsize',20,'fontweight','bold')
    end
end
xl=xlim;
yl=ylim;
try
    if ud.display==2
        title_string=['Nr. ROIs: ' num2str(length(ud.ROIs)) ' **** original ****'];
    else
        title_string=['Nr. ROIs: ' num2str(length(ud.ROIs)) '  --- trans: ' num2str(ud.ROItrans')];
    end
catch
    title_string=['Nr. ROIs: 0'];
end
text(xl(2)/50,yl(2)/20,title_string,'color','w','fontsize',20,'fontweight','bold');
if show_df
    for ind=1:length(ud.ROIs)
        [Rx,Ry]=ind2sub(size(dispImage),ud.ROIs(ind).indices);
        plot([0 -ud.ROIs(ind).shift(2)]+mean(Ry),[0 -ud.ROIs(ind).shift(1)]+mean(Rx),'w','linewidth',2)
        plot(mean(Ry),mean(Rx),'.w','markersize',20)
    end
end

function find_bright_regions(t_fil,h,full_frame)
% find bright regions and plot them
ud=get(h.f,'userdata');
dx=sort([ud.curr_down_point(1) ud.curr_up_point(1)]);
dy=sort([ud.curr_down_point(2) ud.curr_up_point(2)]);
t_mask=zeros(size(t_fil));
if ud.display==3 % for ac map
    t_mask(t_fil>ud.thresholds(3))=1;
else % for all other maps
    if ud.firstcall
        t_fil = ntzo(t_fil);
        
        % Initialize segmentation with Otsu's threshold
        level = graythresh(t_fil);
        mask = im2bw(t_fil,level);
        
        % Evolve segmentation
        t_mask = activecontour(t_fil, mask, 25, 'Chan-Vese');
        
        % Suppress components connected to image border
        t_mask = imclearborder(t_mask);
        
        % Fill holes
        t_mask = imfill(t_mask, 'holes');
        
        ud.firstcall = 0;
    else
        t_mask(t_fil > median(t_fil(~isnan(t_fil))) + ud.thresholds(ud.display) * ...
            std(t_fil(~isnan(t_fil)))) = 1;
    end
end
%%% get rid of border regions
t_mask(1:max(dx(1),ud.win_size+1),:)=0;
t_mask(min(dx(2),size(t_mask,1)-ud.win_size):size(t_mask,1),:)=0;
t_mask(:,1:max(dy(1),ud.win_size+1))=0;
t_mask(:,min(dy(2),size(t_mask,2)-ud.win_size):size(t_mask,2))=0;
t_mask=logical(t_mask);

if full_frame
    t_mask = bwareafilt(t_mask, [ud.min_num_pix_per_cell Inf]);
    
    t_labels = bwlabel(t_mask);
else
    t_mask = bwareaopen(t_mask, 20);
    t_labels = t_mask;
end
% figure;imagesc(t_mask)
for ind=1:double(max(t_labels(:)))
    potROIs(ind).indices = find(t_labels==ind);
    potROIs(ind).type=0;
    
    potROIs(ind).shift=[0 0];
end
if exist('potROIs');
    ud.potROIs=potROIs;
end
max_cont=mean(t_fil(~isnan(t_fil)))+2*std(t_fil(~isnan(t_fil)));
min_cont=mean(t_fil(~isnan(t_fil)))-2*std(t_fil(~isnan(t_fil)));
axes(h.a1);
cla
hold off
tmp=(t_fil-min_cont)/(max_cont-min_cont);
tmp(tmp>1)=1;
tmp(tmp<0)=0;

if ~ud.gray
    overlay = zeros([size(tmp,1),size(tmp,2),3]);
    overlay(:,:,1)=tmp;
else
    overlay = tmp;
end

overlay = imoverlay(overlay,bwperim(t_mask),[0 1 0]);

%imagesc(overlay)
imshow(overlay,[])
xlim(dy)
ylim(dx)

axes(h.a2)
cla
curr_selection=t_fil(dx(1):dx(2),dy(1):dy(2));
[hx,hy]=hist((curr_selection(:)-median(curr_selection(:)))/std(curr_selection(:)),[-3:0.1:3]);
plot(hx,hy,'w','linewidth',2)
hold on
xl=xlim;
plot(xl,[1 1]*ud.thresholds(ud.display),'r','linewidth',2);
axis off

set(h.f,'userdata',ud);


