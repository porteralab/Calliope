function [ExpLogMatched,idx]=qexp(varargin)
% query explog with 'just the snAAAAP of your fingers'
% even number of arguments will output matching snippet of ExpLog including all fields.
% otherwise: last input argument will be 'direct' output of ExpLog snippet
%
% usage:
% ExpLogMatched=qexp('pi','profsmit','age',5); %profsmit's stacks, <=5 days old
% qexp('last',5,'pi');                  %returns pi's last 5 stacks in DB
% qexp(12345,'expid');                  %returns expid assiociated with 12345
% qexp('pi','profsmit','age',5,'expid');%returns profsmit's expids younger than 5 days
% qexp('age','31.12.2000','expid');     %returns expids after date 31.12.2000
% qexp('pi','profsmit','ExpLog',explog);%pass on ExpLog to function, get profsmit's stacks
%
% requestable outputs not stored in ExpLog:
% qexp('pi','profsmit','age');          %returns age of stacks of pi in days
% qexp('last',5,'act');                 %outputs if activity has been calculated
% qexp('last',5,'addact');              %adds if activity has been calculated to output snippet
% qexp('last',5,'fnames');              %attempts to generate fnames of files
%
% 2018 FW

%shorthand argument transformations
varargin(cellfun(@isstr,varargin))=regexprep(varargin(cellfun(@isstr,varargin)),{'acode$','proj$','animal$|mouse$','loc$','stackids','expids','siteids'},{'analysiscode','project','animalid','location','stackid','expid','siteid'});

if isnumeric(varargin{1}), varargin=['stackid' varargin]; end %no identifier => it's a stack

if mod(numel(varargin),2)~=0  %if odd number of arguments, take last one as output
    output=lower(varargin{end});
    varargin(end)=[];
end

condis=lower(varargin(1:2:end)); %get filter conditions
vals=varargin(2:2:end);          %...and their values

%get ExpLog unless provided
ExpLogIdx=~cellfun('isempty',regexpi(condis,'explog'));
if any(ExpLogIdx)
    ExpLog=vals{ExpLogIdx}; condis(ExpLogIdx)=[]; vals(ExpLogIdx)=[];
else
    ExpLog=getExpLog;
end

%transform analysiscode to string
acodeIDX=~cellfun('isempty',regexpi(condis,'analysiscode'));
if any(acodeIDX), vals{acodeIDX}=strsplit(num2str(vals{acodeIDX})); end

%build condition matrix
idx=false(size(ExpLog.stackid,1),size(condis,2));
for ind=1:size(condis,2)
    f=condis{ind};
    v=vals{ind};
    if isfield(ExpLog,f)
        if isnumeric(v)
            idx(ismember([ExpLog.(f){:}],v),ind)=1;
        elseif strcmp(f,'animalid')
            idx(~cellfun('isempty',regexpi(ExpLog.(f),v)),ind)=1;
        elseif isa(v,'cell') %allow for multiple string comparisons
            tmpidx=cellfun(@(x) strcmp(ExpLog.(f),x),v,'uni',0);
            tmpidx=any([tmpidx{:}],2);
            idx(tmpidx,ind)=1;
        else
            idx(strcmp(ExpLog.(f),v),ind)=1;
        end
    elseif any(strcmp(f,{'age','dateafter','olderthan','bornafter','after'}))
        [~,ix]=find_stacks_age(v,ExpLog);
        idx(ix,ind)=1;
    elseif any(strcmp(f,{'datebefore','bornbefore','before'}))
        today=datetime(cellstr(datetime('now','Format','dd-MMM-yyyy')));
        if isnumeric(v)
            ix=dates<=today-caldays(v);
        elseif isa(v,'char') ||  isa(v,'datetime')
            ix=datetime(ExpLog.stackdate,'Format','dd-MMM-yyyy')<=datetime(v,'Format','dd-MMM-yyyy');
        else
            error('could not identify date variable');
        end
        idx(ix,ind)=1;
    elseif any(strcmp(f,{'first','last'}))
        idx(:,ind)=1;%do stuff later
    elseif any(strcmp(f,{'cregex','regex','regexp'}))
        idx(:,ind)=1;%do stuff later
    else
        try
            idx(~cellfun('isempty',strfind(cellfun(@num2str,ExpLog.(f),'uni',0),num2str(v))),ind)=1;
        catch
            idx(:,ind)=1;
            fprintf('Couldn''t interpret this argument: %s\n',f)
        end
    end
end
idx=all(idx,2); %change all() to any() to go from 'and' -> 'or'

%if specified, apply regex to comments after selection of stacks
if any(~cellfun('isempty',regexpi(condis,'regex|regular','once','match')))
    idx(cellfun('isempty',...
        regexpi(ExpLog.comment,vals{~cellfun('isempty',...
        regexpi(condis,'regex|regular'))})))=0;
