function check_siteROIs_acode(pi,Acode,showfigs)
% checks all sites associated with pi and acode.
% wrapper-function for check_siteROIs (see help check_siteROIs)
% 
% usage:
% check_siteROIs_acode('maximust',[1 13]);
% check_siteROIs_acode('maximust');


%% add missing parameters

if ~exist('showfigs','var'), showfigs=0; end;
if ~exist('pi','var'), pi=1; end;
if ~exist('Acode','var'), Acode=1:999; end;
if isa(Acode,'char'), Acode=str2double(Acode); end

% calliope integration
if ishandle(1001) && (~exist('pi','var') || ~exist('Acode','var') || isempty(pi) || isempty(Acode))
    if ~exist('pi','var') && ishandle(1001)
        pi=handle(1001).Children(18).String{handle(1001).Children(18).Value};
        warning('added PI ''%s'' from calliope window',pi);
    end
    if ~exist('Acode','var') && ishandle(1001)
        Acode=str2double(handle(1001).Children(1).String);
        warning('added Acode ''%s'' from calliope window',Acode);
    end
end


%% get siteIDs

ExpLog=getExpLog;
Acodes=ismember(str2double([ExpLog.analysiscode]),Acode);
pis=(strcmp([ExpLog.pi],pi));
selected_sites = (Acodes & pis);
siteIDs= unique([ExpLog.siteid{find(selected_sites)}]);

if numel(siteIDs)==0, error('Couldn''t find any associated sites.'); return; end

%%

disp('--------------------------------------------------------------------')
fprintf('            -------- checking %3d siteIDs --------            \n',numel(siteIDs))
disp('--------------------------------------------------------------------')
disp(char(10));

for siteID=siteIDs
    try
        check_siteROIs(siteID,[],showfigs);
    catch me
        warning('ERROR IN SITEID %d (comment of first stack: %s):\n %s (%s)',siteID,ExpLog.comment{find([ExpLog.stackid{:}]==siteID)} ,me.message,me.identifier)
    end
end

end