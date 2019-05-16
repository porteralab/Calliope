function [act_onsets] = cb_plugin_turning(params,cbh,proj_meta);

% plots a variety of additional, movement related parameters aligned to
% activity windows

figure(11);
clf
hold on

figure(12);
clf
set(gcf,'Position',[740 40 401 258])
hold on
plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed,proj_meta(params.site_id).rd(params.zl,params.tp).velR_smoothed)
% xlim([-0.1 0.01])
% ylim([-0.1 0.1])
xlim([-0.1 0.1])
ylim([-0.1 0.1])

figure(13);
clf

figure(15);
clf


tact=proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:);
win=150;
% thresh = 1.7*mean(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:));
thresh = 1+(std(tact)*2.5);
tact=smooth2(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:),20)>thresh;
act_onsets=find(diff(tact)==1);
if isempty(act_onsets)
    disp('No act onsets with threshold criteria detected. Aborting ...')
    return
end
act_onsets(act_onsets<win+1)=[];
act_onsets(act_onsets>length(tact)-win-1)=[];
use_onset=logical(1);
for ind=1:length(act_onsets)
    use_onset(ind)=~sign(sum(tact(act_onsets(ind)-win/2:act_onsets(ind))));
end
act_onsets=act_onsets(use_onset);
% act_onsets(act_onsets>75000) = [];

for ind=1:size(params.chansToPlot,1)
    for knd=1:size(params.chansToPlot{ind},2)
        if strcmp(params.rdfields{params.chansToPlot{ind}(knd)},'act')
            tmp_trace=ntzo(proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,:));
        else
            eval(['tmp_trace=proj_meta(' num2str(params.site_id) ').rd(' num2str(params.zl) ',' num2str(params.tp) ').' params.rdfields{params.chansToPlot{ind}(knd)} ';']);
        end
        cnt=0;
        snp_mat=[];
        figure(12);
%         set(gcf,'Position',[740 40 401 334])
        %set(gcf,'Position',[2180 22 441 307])
        for lnd=1:length(act_onsets)
            cnt=cnt+1;
            snp_mat(:,cnt)=tmp_trace(act_onsets(lnd)-win:act_onsets(lnd)+win);
            
            if ind==1&knd==1
                plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(act_onsets(lnd)-20:act_onsets(lnd)),proj_meta(params.site_id).rd(params.zl,params.tp).velR_smoothed(act_onsets(lnd)-20:act_onsets(lnd)),'r','linewidth',2)
                plot(proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(act_onsets(lnd):act_onsets(lnd)+20),proj_meta(params.site_id).rd(params.zl,params.tp).velR_smoothed(act_onsets(lnd):act_onsets(lnd)+20),'g','linewidth',2)
                act_mat(:,:,cnt)=proj_meta(params.site_id).rd(params.zl,params.tp).act(:,act_onsets(lnd)-win:act_onsets(lnd)+win);
                velM_mat(:,:,cnt) = -proj_meta(params.site_id).rd(params.zl,params.tp).velM_smoothed(1,act_onsets(lnd)-win:act_onsets(lnd)+win);
                velR_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).velR_smoothed(1,act_onsets(lnd)-win:act_onsets(lnd)+win);
                try
                ipos1_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).pupil_pos(1,act_onsets(lnd)-win:act_onsets(lnd)+win);
                ipos2_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).pupil_pos(2,act_onsets(lnd)-win:act_onsets(lnd)+win);
%                 ipos1_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).pupil_pos(1,act_onsets(lnd)-win:act_onsets(lnd)+win);
%                 ipos2_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).pupil_pos(2,act_onsets(lnd)-win:act_onsets(lnd)+win);
                VRx_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).VRx(1,act_onsets(lnd)-win:act_onsets(lnd)+win);
                VRrew_mat(:,:,cnt) = proj_meta(params.site_id).rd(params.zl,params.tp).VRrew(1,act_onsets(lnd)-win:act_onsets(lnd)+win);

                end
            end
        end
        title('velM vs velR, 20 before onset red, 20 after onset green')
        
        figure(13);
