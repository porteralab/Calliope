function calliope(reload_adata_list,isdocked)
%calliope(reload_adata_list,isdocked)
% Main graphical user interface for data loading
%
%Calliope is a graphical user interface that allows to load imaging data.
%To be able to access the data with calliope the user needs to specifiy the
%project specific network paths in the function "ProjectDefaults_PROJID".
%This is also necessary for the "primary_backup" function. In order to be
%able to see the saved imaging files (.ach, .eye, .lvd, .bin, .ini) the
%user needs to be logged into the machine where the data has been backed up
%(e.g. Keller-Rig1-Ana). This interface is used for operations like
%registering the data, select ROIs or calculate the activity of selected
%ROIs. First select your user name, e.g. kellgeor, second select the
%project, animal and expID you want to work on. Choose your operation by
%clicking on one of the buttons in the interface.
%
% set isdocked to 1 to load calliope docked to the main matlab window
%
%-------Operations to choose-------
%
%load:        loads selected file types into workspace;
%select ROIs: select regions of interes (ROIs) in activity map per z-layer.
%             Follow on screen instructions for selecting
%             z-layer and the use of either saved or new ROIs for
%             particular layer/timepoint;
%             See "find_cells_gui" for furhter explanations how to select ROIs.
%save A-data: saves selected ROIs to the file;
%plot it:     outdated; use "cell_browser" instead;
%get adata:   outdated (if PC is fast enough); loading .ini files is fast
%             enough to look at all parameters;
%reg. dir:    registers raw imaging data in order to be able to select ROIs;
%             Registration can be manually corrected with e.g. "correct_dxdy";
%calc act:    calculates activity of selected ROIs for specified
%             project/animals;
%data expl.:  outdated; use "cell_browser" instead;
%load meta:   opens up directory with project meta files; either select meta
%             file via this option of just drag and drop the meta file directly into
%             MatLab;
%
%--------Example for selecting ROIs-------
%
%Select user name, project, animalID, expID;
%click load: load data into the workspace (select file types in the right box);
%click select ROIs: select ROIs for specified ExpID and layer (user input);
%save A-data: selected ROIs will be save to file;
%calc act: calculate activity of selected ROIs, when done with ROIing of
%all timepoint and z-layers;
%
%
%-------Other helpful functions for calliope-------
%
%proj_info(projID):
%       show all sites of project, e.g. proj_info("M1");
%check_siteROIs(siteID,AdataCode,displayfigures):
%       list all experiments of a site and show ROIs, e.g. check_siteROIs(13123,1,1);
%       AdataCode "1" will result in showing only expIDs that have been selected
%       to go into analysis. See "set_adata_code" for how to select expIDs for analysis.
%       "displayfigures" is "0 (do not show)" or "1(show)";
%set_adata_code:
%       set the adata code for indiviual experiments;
%change_siteID(siteIDold,siteIDnew):
%       change the siteID; new siteID will become the new original image for alinging ROIs;
%
%These descriptions can also be found under the "help" button on the
%calliope interface;
%
%written by GK - 01.01.2012;
%documented by DM - 08.05.2014;

if ishandle(1001) %if calliope is open, don't open it again...
    figure(1001);
    return;
end

if nargin<1
    reload_adata_list=0;
end

if nargin<2
    isdocked=1;
end

adata_dir=set_lab_paths;

cah.hf=figure(1001);
clf
set(cah.hf,'name','calliope','numberTitle','off');
mon_pos=get(0,'MonitorPositions');
set(cah.hf,'color','k','menubar','none');

if isdocked
    set(cah.hf,'WindowStyle','docked');
else
    set(cah.hf,'position', [mon_pos(1,1)+round(0.85*(mon_pos(1,3)-mon_pos(1,1))) 150 250 350]);
end

ud=struct;
set(cah.hf,'UserData',ud);

ExpLog=getExpLog;
assignin('base','ExpLog', ExpLog);

tmp = dir(adata_dir);
if isempty(tmp)
    eval(['!start /max ' adata_dir])
    disp('Please log into argon and start calliope again.')
    return
end
assignin('base','adata_dir',adata_dir);

if reload_adata_list
    [adata_list]=list_all_adata_files(adata_dir,1);
else
    load([adata_dir 'adata_list.mat'],'adata_list');
end

