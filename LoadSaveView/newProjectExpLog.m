function newProjectExpLog
% adds a new Project to the ExpLog database
%documented by GK - 21.05.2016

disp('*******************************************************')
disp('This function will add a Project to the ExpLog database.')
disp('Note that you can cancel at any point by pressing Ctr-C,')
disp('or responding with "no" to the final confirmation.')
disp('Keep to standard formats with all data entered.');
disp('*******************************************************')

disp(' ')
disp(' ')

disp('*******************************************************')
disp('******           Existing Projects            *********')
disp('*******************************************************')

ExpLogProjects=getExpLogProjects;

for ind=1:length(ExpLogProjects.projectid)
    disp([ExpLogProjects.projectid{ind} ' - ' num2str(ExpLogProjects.description{ind})])
end

disp(' ');
disp('*******************************************************')
disp('******           define new project           *********')
disp('*******************************************************')
disp(' ');

go_on=1;
while go_on
    disp('What is the three letter acronym of your project (e.g. VML or LFM):');
    ProjectID=input(' - ','s');
    if sum(strcmp(ProjectID,ExpLogProjects.projectid))>0
        disp('nice try... project already exists - pay attention and use "creativity"');
        disp(' ');
    else
        go_on=0;
    end
end

go_on=1;
while go_on
    disp('What does the acronym stand for:');
    Name=input(' - ','s');
    if length(Name)<5
        disp('nice try... verbose name version is too short.');
        disp(' ');
    else
        go_on=0;
    end
end

go_on=1;
while go_on
    disp('Who is leading the project (username, separate with comma and space if more than one, e.g. "zmarpawe, attialex"):');
    PIs=input(' - ','s');
    if length(PIs)<5
        disp('nice try... PI username is too short.');
        disp(' ');
    else
        go_on=0;
    end
end


go_on=1;
while go_on
    disp('Describe the aim of your project in a few sentences:');
    Description=input(' - ','s');
    if length(Description)<40
        disp('nice try... description is too short.');
        disp(' ');
    else
        go_on=0;
    end
end

go_on=1;
while go_on
    disp('Start date (dd.mm.yyyy):');
    StartDate=input(' - ','s');
    % need to flip dd.mm.yyyy to mm.dd.yyyy - stupid SQL...
    StartDate=[StartDate(4:5) '.' StartDate(1:2) '.' StartDate(7:10)];
    if length(StartDate)~=10
        disp('nice try... check date format.');
        disp(' ');
    else
        go_on=0;
    end
end

go_on=input('Is all the information correct, do you want to create your project in ExpLog (y/n): ','s');

if strcmp(go_on,'y')
    DB=connectToExpLog;
    sql = ['INSERT INTO Projects (ProjectID,Name,PIs,Description,StartDate) '...
        'VALUES (''' ProjectID ''', ''' Name ''', ''' PIs ''', ''' Description ''', ''' StartDate ''')' ];
    ExpLog = adodb_query(DB, sql);
    DB.release;
    disp(' ');
    disp('*******************************************************')
    disp('******      your project has been created!    *********')
    disp('*******************************************************')
    disp(' ');
end




