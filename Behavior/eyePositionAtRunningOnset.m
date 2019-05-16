function eyePositionAtRunningOnset(proj_meta,siteID,tp);


win_l=100;
win_r=100;

r_onsets=find(diff(proj_meta(siteID).rd(1,tp).velM_smoothed>0.005)==1);
r_onsets(r_onsets<win_l)=[];
r_onsets(r_onsets>length(proj_meta(siteID).rd(1,tp).velM_smoothed)-win_r)=[]

r_onsets=r_onsets(proj_meta(siteID).rd(1,tp).ps_id(r_onsets)>1)

if length(r_onsets)==0
    disp('No running onsets found');
    return
elseif length(r_onsets)>100
    disp('warning - more than 100 running onsets found');
end

for ind=1:length(r_onsets)
    pupil_pos_x(:,ind)=proj_meta(siteID).rd(1,tp).pupil_pos(1,r_onsets(ind)-win_l:r_onsets(ind)+win_r);
    pupil_pos_y(:,ind)=proj_meta(siteID).rd(1,tp).pupil_pos(2,r_onsets(ind)-win_l:r_onsets(ind)+win_r);
    pupil_diam(:,ind)=proj_meta(siteID).rd(1,tp).pupil_diam(r_onsets(ind)-win_l:r_onsets(ind)+win_r);
end


figure; 
subplot(2,1,1);hold on;
plot(mean(pupil_pos_x')-mean(mean(pupil_pos_x(1:win_l,:)')))
plot(mean(pupil_pos_y')-mean(mean(pupil_pos_y(1:win_l,:)')),'r')
axis tight
subplot(2,1,2);
plot(mean(pupil_diam'),'k')
axis tight