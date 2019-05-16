function check_registration_batch(SiteID)
%CHECK_REGISTRATION_BATCH Batch check registration by "imaging site".
% Output all check_registration plots of all experiments from the specified
% SiteID. Figures will be named as respective ExpIDs.
%
% BW 20160708

ExpLog = getExpLog;

exp_ind = find(cell2mat(ExpLog.siteid)==SiteID);
exp_id = cell2mat(ExpLog.expid);
exp_id = unique(exp_id(exp_ind));

for cur_exp_ind = exp_id'
    display(['Now checking registration of Exp ' num2str(cur_exp_ind)])
    check_registration(cur_exp_ind)
end
end