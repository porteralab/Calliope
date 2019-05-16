function []=commit(LogMessage)

% commit the script titled "LogMessage" to the code repository

eval(['!svn commit C:\Code\ImageAnalysis -m "' LogMessage '"']);