global adata_list_num;
adata_list_num=zeros(1,length(adata_list));
for znd=93:length(adata_list)
    adata_list_num(znd)=str2num(adata_list{znd});
end

global hostname
[~,hostname]=system('hostname');
% "name" ends on a carriage return in Win7
hostname=hostname(hostname~=10);


lb1=0.05;
lb2=0.4;
lb3=0.725;
wf=0.9;
w0=0.625;
w1=0.325;
w2=0.275;
w3=0.225;
h1=0.06;
h2=0.015;

h_ind=13;
cah.title_string=uicontrol('style','edit',...
    'string','nothing loaded',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 wf h1],...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','r');

h_ind=12;
cah.user_select=uicontrol('style','popupmenu',...
    'string','-',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w0 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');

h_ind=11;
cah.project_select=uicontrol('style','popupmenu',...
    'string','-',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w0 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');

h_ind=10;
cah.mouse_select=uicontrol('style','popupmenu',...
    'string','-',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w0 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');

h_ind=9;
cah.exp_select=uicontrol('style','popupmenu',...
    'string','-',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w0 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');


h_ind=8;
cah.load=uicontrol('style','pushbutton',...
    'string','load',...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w1 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left');

h_ind=7;
cah.select_rois=uicontrol('style','pushbutton',...
    'string','select ROIs',...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w1 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left');

h_ind=6;
cah.save_adata=uicontrol('style','pushbutton',...
    'string','save A-data',...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w1 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',@save_Adata_callback);
h_ind=5;
cah.check_reg_data=uicontrol('style','pushbutton',...
    'string','check reg',...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 w1 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',{@check_reg_callback,ExpLog,cah,adata_dir});

h_ind=8;
cah.preview_adata=uicontrol('style','pushbutton',...
    'string','get adata',...
    'units','normalized',...
    'position',[lb2 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',{@preview_adata_callback,ExpLog,cah,adata_dir});

h_ind=7;
cah.register_entire_dir=uicontrol('style','pushbutton',...
    'string','reg. dir',...
    'units','normalized',...
    'position',[lb2 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',{@register_entire_dir_callback,ExpLog,cah,adata_dir});

h_ind=6;
cah.calc_act=uicontrol('style','pushbutton',...
    'string','calc act',...
    'units','normalized',...
    'position',[lb2 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',{@calcROIact,ExpLog,cah,adata_dir});

h_ind=5;
cah.view_tif=uicontrol('style','pushbutton',...
    'string','data expl.',...
    'units','normalized',...
    'position',[lb2 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback',{@view_tiff_callback,ExpLog,cah,adata_dir});

h_ind=5;
cah.load_meta=uicontrol('style','pushbutton',...
    'string','load meta',...
    'units','normalized',...
    'position',[lb3 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left');

h_ind=6;
cah.help=uicontrol('style','pushbutton',...
    'string','Help',...
    'units','normalized',...
    'position',[lb3 (h1+h2)*h_ind-h1 w2 h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'callback','type(''help.txt'')');


h_ind=8;
cah.ftypes=uicontrol('style','listbox',...
    'string','-',...
    'units','normalized',...
    'position',[lb3 (h1+h2)*h_ind-h1 w3 6*h1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'HorizontalAlignment','left',...
    'Min',1,'Max',10);

h_ind=1;
cah.comments=uicontrol('style','listbox',...
    'string','-',...
    'value',1,...
    'units','normalized',...
    'position',[lb1 (h1+h2)*h_ind-h1 wf 5*h1-h2],...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor',[0 0.8 0],...
    'Max',10,...
    'SelectionHighlight','off',...
    'HorizontalAlignment','left');

h_ind=7;
cah.Acode_label=uicontrol('style','text',...
    'string','Acode',...
    'units','normalized',...
    'position',[lb3 (h1+h2)*h_ind-h1 w2/2 h1],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor',[0 0.8 0]);
cah.Acode=uicontrol('style','text',...
    'string','',...
    'units','normalized',...
    'fontweight','bold',...
    'position',[lb3+w2/2 (h1+h2)*h_ind-h1 w2/2 h1],...
    'HorizontalAlignment','left',...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor',[0.8 0 0]);

[userIDs,~,ExpStrs,~,mouseIDs,~,projectIDs,comments]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.user_select,'string',userIDs,'value',1);
set(cah.project_select,'string',projectIDs,'value',1);
set(cah.mouse_select,'string',mouseIDs,'value',1);
set(cah.exp_select,'string',ExpStrs,'value',1);
set(cah.ftypes,'string','further specify selection')
set(cah.comments,'string',comments{get(cah.exp_select,'value')});

set(cah.user_select,'callback',{@user_select_callback,cah,ExpLog,adata_dir});
set(cah.project_select,'callback',{@project_select_callback,cah,ExpLog,adata_dir});
set(cah.mouse_select,'callback',{@mouse_select_callback,cah,ExpLog,adata_dir});
set(cah.exp_select,'callback',{@exp_select_callback,cah,ExpLog,adata_dir});
set(cah.select_rois,'callback',{@select_rois_callback,ExpLog,cah,adata_dir});
set(cah.load,'callback',{@load_callback,ExpLog,cah,adata_dir});
set(cah.check_reg_data,'callback',{@check_reg_callback,ExpLog,cah,adata_dir});
set(cah.view_tif,'callback',{@view_tiff_callback,ExpLog,cah,adata_dir});
set(cah.load_meta,'callback',{@load_meta_callback,cah});
set(cah.hf,'HandleVisibility','off','IntegerHandle','on')

function user_select_callback(e,h,cah,ExpLog,adata_dir)
set(cah.project_select,'string','loading...');

set(cah.project_select,'value',1);
set(cah.mouse_select,'value',1);
[~,~,~,~,~,~,projectIDs]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.project_select,'string',projectIDs);

project_select_callback(e,h,cah,ExpLog,adata_dir)

function project_select_callback(e,h,cah,ExpLog,adata_dir)
ud=get(cah.hf,'UserData');
set(cah.mouse_select,'value',1);
[~,~,~,~,mouseIDs,~,projectIDs,~]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.mouse_select,'value',1,'string',mouseIDs);
proj=projectIDs{get(cah.project_select,'value')};
pdef=getProjDef(proj);
% set(cah.ftypes,'UserData',pdef.calliope_load_filetypes_def);
% set(cah.hf,'UserData',ud);
set(cah.exp_select,'value',1);
[~,~,ExpStrs,~]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.exp_select,'string',ExpStrs);
ftypes={'further specify selection'};
set(cah.ftypes,'string',ftypes{get(cah.exp_select,'value')})

function mouse_select_callback(e,h,cah,ExpLog,adata_dir)
set(cah.exp_select,'value',1);
[~,~,ExpStrs,~]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.exp_select,'string',ExpStrs);
set(cah.ftypes,'value',numel(cah.ftypes.String))
exp_select_callback(e,h,cah,ExpLog,adata_dir)

function exp_select_callback(e,h,cah,ExpLog,adata_dir)
set(cah.ftypes,'Value',1)
set(cah.ftypes,'string','loading...'); pause(0.01);
[~,~,~,~,~,~,~,comments,~,ftypes]=get_menu_data(ExpLog,cah,adata_dir);
projDefaults=get(cah.ftypes,'UserData');
curr_ftypes=ftypes{get(cah.exp_select,'value')};
[~,floc]=intersect(curr_ftypes,projDefaults);
set(cah.ftypes,'string',ftypes{get(cah.exp_select,'value')})
set(cah.ftypes,'value',floc)
set(cah.comments,'string',comments{get(cah.exp_select,'value')});
set(cah.Acode,'string',ExpLog.analysiscode{[ExpLog.stackid{:}]==calliope_getCurStack});

function load_callback(e,h,ExpLog,cah,adata_dir)
[~,ExpIDs,~,~]=get_menu_data(ExpLog,cah,adata_dir);
set(cah.title_string,'string',['loaded Exp ' num2str(ExpIDs(get(cah.exp_select,'value'))) ' - ' datestr(now,13)]);
disp(['Loading Exp --- ' num2str(ExpIDs(get(cah.exp_select,'value'))) ' --- ' datestr(now)])
disp('clearing data to prevent mismatch!');
evalin('base','clear data;');
ftypes=get(cah.ftypes,'string');
if sum(strcmp(ftypes,'610.bin') + strcmp(ftypes,'525.bin') + strcmp(ftypes,'.wid'))==0
    just_behave=1;
else
    just_behave=0;
end
load_exp(ExpIDs(get(cah.exp_select,'value')),adata_dir,ftypes(get(cah.ftypes,'value')),ExpLog,'base',just_behave);

function load_meta_callback(e,h,cah)
adata_dir=set_lab_paths;
[fname,fpath] = uigetfile([adata_dir '_metaData']);
set(cah.title_string,'string',['loaded meta ' fname ' - ' datestr(now,13)]);
disp(['------ Now loading meta file ' fname ' ------']);
evalin('base',['load(''' fpath fname ''');']);
disp('------ Done loading ------')

function select_rois_callback(e,h,ExpLog,cah,adata_dir)

template=evalin('base','template');

if isa(template,'cell')
    z_plane=input(['There are ' num2str(length(template)) ' z-planes' '. Select z-plane: ']);
    assignin('base','z_plane',z_plane);
else
    z_plane=0;
    assignin('base','z_plane',z_plane);
end

[~,ExpIDs,~,same_site_as_ID,~,ExpGroup]=get_menu_data(ExpLog,cah,adata_dir);
assignin('base','ExpGroup',ExpGroup);

[ofile_ID,omouse_ID,ouser_ID]=get_adata_filename(same_site_as_ID(get(cah.exp_select,'value')),adata_dir,ExpLog);

[file_ID,mouse_ID,user_ID]=get_adata_filename(ExpIDs(get(cah.exp_select,'value')),adata_dir,ExpLog);
curr=load([adata_dir user_ID '\' mouse_ID '\' file_ID],'template','ROIs','ROItrans','bv','np');

if z_plane==0
    if isempty(ofile_ID)
        disp('first exp of this site not registered yet - will improvise')
        evalin('base','find_cells_gui(template,ROIs,[0 0 0],act_map)');
    else
        orig=load([adata_dir ouser_ID '\' omouse_ID '\' ofile_ID],'template','ROIs','ROItrans','bv','np');
        try
            orig.ROIs=rmfield(orig.ROIs,'activity');
            orig.bv=rmfield(orig.bv,'activity');
            orig.np=rmfield(orig.np,'activity');
        end
        if ~isfield(orig,'ROItrans')
            orig.ROItrans=zeros(3,1);
        end
        assignin('base','orig_template',orig.template);
        load_curr=0;
        if length(curr.ROIs)>1
            disp('ROIs were already registered for this Exp')
            load_curr=input('Use saved ROIs (1) or choose new (0)? ');
            if load_curr
                if strcmp(ofile_ID,file_ID)
                    evalin('base','find_cells_gui(template,ROIs,ROItrans,act_map,orig_template)');
                else
                    disp('This file ID differs from the saved one')
                    load_curr_nf=input('Use ROIs saved in this file (1) or the orig file (0) ROIs? ');
                    if load_curr_nf
                        evalin('base','find_cells_gui(template,ROIs,ROItrans,act_map,orig_template)');
                    else
                        load_curr=0;
                    end
                end
            end
        end
        if ~load_curr
            disp('ROIs were not registered for this Exp - using main ROIs')
            assignin('base','bv',orig.bv);
            assignin('base','np',orig.np);
            assignin('base','ROIs',orig.ROIs);
            assignin('base','ROItrans',orig.ROItrans);
            evalin('base','find_cells_gui(template,ROIs,ROItrans,act_map,orig_template)');
        end
    end
else
    if isempty(ofile_ID)
        disp('first exp of this site not registered yet - will improvise')
        %         evalin('base','find_cells_gui(template{z_plane},ROIs{z_plane},[0 0 0],act_map{z_plane})');
    else
        orig=load([adata_dir ouser_ID '\' omouse_ID '\' ofile_ID],'template','ROIs','ROItrans','bv','np');
        try
            orig.ROIs{z_plane}=rmfield(orig.ROIs{z_plane},'activity');
            orig.bv{z_plane}=rmfield(orig.bv{z_plane},'activity');
            orig.np{z_plane}=rmfield(orig.np{z_plane},'activity');
        end
        if ~isfield(orig,'ROItrans')
            orig.ROItrans=cell(1,length(orig.ROIs));
            for rnd=1:length(orig.ROIs)
                orig.ROItrans{rnd}=zeros(3,1);
            end
        end
        assignin('base','orig_template',orig.template);
    end
    
    if length(curr.ROIs{z_plane})>1
        disp('ROIs were already selected for this Exp')
        load_curr=input('Use saved ROIs (1) or choose new (0)? ');
        if load_curr
            if strcmp(ofile_ID,file_ID)
                evalin('base','find_cells_gui(template{z_plane},ROIs{z_plane},ROItrans{z_plane},act_map{z_plane},orig_template{z_plane})');
            else
                load_curr_nf=input(['Use ROIs saved in this file (1) or the orig file (0) ROIs? ']);
                if load_curr_nf
                    if isempty(ofile_ID)
                        evalin('base','find_cells_gui(template{z_plane},ROIs{z_plane},ROItrans{z_plane},act_map{z_plane},template{z_plane})');
                    else
                        evalin('base','find_cells_gui(template{z_plane},ROIs{z_plane},ROItrans{z_plane},act_map{z_plane},orig_template{z_plane})');
                    end
                else
                    load_curr=0;
                end
            end
        else
            orig.ROIs{z_plane}=struct;
        end
    else
        load_curr=0;
    end
    if load_curr==0
        disp('ROIs were not registered for this Exp - using main ROIs')
        assignin('base','orig_bv',orig.bv{z_plane});
        evalin('base','bv{z_plane}=orig_bv;')
        assignin('base','orig_np',orig.np{z_plane});
        evalin('base','np{z_plane}=orig_np;')
        assignin('base','orig_ROIs',orig.ROIs{z_plane});
        evalin('base','ROIs{z_plane}=orig_ROIs;')
        assignin('base','orig_ROItrans',orig.ROItrans{z_plane});
        evalin('base','ROItrans{z_plane}=orig_ROItrans;')
        evalin('base','find_cells_gui(template{z_plane},ROIs{z_plane},ROItrans{z_plane},act_map{z_plane},orig_template{z_plane})');
    end
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function save_Adata_callback(e,h)
evalin('base','save_ROIs_df(adata_dir,ROIs,ROItrans,fnames,mouse_id,userID,ExpGroup,template,z_plane)')

function view_tiff_callback(e,h,ExpLog,cah,adata_dir)
if evalin('base','exist(''data'',''var'')')
    dx=evalin('base','dx');
    if isa(dx,'cell')
        view_z_plane=input(['There are ' num2str(length(dx)) ' z-planes' '. Select z-plane: ']);
        evalin('base',['view_stack(data{' num2str(view_z_plane) '})']);
    else
        evalin('base','view_stack(data)');
    end
elseif strcmpi(cell2mat(cah.ftypes.String(cah.ftypes.Value)'),'.lvd')
    disp('Running checkAux() on selected stackID...')
    evalin('base','checkAux();')
else
    disp('load *.bin to use data explorer');
end


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function check_reg_callback(e,h,ExpLog,cah,adata_dir)
% if loaded data mismatches displayed data, update loaded data
try
    fnames=evalin('base','fnames');
catch
    warning('no data loaded, loading it for you...');
    set(cah.ftypes,'Value',find(~cellfun('isempty',regexpi(get(cah.ftypes,'String'),'ini','once'))));
    load_callback(e,h,ExpLog,cah,adata_dir)
    fnames=evalin('base','fnames');
end
if all(cellfun('isempty',(regexp(fnames,['(?<=S1-T)' num2str(calliope_getCurStack) '(?=_ch525.bin)'],'match'))))
    warning('mismatch loaded/selected data: showing registration of selected ExpID');
    evalin('base',['check_registration(' num2str(calliope_getCurStack) ' )']);
else
    evalin('base','check_registration(dx,dy,template)');
end


function register_entire_dir_callback(e,h,ExpLog,cah,adata_dir)
answer = questdlg('Do you want to register all data? This takes roughly 10 min per exp', ...
    'Batch registration','All project experiments','Only this animal','Manually select','Manually select');

switch answer
    case 'All project experiments'
        ExpIDs = get_proj_ExpIDs(ExpLog,cah);
    case 'Only this animal'
        [~,ExpIDs,~,~] = get_menu_data(ExpLog,cah,adata_dir);
    case 'Manually select'
        ExpIDs=intersect(input('Which ExpIDs? (e.g. [10001:10004]): '), get_proj_ExpIDs(ExpLog,cah)');
end

answer = questdlg('Do you want to perform automatic ROI detection? It wil take FOREVER! (*pause* NOT)', ...
    'Automatic ROI Detection','Hell Yeah','No Way Jose','No Way Jose');

switch answer
    case 'Hell Yeah'
        auto_roi.flag=1;
        auto_roi.type=input('Is it cell [1] or axon [2] data? ([3] for custom parameters): ');
        
        if auto_roi.type==1
            auto_roi.area=[200 1000];
            auto_roi.thresh=3;
            auto_roi.ROIsmoothing=1;
        elseif auto_roi.type==2;
            auto_roi.area=[10 1000];
            auto_roi.thresh=2;
            auto_roi.ROIsmoothing=0;
        else
            disp('Interesting choice - well, we''ll need more information...');
            auto_roi.area=input('What range of ROI sizes do you want to find (cells [200 1000], axons [10 100]): ');
            auto_roi.thresh=input('What threshold do you want to use (cells 3, axons 2 - lower threshold more ROIs): ');
            auto_roi.ROIsmoothing=input('Do you want to smooth your rois (1 or 0 - don''t for axons): ');
        end
    case 'No Way Jose'
        auto_roi.flag=0;
end

reg_on_ch=1;
ExpInfo=read_info_from_ExpLog(ExpIDs(1),1);
if isfield(ExpInfo, 'sec_fnames')
    if ~isempty(ExpInfo.sec_fnames)
        reg_on_ch=input('This project contains 2 channels - which one do you want to register on? [1/2]: ');
    end
end

disp('##############################################');
disp('Batch registering of data in current directory');
disp('##############################################');
for ind=1:length(ExpIDs)
    try
        disp('************************');
        disp(['Now registering exp ' num2str(ExpIDs(ind))]);
        disp('************************');
        evalin('base','clear data');
        register_exp(ExpIDs(ind),adata_dir,cah,reg_on_ch,auto_roi)
        
    catch exception
        disp(exception.message)
        disp(['There was an ERROR with Exp ' num2str(ExpIDs(ind))])
    end
end

[adata_list]=list_all_adata_files(adata_dir,1);

function calcROIact(e,h,ExpLog,cah,adata_dir)

answer = questdlg('Do you want to calculate activity for all data?', ...
    'Batch registration','All project experiments','Only this animal','Manually select','Manually select');

switch answer
    case 'All project experiments'
        ExpIDs = get_proj_ExpIDs(ExpLog,cah);
    case 'Only this animal'
        [~,ExpIDs,~,~] = get_menu_data(ExpLog,cah,adata_dir);
    case 'Manually select'
        ExpIDs=intersect(input('Which ExpIDs? (e.g. [10001:10004]): '), get_proj_ExpIDs(ExpLog,cah)');
end

calc_on_ch=1;
evalin('base','load_noregister=0;') %to avoid accidental loading without registration
ExpInfo=read_info_from_ExpLog(ExpIDs(1),1);
if isfield(ExpInfo, 'sec_fnames')
    if ~isempty(ExpInfo.sec_fnames)
        calc_on_ch=input('This project contains 2 channels - which one do you want to register on? [1/2]: ');
    end
end

for ind=1:length(ExpIDs)
    
    disp('**********************************');
    disp(['Now calculating ROI act of exp ' num2str(ExpIDs(ind))]);
    disp('**********************************');
    evalin('base','clear data');
    calc_act(ExpIDs(ind),adata_dir,cah,calc_on_ch)
end

function preview_adata_callback(e,h,ExpLog,cah,adata_dir)
[~,ExpIDs,~,~]=get_menu_data(ExpLog,cah,adata_dir);
[file_ID,mouse_ID,user_ID]=find_adata_file(ExpIDs(get(cah.exp_select,'value')),adata_dir);
if isempty(file_ID)
    disp('No AData found');
else
    disp(['Previewing Adata of file ' file_ID])
    prev_adata=load([adata_dir user_ID '\' mouse_ID '\' file_ID]);
    assignin('base','prev_adata',prev_adata);
end

function [userIDs,ExpIDs,ExpStrs,same_site_as_ID,mouseIDs,ExpGroup,projectIDs,comments,...
    Acode,ftypes]=get_menu_data(ExpLog,cah,adata_dir)

global adata_list_num;

ud=get(cah.hf,'UserData');

userIDs=unique(ExpLog.pi, 'first');
user_ind=find(strcmp(ExpLog.pi,userIDs(get(cah.user_select,'value'))));

projectIDs=unique(ExpLog.project(user_ind),'first');
project_ind=find(strcmp(ExpLog.project,projectIDs(get(cah.project_select,'value'))));
project_ind=intersect(user_ind,project_ind);

mouseIDs = unique(ExpLog.animalid(project_ind),'first');
mouse_ind=find(strcmp(ExpLog.animalid,mouseIDs(get(cah.mouse_select,'value'))));
mouse_ind=intersect(user_ind,mouse_ind);

[ExpIDs,ExpIDs_ind]=unique(cell2mat(ExpLog.expid(mouse_ind)),'first');

same_site_as_ID = ExpLog.siteid(mouse_ind);
same_site_as_ID = cell2mat(same_site_as_ID(ExpIDs_ind));

ExpStrs=[num2str(ExpIDs), char(ones(length(ExpIDs),1)*[32,45,32]), num2str(same_site_as_ID)];
ExpStrs=mat2cell(ExpStrs,ones(length(ExpIDs),1));

% replace NaNs in no-comment fields
mouse_IDs=ExpLog.comment(mouse_ind);
mouse_IDs(logical(cellfun(@sum,cellfun(@isnan,mouse_IDs,'uniformoutput',0))))={''};
% remove line breaks from comments field
mouse_IDs=regexprep(mouse_IDs,'\n',' ');

curr_exp_sel_ind=get(cah.exp_select,'value');
if curr_exp_sel_ind>length(same_site_as_ID)
    curr_exp_sel_ind=1;
end
ExpLog.siteid = cell2mat(ExpLog.siteid);
ExpLog.expid = cell2mat(ExpLog.expid);

ExpGroup = [same_site_as_ID(curr_exp_sel_ind); ExpLog.expid(ExpLog.siteid == same_site_as_ID(curr_exp_sel_ind))];
Acode = ExpLog.analysiscode(ExpLog.siteid == same_site_as_ID(curr_exp_sel_ind));
Acode = cell2mat(Acode(1));
if ~isa(Acode,'char')
    Acode = num2str(Acode);
end

[~,b,~]=unique(ExpGroup,'first');
ExpGroup=ExpGroup(sort(b));

for ind=1:length(ExpIDs)
    if sum(adata_list_num()==ExpIDs(ind))
        ExpStrs{ind}=['A. ' ExpStrs{ind} ' - ' mouse_IDs{ExpIDs_ind(ind)}];
    else
        ExpStrs{ind}=[ExpStrs{ind} ' - ' mouse_IDs{ExpIDs_ind(ind)}];
    end
end

[~,~,comment_ID]=unique(ExpLog.expid(mouse_ind));
for ind=1:length(ExpIDs)
    comments{ind}=mouse_IDs(comment_ID==ind);
end

% only perform this if ftypes is requested as output
if nargout>9
    try
        data_dir=get_data_path(ExpIDs(get(cah.exp_select,'value')),[],ExpLog);
        curr_files=dir([data_dir userIDs{get(cah.user_select,'value')} '\' mouseIDs{get(cah.mouse_select,'value')} '\']);
        tmp3 = regexp(sprintf('%i ',ExpIDs),'(\d+)','match'); % faster than num2str individually in the 2nd for loop
        curr_files={curr_files.name}.';
        for ind=1:length(ExpIDs)
            jnd = cellfun(@(x)(~isempty(x)),regexp(curr_files,tmp3(ind)))';
            ftypes{ind}=cellfun(@(x)(x(findstr(x,tmp3{ind})+length(tmp3{ind}):end)),curr_files(jnd), 'UniformOutput', false);
            ftypes{ind}=cellfun(@(x)(x(end-min(6,length(x)-1):end)),ftypes{ind},'UniformOutput',false);
        end
    end
    if ~exist('ftypes','var')
        for ind=1:length(ExpIDs)
            ftypes{ind}='no data';
        end
    end
end



function [ExpIDs]=get_proj_ExpIDs(ExpLog,cah)

[userIDs]=get(cah.user_select,'string');
user_ind=find(strcmp(ExpLog.pi,userIDs(get(cah.user_select,'value'))));

[projectIDs]=get(cah.project_select,'string');
project_ind=find(strcmp(ExpLog.project,projectIDs(get(cah.project_select,'value'))));

project_ind=intersect(user_ind,project_ind);

ExpIDs=unique(cell2mat(ExpLog.expid(project_ind)),'first');




