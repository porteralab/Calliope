function ExpLogProjects=getExpLogProjects()
%Functions extracts all Projects from ExpLog database.


DB=connectToExpLog;
sql = ['SELECT Projects.ProjectID, Projects.name, Projects.PIs, Projects.Description, Projects.StartDate, Projects.Status FROM Projects'];
ExpLogProjects = adodb_query(DB, sql);
DB.release;
