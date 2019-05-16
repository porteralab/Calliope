function sendlog(email,title)
% sends current console output to specified email address
% examples:
% sendlog('example@fmi.ch'); 
% sendlog({'example1@fmi.ch','example2@fmi.ch'}); %multiple addresses
% sendlog('example@fmi.ch','Job completed!'); %specify email title
%
% 16.01.2018 FW

setSMTPprefGmail;
if ~exist('title','var') %if title is unspecified: autogenerate
    pc=getenv('COMPUTERNAME');
    sendmail(email,['log from:' pc],getlog);
else
    sendmail(email,title,getlog);
end
end