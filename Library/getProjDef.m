function [pdef]=getProjDef(projID)
%getProjDef load project definitions into a structre "pdef"
%
% calls the project specific function ProjectDefinitions_projID,
% e.g. ProjectDefinitions_ENU
%GK - 08.05.2014
% try 
%     Acode = str2double(evalin('caller','Acode'));
% catch
%     disp('NC Warning - No Acode found, setting it to 1 for now')
%     Acode = 1;
% end


try
    
    eval(['pdef=ProjectDefaults_' projID ';']);
    
    % make sure pathnames are FQDNS (...fmi.ch)
    for ind=1:length(pdef.backup_destination)
        if isempty(strfind(pdef.backup_destination{ind},'.fmi.ch'))
            thrid_backslash=strfind(pdef.backup_destination{ind},'\');
            thrid_backslash=thrid_backslash(3);
            pdef.backup_destination{ind}=[pdef.backup_destination{ind}(1:thrid_backslash-1) '.fmi.ch' pdef.backup_destination{ind}(thrid_backslash:end)];
        end
    end
    
    
    if ~isfield(pdef,'main_channel')
        pdef.main_channel='ch525';
    end
    if ~isfield(pdef,'secondary_channels')
        pdef.secondary_channels={};
    end
catch
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('!!!!!!!!!!!!!!!!!!! Read Me !!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('No ProjectDefinitions function found for your project');
    disp('Please add one to the \Code\ImageAnalysis\ProjectDefaults directory');
    disp('Refer to an existing function for an example');
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    pdef=struct;
end
