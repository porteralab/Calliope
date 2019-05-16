function [fract_running]=check_my_running(aux_data)
% this function checks the fraction of time spent running and reports
% results
%--------------------------------------------------------------------------
% Returns running as a fraction (0 to 1), as well as the number of running
% onsets
% doc edited by AF, 08.05.2014

velM=diff(aux_data(5,:));
velM(velM>5)=velM(velM>5)-10;
velM(velM<-5)=velM(velM<-5)+10;
velM_raw=velM;
velM=ftfil(velM,1000,0,10);

smoothed_running=abs(smooth2(velM,2000));
figure; plot(smoothed_running)
rind=smoothed_running>0.0001;

fract_running=sum(rind)/length(rind);
run_onsets=sum(diff(rind)==1);

error_str='So far so good!';

if fract_running<0.1
    error_str='The animal probably did not run enough - consider redoing the experiment!';
elseif fract_running>0.8
    error_str='The animal probably ran too much - consider redoing the experiment!';
end
   
disp(['Fraction of time spent running: ' num2str(fract_running)]);
disp(['Number of running onsets: ' num2str(run_onsets)]);
disp(error_str);


end

