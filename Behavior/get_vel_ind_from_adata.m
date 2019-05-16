function [vel,vel_ind,vel_smoothed,vel_raw]=get_vel_ind_from_adata(data,scalefactor)
%%[vel,vel_ind,vel_smoothed,vel_raw]=get_vel_ind_from_adata(data)
%
% vel           : velocity filtered
% vel_ind       : velocity thresholded and binarisied
% vel_smoothed  : velocity filtered and smoothed
% vel_raw       : velocity raw (no filtering and smoothing)
%
% modified PZ 2013-10-01 if statement to distinguish aux_data dynamic range (either +/-5 or +/-10)
% modified PZ 2014-05-09 removed 'velM' and 'velP' tags to make function channel non-specific
% modified ML 2017-04-07 other scaling factors possible if specified

if ~exist('scalefactor','var')
    if round(max(data))>7
        scalefactor = 10;
    else
        scalefactor = 5;
    end
end

vel=diff(data);
vel(vel>scalefactor)=vel(vel>scalefactor)-(scalefactor*2);
vel(vel<-scalefactor)=vel(vel<-scalefactor)+(scalefactor*2);

vel_raw=vel;
vel=ftfil(vel,1000,0,10);
vel_smoothed=smooth2(vel,1000);
vel_ind=vel_smoothed>0.005;