end

%only output first/last X elements
if any(strcmp(condis,'last')) && sum(idx)>vals{strcmp(condis,'last')}, idx(1:(min(find(idx, vals{strcmp(condis,'last')}, 'last'))-1)) = false; end
if any(strcmp(condis,'first')) && sum(idx)>vals{strcmp(condis,'first')}, idx((max(find(idx, vals{strcmp(condis,'first')}, 'first'))+1):end) = false; end

%output ExpLog or ExpLog field
if ~exist('output','var') || (exist('output','var') && any(strcmp(output,{'act','activity','addact','inclact'}))) %output not specified
    for f=fieldnames(ExpLog)'
        if any(strcmp(f{:},{'stackid','expid','siteid'})) %output as vector
            ExpLogMatched.(f{:})=[ExpLog.(f{:}){idx}];
        else %output as cell array
            ExpLogMatched.(f{:})=ExpLog.(f{:})(idx);
        end
    end
else %output specific fields
    if any(strcmp(output,{'stackid','expid','siteid'})) %output as matrix
        ExpLogMatched = unique([ExpLog.(output){idx}]);
    elseif any(strcmp(output,{'fname','fnames'})) %experimental quick-output of fname
        pdef=getProjDef(ExpLog.project{min(find(idx==1))});
        bak=pdef.backup_destination{1};
        ExpLogMatched = cellfun(@(x) [bak filesep ExpLog.pi{x} filesep ExpLog.animalid{x} filesep 'S1-T' num2str(ExpLog.stackid{x}) '_ch525.bin'],num2cell(find(idx)),'uni',0);
    elseif any(strcmp(output,{'age'}))
        ExpLogMatched=get_ages(ExpLog,idx);
    elseif isfield(ExpLog,output) %output as cell array
        
        ExpLogMatched = ExpLog.(output)(idx);
        if ~strcmp(output,'comment') && all(cellfun(@isstr,ExpLogMatched)) %unique: Cell array input must be a cell array of character vectors.
            ExpLogMatched=unique(ExpLogMatched);
        end
    else
        fprintf('Couldn''t interpret this output-argument: %s\n',output)
    end
end
% if has_act is requested...
if exist('output','var') && any(strcmp(output,{'act','activity','addact','inclact'}))
    ExpLogMatched=has_act(ExpLogMatched,output);
end
end

function [stack_id,idx,varargout]=find_stacks_age(lookback,ExpLog,varargin)
% returns stacks with certain age or younger. It's ok to look old.
% usage: find_stacks_age(5); %returns stacks that are younger or 5 days old

if ~exist('ExpLog','var'),ExpLog=getExpLog; end

dates=datetime(ExpLog.stackdate);
today=datetime(cellstr(datetime('now','Format','dd-MMM-yyyy')));
if isnumeric(lookback)
    idx=dates>=today-caldays(lookback);
elseif isa(lookback,'char') || isa(lookback,'datetime')
    idx=dates>=datetime(lookback);
else
    error('could not identify date variable');
end
stack_id=[ExpLog.stackid{idx}];

if exist('varargin','var')
    varargout={};
    for f=varargin
        f=f{:};
        varargout{end+1}={ExpLog.(f){idx}};
        if isnumeric(varargout{:}{end})
            varargout{end}=cell2mat(varargout{end});
        end
    end
end
end



function ages=get_ages(ExpLog,idx)
% returns age of a stack in days
if ~exist('ExpLog','var'),ExpLog=getExpLog; end
date=datetime(ExpLog.stackdate(idx));
today=datetime(cellstr(datetime('now','Format','dd-MMM-yyyy')));
ages=days(today-date);
end

function ExpLogMatched=has_act(ExpLogMatched,output)
afiles=cellfun(@(pi,animalid,stackid)  [set_lab_paths filesep pi filesep animalid filesep 'Adata-S1-T' num2str(stackid) '.mat'],ExpLogMatched.pi,ExpLogMatched.animalid,num2cell(ExpLogMatched.expid)','uni',0);
afiles_exist=cellfun(@(x) exist(x,'file')>0,afiles);
if any(strcmp(output,{'act','activity'}))
    afiles_exist=afiles_exist(afiles_exist);
    ExpLogMatched=zeros([1 size(afiles,1)]);
    ExpLogMatched(afiles_exist)=cellfun(@(x) ~isempty(who('-file',x,'act_map')),afiles(afiles_exist));
else
    ExpLogMatched.hasact=zeros([1 size(afiles,1)]);
    ExpLogMatched.hasact(afiles_exist)=cellfun(@(x) ~isempty(who('-file',x,'act_map')),afiles(afiles_exist));
end
end

%EOF