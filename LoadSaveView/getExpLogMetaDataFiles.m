function ExpLogMetaDataFiles=getExpLogMetaDataFiles()
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

DB=connectToExpLog;
sql = ['SELECT MetaDataFiles.MetaDataName, MetaDataFiles.ProjectID, MetaDataFiles.Description FROM MetaDataFiles'];
ExpLogMetaDataFiles = adodb_query(DB, sql);
DB.release;
