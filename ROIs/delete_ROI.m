function []=delete_ROI(del_ind,adata_dir,ExpGroup,z_plane,autoreload)
% deletes ROIs in all ExpIDs of a site
% usage:
% delete_ROI([1 3 10:12],adata_dir,ExpGroup,z_plane)
%
% documented & edited FW 14.03.2018
% 2018 FW: added autoreload parameter

warning('off','MATLAB:load:variableNotFound')

if ~exist('adata_dir','var'), adata_dir=evalin('base','adata_dir'); warning('added *adata_dir* variable from base workspace'); end
if ~exist('ExpGroup','var'), ExpGroup=evalin('base','ExpGroup'); warning('added *ExpGroup* variable from base workspace'); end
if ~exist('z_plane','var'), z_plane=evalin('base','z_plane'); warning('added *z_plane* variable from base workspace'); end

ExpLog = getExpLog;

cnt=0;
for knd=ExpGroup'
    cnt=cnt+1;
    [curr_adata_file,curr_mouse_id,userID]=get_adata_filename(knd,adata_dir,ExpLog);
    if isempty(curr_adata_file)
        disp(['Exp ' num2str(knd) ' does not have a Adata file - skipping']);
    elseif strcmp(curr_adata_file(1:9),'mean_data')
        disp(['Exp ' num2str(knd) ' is a z-stack - skipping']);
    else
        fname=[adata_dir userID '\' curr_mouse_id '\' curr_adata_file];
        curr=load(fname,'ROIs');
        if cnt==1
            nbr_main_ROIs=length(curr.ROIs{z_plane});
        end
        if length(curr.ROIs{z_plane})==nbr_main_ROIs
            curr.ROIs{z_plane}=curr.ROIs{z_plane}(setdiff([1:length(curr.ROIs{z_plane})],del_ind));
            disp(['Now saving ' fname])
            ROIs=curr.ROIs;
            save(fname,'ROIs','-append');
        else
            disp(['Exp ' num2str(knd) ' has probably not been analyzed yet']);
        end
    end
end

warning('on','MATLAB:load:variableNotFound')

disp(['--- Done deleting ROI ' num2str(del_ind) ' ---']);
disp('--- RELOAD CURRENT ROIS ---');

if exist('autoreload','var') %experimental: reload for you
    try
        ca;
        disp('   xxxx   reloading *.ini file for you   xxxx   ');
        cal=handle(1001);
        cal.Children(4).Value=find(~cellfun('isempty',regexpi(cal.Children(4).String,'ini','once')));
        calliope_press(cal,cal.Children(14));
        calliope_press(cal,cal.Children(13));
    catch
    end
end
end

function calliope_press(cal,element)
mycall=get(element,'Callback');
mycall{1}(cal,[],mycall{2:end})
end