function listProjectsExpLog(uname)
% shows Project in the ExpLog database
% GK - 18.07.2016

if nargin<1
    uname='';
end


ExpLogProjects=getExpLogProjects;

if isempty(uname)
    inds=1:length(ExpLogProjects.projectid)
else
    inds=find(~cellfun(@isempty,strfind(ExpLogProjects.pis,uname)));
end



disp(' ')
disp(' ')

for ind=inds(:)'
    disp([ExpLogProjects.projectid{ind} ' - ' num2str(ExpLogProjects.pis{ind}) ' - ' num2str(ExpLogProjects.description{ind})])
end

disp(' ')
disp(' ')
