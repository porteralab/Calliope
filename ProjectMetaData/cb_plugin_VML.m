function cb_plugin_VML(params,cbh,proj_meta)
% Cell browser plugin for the VML project.
%
% Figure 12 plots the speed of visual flow against the running speed of the
% playback session selected in the cell browser, where the red trace is 
% before the velocity before the calcium transient onset and the green is
% after the onset. If the animal coupled its behavior to the visual flow,
% the trajectory should be around the diagonal.
%
% Figure 11 plots the scaled calcium transient activity around the activity
% onset of the channels selected in the cell browser.
figure(12);
clf
hold on
plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed,...
    proj_meta(params.site_id).rd(params.zl,params.tp).velP_smoothed)
xlim([0.001 0.025])
ylim([0.001 0.025])


figure(11);
clf
hold on

win=200;
tact=proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:)>1.5;
act_onsets=find(diff(tact)==1);
act_onsets(act_onsets<win+1)=[];
act_onsets(act_onsets>length(tact)-win-1)=[];
use_onset=logical(1);
for ind=1:length(act_onsets)
    use_onset(ind)=~sign(sum(tact(act_onsets(ind)-win/2:act_onsets(ind))));
end
act_onsets=act_onsets(use_onset);

for ind=1:size(params.chansToPlot,1)
    for knd=1:size(params.chansToPlot{ind},2)
        if strcmp(params.rdfields{params.chansToPlot{ind}(knd)},'act')
            tmp_trace=ntzo(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:));
        else
            eval(['tmp_trace=proj_meta(' num2str(params.site_id) ').rd(' num2str(params.zl) ',' ...
                num2str(params.tp) ').' params.rdfields{params.chansToPlot{ind}(knd)} ';']);
        end
        cntM=0;
        cntP=0;
        snp_mat=NaN(2*win+1,1,2);
        if ind==1&knd==1
            figure(12);
        end
        
        for lnd=1:length(act_onsets)
            if act_onsets(lnd)<proj_meta(params.site_id).rd(params.zl,params.tp).nbr_frames(1)
                cntM=cntM+1;
                snp_mat(:,cntM,1)=tmp_trace(act_onsets(lnd)-win:act_onsets(lnd)+win);
            else
                cntP=cntP+1;
                snp_mat(:,cntP,2)=tmp_trace(act_onsets(lnd)-win:act_onsets(lnd)+win);
            end
            if ind==1&knd==1
                plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(act_onsets(lnd)...
                    -20:act_onsets(lnd)),proj_meta(params.site_id).rd(params.zl,params.tp)...
                    .velP_smoothed(act_onsets(lnd)-20:act_onsets(lnd)),'r','linewidth',2)
                plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(act_onsets(lnd)...
                    :act_onsets(lnd)+20),proj_meta(params.site_id).rd(params.zl,params.tp)...
                    .velP_smoothed(act_onsets(lnd):act_onsets(lnd)+20),'g','linewidth',2)
            end
            
        end
        if ind==1&knd==1
            figure(11);
        end
        subplot(5,1,6-ind);
        hold on
        plot(mean(snp_mat(:,:,1),2),'r')
        plot(mean(snp_mat(:,:,2),2),'g')
        axis tight
    end
    
end

title(['Nuber of onsets: ' num2str(sum(use_onset))]);


figure(cbh.mf);
