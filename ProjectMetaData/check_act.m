function check_act(proj_meta)
% checks for inconsistencies in act matriices in proj_meta file
%
% usage: check_act;
%
% FW 2018

if ~exist('proj_meta','var'), proj_meta=evalin('base','proj_meta'); end
badexpids=[];

disp([char(10) 'size of activity matrices:'] );
for siteID=1:size(proj_meta,2)
    act_tp={};
    for tp=1:size(proj_meta(siteID).rd,2)
        act={};
        act_empty=[0 0 0 0];
        for zl=1:4
            try
                act{zl}=proj_meta(siteID).rd(zl,tp).act;
                if isempty(act{zl}), act_empty(zl)=1; badexpids=[badexpids proj_meta(siteID).ExpGroup(tp)]; end
            catch me
            end
        end
        if any(act_empty), suffix=sprintf(' (act [%i] empty)',find(act_empty)); else suffix=''; end
        try
            act_tp{tp}=cat(1,act{:});
            if tp==1 &&  size(act_tp{tp},1)~=0 && ~isempty(act_tp{tp})
                fprintf('siteID %2d tp %1d: [%4d,%6d] %s\n',siteID,tp,size(act_tp{tp},1),size(act_tp{tp},2),suffix);
            elseif tp==1 && ~( size(act_tp{tp},1)~=0 && ~isempty(act_tp{tp}))
                fprintf('s (!)  %2d tp %1d: [%4d,%6d] :: ExpID %d, mouse ''%s'' %s\n',siteID,tp,size(act_tp{tp},1),size(act_tp{tp},2),proj_meta(siteID).ExpGroup(tp),proj_meta(siteID).animal,suffix);
                badexpids=[badexpids proj_meta(siteID).ExpGroup(tp)];
            else
                %assume the first timepoint has the correct number of cells
                if size(act_tp{tp},1)==size(act_tp{1},1)  && size(act_tp{tp},1)~=0 && ~isempty(act_tp{tp})
                    fprintf('          tp %1d: [%4d,%6d] %s\n',tp,size(act_tp{tp},1),size(act_tp{tp},2),suffix);
                else
                    fprintf('  (!)     tp %1d: [%4d,%6d] :: ExpID %d, mouse ''%s'' %s\n',tp,size(act_tp{tp},1),size(act_tp{tp},2),proj_meta(siteID).ExpGroup(tp),proj_meta(siteID).animal,suffix);
                    badexpids=[badexpids proj_meta(siteID).ExpGroup(tp)];
                end
            end
        catch
            warning('couldnt''t concatinate act of zlayers siteID/tp (%d/%d):\n neurons zl(1:4)=%d,%d,%d,%d',siteID,tp,size(act{1},1),size(act{2},1),size(act{3},1),size(act{4},1))
        end
    end
    
end

if ~isempty(badexpids)
    fprintf('\nbad expIDs have been copied to clipboard: %s \n\n',regexprep(num2str(badexpids),'  ',','));
    clipboard('copy',badexpids)
    fprintf('press any key to run check_siteID for the bad sites\n');
    pause;
    
    %get siteIDs from stackIDs
    ExpLog=getExpLog;
    idx=[];
    for ind=1:numel(badexpids)
        idx=[idx find([ExpLog.stackid{:}]==badexpids(ind))];
    end
    badsites=[ExpLog.siteid{idx}];
    badsites=unique(badsites);
    for ind=1:numel(badsites)
        check_siteROIs(badsites(ind),[],0);
    end
else
    fprintf('\nno inconsistencies found.\n');
end