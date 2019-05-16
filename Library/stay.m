function stay
% make current figure un-closeable (figure will be ignored by 'ca' command)
% use ;close force' to force-close the figure 
% use 'close force all' to force-close all figures marked with 'stay'
% 16.01.2018 FW

a=gcf;
a.CloseRequestFcn=[];
end