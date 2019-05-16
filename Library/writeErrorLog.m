function writeErrorLog(ExpID,message)
% use this function to write all Critical Errors to the Error Log file

ExpLog=getExpLog;

fprintf(2,[message '\n']); % message on screen in red

adata_dir=set_lab_paths;

fn=[adata_dir '_ErrorLog\ErrorLog.txt'];
PI=ExpLog.pi{find(cell2mat(ExpLog.expid)==ExpID,1,'first')};

caller=dbstack;

cf=caller(2).file;
cl=num2str(caller(2).line);

fid=fopen(fn,'a');
fprintf(fid,'\r\n %s',[num2str(ExpID) ' - ' PI ' - ' datestr(now) ' called in ' cf ' line: ' cl ' - ' message ]);
fclose(fid);