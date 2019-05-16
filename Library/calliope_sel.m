function calliope_sel(StackID,ExpLog,adataload)
% selects given ExpID in calliope GUI. Optionally loads adata of ExpID.
%
% usage:
% calliope_sel(); %opens lastest stack in database
% calliope_sel(1234);
% calliope_sel(1234,[],1);
% calliope_sel('username'); %opens the latest expID for specific user
% calliope_sel('proj');     %opens the latest expID for specified project
%
% FW 2018

find_val_in_calliope=@(cal_element,str_element) find(~cellfun('isempty',regexpi(cal_element.String,str_element)));

if nargin==0, StackID=qexp('last',1,'expid'); end
if ~ishandle(1001), calliope; end
if ~exist('ExpLog','var') || isempty(ExpLog), ExpLog=getExpLog; end
if ~exist('adataload','var') || isempty(adataload), adataload=0; end
if ~isnan(str2double(StackID)),str2double(StackID); end
if isa(StackID,'char') %try-interpret project/pi
    if size(StackID,2)<5, StackID=qexp('project',StackID,'last',1,'stackid');
    else, StackID=qexp('pi',StackID,'last',1,'stackid');
    end
end

figure(1001); %bring calliope to front

cal=handle(1001);
%find idx in ExpLog, correct StackIDs to ExpIDs
idx=find([ExpLog.stackid{:}]==StackID);
if isempty(idx), fprintf('StackID not found.\n'); return; end
idx=find([ExpLog.expid{:}]==ExpLog.expid{idx});
idx=idx(1);
%select user
element=cal.Children(18);
tmp=ExpLog.pi{idx};
tmp=find_val_in_calliope(element,tmp);
element.Value=tmp(1);
update(cal,element)

%select project
element=cal.Children(17);
tmp=ExpLog.project{idx};
tmp=find_val_in_calliope(element,tmp);
element.Value=tmp(1);
update(cal,element)

%select animal
element=cal.Children(16);
tmp=ExpLog.animalid{idx};
tmp=find_val_in_calliope(element,tmp);
element.Value=tmp(1);
update(cal,element)

%select stack
element=cal.Children(15);
tmp=num2str(ExpLog.stackid{idx});
tmp=find_val_in_calliope(element,[tmp '(?= - \d* - )']);
if isempty(tmp), tmp=find_val_in_calliope(element,tmp); end
element.Value=tmp(1);
update(cal,element)

if adataload
    load_adata(ExpLog.expid{idx},'base',ExpLog);
end
end

function update(cal,element)
mycall=get(element,'Callback');
mycall{1}(cal,[],mycall{2:end})
end