function ExpLog=getExpLog()
%Functions extracts all entries in the ExpLog database.
%
%Output of this function is a cell array with:
%       stackid
%       expid
%       comment
%       siteid
%       analysiscode
%       animalid
%       project
%       location
%       pi
%
%
%documented by DM - 08.05.2014

if ~evalin('base','exist(''ExpLog'',''var'')')    
    DB=connectToExpLog;
    sql = ['SELECT Stacks.stackid, Stacks.expid, Stacks.comment, Stacks.stackdate, Experiments.siteid, Experiments.analysiscode, '...
        'Sites.animalid, Sites.project, Sites.location, Animals.pi, Animals.strain FROM Stacks INNER JOIN Experiments ON Stacks.expid=Experiments.expid '...
        'INNER JOIN Sites ON Experiments.siteid=Sites.siteid INNER JOIN Animals ON Sites.AnimalID=Animals.AnimalID ORDER BY Stacks.stackid'];
    ExpLog = adodb_query(DB, sql);
    
    %replace non-strings (Nans) in comment field with empty string
    ExpLog.comment(find(cell2mat(cellfun(@isstr,ExpLog.comment,'uniformoutput',0))==0))={''};
    
    DB.release;
else
    disp('NC Warning - getting ExpLog from ''base'' workspace!')
    ExpLog=evalin('base','ExpLog');
end