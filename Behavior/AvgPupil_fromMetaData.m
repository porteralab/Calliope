
meta_files_to_load={'ENU_meta.mat','HOM_1_meta.mat','NPY_1_meta.mat','M1_5_meta.mat'};

zl=1;
win_l=100;
win_r=100;
pupil_snips=[];
running_snips=[];
cnt=0;
cnt_site=0;
cnt_tp=0;
total_time=[];
total_onsets=[];
total_sites=[];

for knd=1:length(meta_files_to_load);
    disp(['Now working on ' meta_files_to_load{knd}]);
    load(['C:\MetaDataTemp\' meta_files_to_load{knd}]);
    cnt_site=cnt_site+1;
    total_sites(cnt_site)=size(proj_meta,2);
    
    for siteID=1:size(proj_meta,2)

        
        for tp=1:size(proj_meta(siteID).rd,2)
            cnt_tp=cnt_tp+1;
            run_onsets=find(diff(proj_meta(siteID).rd(zl,tp).velM_smoothed>0.005)==1);
            run_onsets(find(diff(run_onsets)<200)+1)=[];
            
            run_onsets(run_onsets<win_l+1)=[];
            run_onsets(run_onsets>length(proj_meta(siteID).rd(zl,tp).velM_smoothed)-win_r-1)=[];
            
            total_time(cnt_tp)=length(proj_meta(siteID).rd(zl,tp).velM_smoothed);
            total_onsets(cnt_tp)=length(run_onsets);
            
            for ind=1:length(run_onsets)
                cnt=cnt+1;
                pupil_snips(:,cnt)=proj_meta(siteID).rd(zl,tp).pupil_diam(run_onsets(ind)-win_l:run_onsets(ind)+win_r);
                running_snips(:,cnt)=proj_meta(siteID).rd(zl,tp).velM_smoothed(run_onsets(ind)-win_l:run_onsets(ind)+win_r);
            end
            
        end
    end
end

running_snips(:,sum(pupil_snips<5)>0)=[];
pupil_snips(:,sum(pupil_snips<5)>0)=[];

running_snips(:,sum(pupil_snips>100)>0)=[];
pupil_snips(:,sum(pupil_snips>100)>0)=[];

mpup=mean(pupil_snips');
sempup=std(pupil_snips');
sempup=sempup/(max(mpup)-min(mpup))/sqrt(size(pupil_snips,2));
mpup=(mpup-min(mpup))/(max(mpup)-min(mpup));

mrun=mean(running_snips');
semrun=std(running_snips');
semrun=semrun/(max(mrun)-min(mrun))/sqrt(size(running_snips,2));
mrun=(mrun-min(mrun))/(max(mrun)-min(mrun));

figure;
hold on;
plot(mpup)
plot(mrun,'r')
area([1:201 201:-1:1],[mrun+semrun flipdim(mrun-semrun,2)],'facecolor',[1 1 1]*0.7,'linestyle','none')
area([1:201 201:-1:1],[mpup+sempup flipdim(mpup-sempup,2)],'facecolor',[1 1 1]*0.7,'linestyle','none')
plot(mpup,'linewidth',2)
plot(mrun,'r','linewidth',2)
plot([1 1]*win_l,[0 1],'k')
set(gca,'xtick',[0:20:200]);
set(gca,'xticklabel',[-10:2:10]);
xlabel('Time [s]');
ylabel('Normalized to [max min]')
xlim([25 200])
ylim([0 1])
legend({'pupil diameter [+/- SEM]','running speed [+/- SEM]'})
title(['Based on: ' num2str(round(sum(total_time)/10/60/60)) ' hours - ' num2str(sum(total_onsets)) ' running onsets in ' num2str(sum(total_sites)) ' mice'])







