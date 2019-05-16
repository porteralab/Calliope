function cb_plugin_ACX(params,cbh,proj_meta)
win=100;
act=proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:);
tact=act>1+(2.5*std(act));
act_onsets=find(diff(tact)==1);
act_onsets(act_onsets<win+1)=[];
act_onsets(act_onsets>length(tact)-win-1)=[];
use_onset=logical(1);
for ind=1:length(act_onsets)
    use_onset(ind)=~sign(sum(tact(act_onsets(ind)-win/2:act_onsets(ind))));
end
act_onsets=act_onsets(use_onset);
plotNum=5;
figure(90);
clf
set(gcf,'pos',[2836        -159         666         976])
for gnd=1:length(act_onsets)
    
    subplot(plotNum,1,1)
    hold on
    plot(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,act_onsets(gnd)-win:act_onsets(gnd)+win))
    axis tight
    
    subplot(plotNum,1,2)
    hold on
    plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(act_onsets(gnd)-win:act_onsets(gnd)+win),'r')
    axis tight
    
    subplot(plotNum,1,3)
    hold on
    plot(proj_meta(params.site_id).rd(params.zl,params.tp).airPuff(act_onsets(gnd)-win:act_onsets(gnd)+win),'k')
    axis tight
    
    subplot(plotNum,1,4)
    hold on
    plot(proj_meta(params.site_id).rd(params.zl,params.tp).el_stim(act_onsets(gnd)-win:act_onsets(gnd)+win),'y')
    axis tight
    
    subplot(plotNum,1,5)
    hold on
    plot(proj_meta(params.site_id).rd(params.zl,params.tp).aud_trig(act_onsets(gnd)-win:act_onsets(gnd)+win),'g')
    axis tight
end
figure(cbh.mf);