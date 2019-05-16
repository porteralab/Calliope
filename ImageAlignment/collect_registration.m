function result=collect_registration(varargin)
% collects all registration commands from registration_log in adata files
% using jazzy regular expressions. Only finds logs after Dec-2018 as the
% registration log was implemented then.
%
% examples, see 'help qexp' for more input parameters:
% collect_registration('pi','profsmit','last',50); %gets profsmith's last 50 registration changes
% collect_registration('pi','profsmit','acode','26'); %gets profsmit's regisration changes with acode '26'
%
% 2018 FW

ExpLog=getExpLog;
ExpLogSnp=qexp(varargin{:},'ExpLog',ExpLog,'bornafter','01.12.2018');
[ExpIDs]=unique([ExpLogSnp.expid]);
ExpLogSnp=qexp(ExpIDs,'ExpLog',ExpLog);
result={};
warning('off','MATLAB:load:variableNotFound');
if isempty(ExpLogSnp.stackid), disp('no expids found, possibly none after Dec-2018'); return; end;
for ind=1:numel(ExpIDs)
    ExpID=ExpIDs(ind);
    filename=dir([set_lab_paths ExpLogSnp.pi{ind} '\' ExpLogSnp.animalid{ind} '\*' num2str(ExpID) '*.mat']);
    if isempty(filename), continue; end
    path=[set_lab_paths ExpLogSnp.pi{ind} '\' ExpLogSnp.animalid{ind} '\' filename.name];
    clear registration_log
    load(path,'registration_log');
    if exist('registration_log','var')
        [~,tok]=regexpi(registration_log,'.* nbr: (?:\d+)* : (\w+)* - (?:(fta: ))*(\w+)*(?:\w+: |, )*(\d+:\d+|\d+)*(?:, )*(\d+:\d+|\d+)*','once','match','tokens','warnings');
        for tnd=1:size(tok,2)
            just_words=~cellfun('isempty',regexpi(tok{tnd}(:)','[A-Z_-]+','match','once'));
            just_words(1)=0;
            tok{tnd}(find(just_words))=cellfun(@(x) ['''' x ''''],tok{tnd}(find(just_words)),'uni',0);
            tok{tnd}(cellfun('isempty',tok{tnd}))=[];
            result=vertcat(result,[tok{tnd}{1} '(' num2str(ExpID) ',' strjoin(tok{tnd}(2:end)',',') ')']);%[tok{tnd}{1} '(' num2str(ExpID) ',1,''' tok{tnd}{2} ''', [' tok{tnd}{3} '])']);
        end
    end
end
warning('on','MATLAB:load:variableNotFound');
if nargout==0 && isempty(result), disp('no registration logs found, possibly because registered before Dec-2018'); return; end
end