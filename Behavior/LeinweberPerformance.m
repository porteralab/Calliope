function performance=LeinweberPerformance(velM,velR,VRangle)
% calculates the performance of the mouse in a 2d navigate to the end of
% the corridor task. Use velM_smoothed, velR_smoothed, and VRangle 
% (-2.5 to 2.5 where 0 is the direction of the target).
%
% Performance is defined as the distance covered towards the target
% normalized by the total distance travelled.
%
% GK 15.07.19

vel=sqrt(velM(:).^2+velR(:).^2);
performance = sum(vel.*cos(VRangle(:)/2.5*pi))/sum(vel);

