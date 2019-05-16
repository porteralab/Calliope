function set_adata_code(siteID)
% GUI used to set Adata code field in the ExpLog database
% GK - 01.01.14
% modified PZ 2015-12-14 remove line breaks from comments field
% modified FW 2018-03-14 added calliope integration
% modified FW 2018-04-19 argument to navigate to site
% modified MH 2019-05-15 displays animalid in the drop down

ExpLog=getExpLog;

sach.mf=figure(1394);
set(sach.mf,'userdata',ExpLog,'color','k','menubar','none','Tag','set_adata_code');

uicontrol('style','text',...
    'string','Project:',...
    'units','normalized',...
    'position',[0.1 0.84 0.1 0.05],...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','g');

uicontrol('style','text',...
    'string','SiteID:',...
    'units','normalized',...
    'position',[0.1 0.74 0.1 0.05],...
    'BackgroundColor',[1 1 1]*0,...
    'ForegroundColor','g');

sach.project_select=uicontrol('style','popupmenu',...
    'string',unique(ExpLog.project),...
    'value',1,...
    'units','normalized',...
    'position',[0.2 0.8 0.25 0.1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');

sach.site_select=uicontrol('style','popupmenu',...
    'string','Select Project',...
    'value',1,...
    'units','normalized',...
    'position',[0.2 0.7 0.25 0.1],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g');


sach.exp_list = uicontrol('Style','listbox',...
    'Units','normalized',...
    'Position',[0.1 0.1 0.8 0.6],...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'Min',0,'Max',10,...
    'String','Select Site');

sach.acode=uicontrol('Style','edit',...
    'Units','normalized',...
    'fontsize',20,...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'Position',[0.525 0.775 0.1 0.1],...
    'String','1');


sach.update=uicontrol('Style','pushbutton',...
    'Units','normalized',...
    'fontsize',20,...
    'BackgroundColor',[1 1 1]*0.1,...
    'ForegroundColor','g',...
    'Position',[0.65 0.775 0.2 0.1],...
    'String','update');




set(sach.project_select,'callback',{@proj_select_callback,sach})
set(sach.site_select,'callback',{@site_select_callback,sach})
set(sach.update,'callback',{@update_callback,sach})

if ishandle(1001) && nargin==0 %if calliope open, directly navigate to that project/site
    warning('navigating to project/site currently open in calliope');
    try
        adata_window=figure(1394);
        calliope_proj=handle(1001).Children(17).String{handle(1001).Children(17).Value};
        calliope_site=regexp(handle(1001).Children(15).String{handle(1001).Children(15).Value},'(?<= - )[0-9]*','match','once');
        adata_window.Children(5).Value=find(~cellfun('isempty',regexp(adata_window.Children(5).String,calliope_proj)));
        proj_select_callback([],[],sach)
        adata_window.Children(4).Value=find(~cellfun('isempty',regexp(adata_window.Children(4).String,calliope_site)));
        site_select_callback([],[],sach)
    catch
        %revert to default if failed
    end
end

if nargin==1 && isnumeric(siteID) %directly navigate set_adata_code to given site
        adata_window=figure(1394);
        siteID=ExpLog.siteid{find([ExpLog.stackid{:}]==siteID)};
        calliope_proj=ExpLog.project{find([ExpLog.stackid{:}]==siteID)};
        calliope_site=siteID;
        adata_window.Children(5).Value=find(~cellfun('isempty',regexp(adata_window.Children(5).String,calliope_proj)));
        proj_select_callback([],[],sach)
        adata_window.Children(4).Value=find(~cellfun('isempty',regexp(adata_window.Children(4).String,num2str(calliope_site))));
        site_select_callback([],[],sach)
end

end


function proj_select_callback(hf,e,sach)

ExpLog=get(sach.mf,'userdata');

projIDs=get(sach.project_select,'String');
projID=projIDs{get(sach.project_select,'value')};

siteIDs=unique(cell2mat(ExpLog.siteid(strcmp(ExpLog.project,projID))));

for ind=1:length(siteIDs)
    mouse = cell2mat(ExpLog.animalid(find(cell2mat(ExpLog.siteid) == siteIDs(ind),1,'first')));
    tmp{ind}=[num2str(siteIDs(ind)) '     ' mouse([1:3 end-2:end])];
end
siteIDs=tmp';
set(sach.site_select,'String',siteIDs,'Value',1);
end

function site_select_callback(hf,e,sach)

ExpLog=get(sach.mf,'userdata');
projIDs=get(sach.project_select,'String');
projID=projIDs{get(sach.project_select,'value')};
siteIDs=unique(cell2mat(ExpLog.siteid(strcmp(ExpLog.project,projID))));
siteID=siteIDs(get(sach.site_select,'Value'));


curr_inds=find(cell2mat(ExpLog.siteid)==siteID);
[~,tmp_ind]=unique(cell2mat(ExpLog.expid(cell2mat(ExpLog.siteid)==siteID)),'first');
curr_inds=curr_inds(tmp_ind);

expIDs=ExpLog.expid(curr_inds);
acodes=ExpLog.analysiscode(curr_inds);

% remove line breaks from comments field
comments=regexprep(ExpLog.comment(curr_inds),'\n',' ');

for ind=1:length(expIDs)
    if isnan(acodes{ind})
        acode_str='-';
    else
        acode_str=acodes{ind};
    end
    tmp{ind}=[acode_str ' -- ' num2str(expIDs{ind}) ' -- ' comments{ind} ];
end
expIDs=tmp';

set(sach.exp_list,'String',expIDs,'Value',1);
end

function update_callback(hf,e,sach)

ExpLog=get(sach.mf,'userdata');

projIDs=get(sach.project_select,'String');
projID=projIDs{get(sach.project_select,'value')};
siteIDs=unique(cell2mat(ExpLog.siteid(strcmp(ExpLog.project,projID))));
siteID=siteIDs(get(sach.site_select,'Value'));

curr_inds=find(cell2mat(ExpLog.siteid)==siteID);
[~,tmp_ind]=unique(cell2mat(ExpLog.expid(cell2mat(ExpLog.siteid)==siteID)),'first');
curr_inds=curr_inds(tmp_ind);

expIDs=ExpLog.expid(curr_inds);

for ind=1:length(expIDs)
    tmp{ind}=num2str(expIDs{ind});
end
expIDs=tmp';

update_expIDs=expIDs(get(sach.exp_list,'value'));

acode=get(sach.acode,'string');

ButtonName = questdlg('Are you sure you want to proceed, this will lead to actual changes in the Database?');

if strcmp(ButtonName,'Yes')
   
    DB=connectToExpLog;
    
    for ind=1:length(update_expIDs)
        sql=['UPDATE Experiments SET Experiments.AnalysisCode = ''' acode ''' WHERE Experiments.ExpID = ' num2str(update_expIDs{ind})];
        ExpLog = adodb_query(DB, sql);
    end
    
    sql = ['SELECT Stacks.stackid, Stacks.expid, Stacks.comment, Experiments.siteid, Experiments.analysiscode,',...
        'Sites.animalid, Sites.project, Animals.pi FROM Stacks INNER JOIN Experiments ON Stacks.expid=Experiments.expid ' ...
        'INNER JOIN Sites ON Experiments.siteid=Sites.siteid INNER JOIN Animals ON Sites.AnimalID=Animals.AnimalID ORDER BY Stacks.stackid'];
    ExpLog = adodb_query(DB, sql);
    DB.release;
    
    set(sach.mf,'userdata',ExpLog);
    
    site_select_callback(hf,e,sach)
    
else
    disp('Aborted - nothing was changed');
end



end