%         set(gcf,'Position',[1155 38 401 334])
        set(gcf,'Position',[1155 38 401 260])
        %set(gcf,'Position',[2636 18 496 319])
        tmp=mean(act_mat,3);
        [~,sortID]=sort(max(tmp,[],2));
        imagesc(tmp(sortID,:));
        title('raster aligned to max any cell act')
        
        figure(11),
%         set(gcf,'Position',[19 23 560 792])
        set(gcf,'Position',[8 71 585 721])
        %set(gcf,'Position', [1623 23 560 792])
        subplot(5,1,6-ind);
        hold on
        
        if ind == 4
            plot(snp_mat,'Color',[0.4 0.4 0.4])
            axis tight
            hold on
            plot(mean(snp_mat'),'r')
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 1)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            title([params.rdfields{params.chansToPlot{ind}(knd)}])
        elseif strcmp(params.rdfields{params.chansToPlot{ind}(knd)},'pupil_pos')
            plot(mean(ipos1_mat,3)-36)
%         elseif ind == 1 
% %             | strcmp(params.rdfields{params.chansToPlot{ind}(knd)},'pupil_pos')
% %             plot(mean(ipos1_mat,3)-36)
% %             hold on
% %             plot(mean(ipos2_mat,3),'r')
%             plot(mean(VRx_mat,3))
%             hold on
%             axis tight
%             plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 1)
%             plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
%             plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
%             title([params.rdfields{params.chansToPlot{ind}(knd)}])
        else
            plot(snp_mat,'Color',[0.4 0.4 0.4])
            axis tight
            hold on
            plot(mean(snp_mat'),'r')
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 1)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            title([params.rdfields{params.chansToPlot{ind}(knd)}])
        end
        
        if ind == 5
            figure(14),
%             set(gcf,'Position',[606 435 987 381])
            set(gcf,'Position',[606 351 987 465])
            %set(gcf,'Position',[2201 435 987 381])
            clf
            hold on
            subplot(4,1,1),
            hold on
            plot(diff(mean(-velM_mat,3)));
            plot(diff(mean(velR_mat,3)),'r');
            %plot(diff(sqrt(mean(velM_mat,3).^2+mean(velR_mat,3).^2)),'--','color',[0 1 0.8])
            title('diff(velM): blue   diff(velR):red')
            %set(gca,'Ylim',[-0.0004 0.0004])
            axis tight
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 2)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([0 2*win], [0 0],'-.k')
            
            subplot(4,1,2),
            hold on
            plot(mean(-velM_mat,3));
            plot(mean(velR_mat,3),'r');
            %plot(diff(sqrt(mean(velM_mat,3).^2+mean(velR_mat,3).^2)),'--','color',[0 1 0.8])
            title('velM: blue   velR: red')
            %set(gca,'Ylim',[-0.0004 0.0004])
            axis tight
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 2)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([0 2*win], [0 0],'-.k')
            
            
            subplot(4,1,3),
            hold on
            plot(mean(mean(act_mat),3))
            axis tight
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 2)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            title('population mean')
            
            subplot(4,1,4),
            hold on
            plot(mean(snp_mat'))
            axis tight
            plot([win win], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.k','LineWidth', 2)
            plot([win+50 win+50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            plot([win-50 win-50], [max(get(gca,'Ylim')) min(get(gca,'Ylim'))],'-.g','LineWidth', 1)
            title(['cell mean, number of onsets: ' num2str(length(act_onsets))])
        end
        
    end
    
end

figure(15);
plot(proj_meta(params.site_id).rd(params.zl,params.tp).VRx(tact),proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,tact),'.')
hold on
plot(proj_meta(params.site_id).rd(params.zl,params.tp).VRx(act_onsets),proj_meta(params.site_id).rd(params.zl,params.tp).act(params.cell_ind,act_onsets),'ro')
xlabel('VRx')
ylabel('\DeltaF/F')
xlim([0 5])

figure(cbh.mf)