function frames=session2frames(proj_meta,siteID,tp,sessionID,session_field_name)
% converts a session ID to frames
% the session ID has to be in the form of a string in proj_meta as
% e.g. proj_meta(siteID).rd(zl,tp).session_id='FFPPDDFF'
% use the last variable 'session_field_name' to specify field name if not
% 'session_id' (default)
% usage session2frames(proj_meta,siteID,tp,'F','sessionID')


if nargin<5
    session_field_name='session_id';
end

if ~eval(['iscell(proj_meta(siteID).rd(1,tp).' session_field_name ')'])
    eval(['list_of_sessions=strsplit(proj_meta(siteID).rd(1,tp).' session_field_name ');']);
    sess_id=find(strcmp(list_of_sessions,sessionID));
    
else
    eval(['list_of_sessions=proj_meta(siteID).rd(1,tp).' session_field_name ';']);
    eval(['sess_id=find(proj_meta(siteID).rd(1,tp).' session_field_name '==sessionID);']);
end

sess_ons=[1 cumsum(proj_meta(siteID).rd(1,tp).nbr_frames)+1];
sess_off=[cumsum(proj_meta(siteID).rd(1,tp).nbr_frames)];
frames=[];
for ind=1:length(sess_id)
    frames=[frames sess_ons(sess_id(ind)):sess_off(sess_id(ind))];
end