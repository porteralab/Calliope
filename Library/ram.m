function varargout=ram
% displays current RAM usage in percent (snapshot, may be inaccurate)
% returns used ram in [%], e.g.: [85] represents 85% of ram is in use. 
% 16.01.2018 FW
[~,systemview]=memory;
usedram=round((systemview.PhysicalMemory.Total-systemview.PhysicalMemory.Available ) / systemview.PhysicalMemory.Total,6)*100;
fprintf('%.2f%% RAM used\n',usedram)
if nargout>0
    varargout{1}=usedram;
end
end