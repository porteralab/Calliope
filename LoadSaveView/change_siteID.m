function change_siteID(siteIDold,siteIDnew)
% changes the siteID of an ExpGroup in the ExpLog database
% siteIDold is the siteID you want to change
% siteIDnew is the siteID you want to chnage it to
% use this function when the default siteID (typically the first stack in
% an eperiment) is unsuited to be used as main ROI alignment time point
% GK - 19.12.2013

disp('Be careful when using this function - are you sure you know what you are doing?')
go_on=input(['You are about to change siteID ' num2str(siteIDold) ' to ' num2str(siteIDnew) '. Do you want to proceed? [y/n]: '],'s');

if strcmp(go_on,'y');
    
    if siteIDold==siteIDnew
        disp('Old and new siteID need to be different! Aborting.');
        return
    end
   
    
    DB=connectToExpLog;
    
    sql=['UPDATE Sites SET Sites.siteid = ' num2str(siteIDnew) ' WHERE Sites.siteid = ' num2str(siteIDold)];
    ExpLog = adodb_query(DB, sql);
    
    sql=['UPDATE Experiments SET Experiments.siteid = ' num2str(siteIDnew) ' WHERE Experiments.siteid = ' num2str(siteIDold)];
    ExpLog = adodb_query(DB, sql);
    
    DB.release;
    
    
else
    disp('phewww... close call...')
end