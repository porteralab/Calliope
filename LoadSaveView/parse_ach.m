function [pdef]=parse_ach(pdef,proj,acode)
% loads channels and labels directly from first .ach file in ExpLog
% intended to work in conjunction with ProjectDefaults file to replace
% channel list from .ach file
%
% usage:
% pdef=parse_ach([], 'XXX',[]); %pdef from first match in project
% pdef=parse_ach([], 'XXX',11); %pdef from first match in project & acode
% pdef=parse_ach([], 12345);    %gets channels for given stackID
% pdef=parse_ach('\\keller-rig1-aux\tempData\S1-T12345.ach') %asdf
%
% 09.04.2018 FW

ExpLog=getExpLog;

if nargin==1 && isa(pdef,'char') % filename is given
    [fname,pdef]=deal(pdef,[]);
    try ExpID=str2double(regexpi(fname,'(?<=S1-T)\d+(?=\.ach)','match','once')); catch, ExpID=-1; end
elseif nargin==1 && isnumeric(pdef) && numel(pdef)==1
    [data_path,ExpIDinfo]=get_data_path(pdef)
    [fname,ExpID,pdef]=deal([data_path ExpIDinfo.userID '\' ExpIDinfo.mouse_id '\S1-T' num2str(pdef) '.ach' ],pdef,[]);
    disp('');
else % get filename from ExpID
    if exist('proj','var') && isnumeric(proj) && ~isempty(proj)
        ExpID=proj;
    else
        if exist('proj','var') && ~isempty(proj)
            proj_match=~cellfun('isempty',regexpi(cellfun(@(x) num2str(x), ExpLog.project,'uni',0),proj));
        else
            proj_match=1;
        end
        if exist('acode','var') && ~isempty(acode)
            acode_match=~cellfun('isempty',regexpi(cellfun(@(x) num2str(x), ExpLog.analysiscode,'uni',0),num2str(acode)));
        else
            acode_match=1;
        end
        
        %get first matching .ach file for project and acode
        matched=find(acode_match&proj_match);
        ExpID=ExpLog.expid{matched(1)};
    end
    
    % find file path
    [data_path,ExpIDinfo]=get_data_path(ExpID,[],ExpLog);
    fname=[data_path ExpIDinfo.userID '\' ExpIDinfo.mouse_id  '\' 'S1-T' num2str(ExpID) '.ach'];   
end

% read .ach file
fprintf('loading channels from ExpID [%d]\n',ExpID);
fi=fopen(fname,'r');
txt=fscanf(fi,'%c');
fclose(fi);
txt=strsplit(txt,'\n');

% 'brute-force parse' every line of the .act file
for ind=2:numel(txt) % skip header-line
    try
        evalstr=regexprep(['pdef.' strtrim([ txt{ind}]) ';'],'\"','''');
        if regexpi(evalstr,'Running')
            evalstr=regexprep(evalstr,'Running','velM'); 
        end
        if regexpi(evalstr,'VisualFlow')
            evalstr=regexprep(evalstr,'VisualFlow','velP'); 
        end
        if regexpi(evalstr,'Perturbation')
            evalstr=regexprep(evalstr,'Perturbation','PS'); 
        end
        eval(evalstr);
    catch
        fprintf('coulnt''t eval: %s',txt{ind});
    end
end

% attempt to convert parsed .ach file to projectDefaults format
pdef.aux_chans={};
for f=fieldnames(pdef.auxrec)'
    channelnr=str2double(regexpi((f{1}),'\d*','match'))+1;
    if isnumeric(channelnr) && ~isempty(channelnr)
    pdef.aux_chans{end+1,1}=channelnr; %ach file starts with 'channel0'
    pdef.aux_chans{end  ,2}=pdef.auxrec.(f{:}); %channel label
    end
end

end
