function cpu
% displays current CPU usage in percent (snapshot, may be inaccurate)
% 16.01.2018 FW
[~,b]=system('wmic cpu get loadpercentage');
disp(['cpu load: ' strjoin(regexp(b,'[0-9]','match'),'') '%']);
end