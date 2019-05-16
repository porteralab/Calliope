function []=proj_info(project_ID)

try
    ExpLog=getExpLog;
    
    proj_inds=find(strcmp(ExpLog.project,project_ID));
    user=unique(ExpLog.pi(proj_inds));
    
    [site_IDs,sites_in_rows]=unique(cell2mat(ExpLog.siteid(proj_inds)),'first');
    animals=ExpLog.animalid(proj_inds(sites_in_rows));
    comments=ExpLog.comment(proj_inds(sites_in_rows));
    
    
    disp(['Report for project ' project_ID ' - PI: ' user{1}])
    
    
    for ind=1:length(site_IDs)
        fprintf(['Site: ' num2str(site_IDs(ind)) ' \t' animals{ind} ' \t' regexprep(num2str(comments{ind}),{'%' '\' '\n' '\r' 'span'},'') ' \n'])
    end
catch
    disp('Project ID not found in DB');
end


