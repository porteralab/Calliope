
nbins=50;

figure;
hold on;
mplot=[];
m_act_fb=[];
m_act_da=[];

for tp=1:8;
    mpos_act=[];
    mpos_rot=[];
    for siteID=[3 5 7 10 6 8 11];%[6 8 11]%
        
        
        pos_bins=round(proj_meta(siteID).rd(1,tp).VRx*nbins/5);
        pos_act=[];
        pos_rot=[];
        
        rewards=find(diff(proj_meta(siteID).rd(1,tp).VRrew>1)==1);
        if isempty(rewards)
            first_rew=1;
        else
            first_rew=rewards(min(4,length(rewards)));
            last_rew=rewards(1);
        end
        
        pos_bins(first_rew:end)=-1;
        pos_bins(1:last_rew)=-1;
        
        cur_act=proj_meta(siteID).rd(1,tp).act;
        
        
        cur_act(cur_act<1.25)=1;
        m_act_fb(siteID,tp)=sum(sum(cur_act(:,1:75000)>3))/prod(size(cur_act(:,1:75000)));
        
        try
            m_act_da(siteID,tp)=sum(sum(cur_act(:,75001:100000)>3))/prod(size(cur_act(:,75001:100000)));
        catch
            m_act_da(siteID,tp)=NaN;
        end
        
        m_act_first(siteID,tp)=sum(sum(cur_act(:,proj_meta(siteID).rd(1,tp).VRx>2.5)>3))/prod(size(cur_act(:,proj_meta(siteID).rd(1,tp).VRx>2.5)));
        m_act_last(siteID,tp)=sum(sum(cur_act(:,proj_meta(siteID).rd(1,tp).VRx<2.5)>3))/prod(size(cur_act(:,proj_meta(siteID).rd(1,tp).VRx<2.5)));
        
        ccmat(siteID,tp,:,:)=corrcoef(act);
        
        tmp=corrcoef(mean(cur_act),proj_meta(siteID).rd(1,tp).velR_smoothed);
        cc_act_velM(siteID,tp)=tmp(2);
        
        for ind=1:nbins
            pos_act(:,ind)=mean(cur_act(:,pos_bins==ind),2);
            pos_rot(ind)=mean(abs(proj_meta(siteID).rd(1,tp).velR_smoothed(pos_bins==ind)));
        end
        
        mpos_act(:,tp,siteID)=mean(pos_act);
        mpos_rot(:,tp,siteID)=pos_rot;
        
    end
    
    mpos_act(mpos_act==0)=NaN;
    mplot(tp,:)=nanmean(nanmean(mpos_act,3),2);
    plot(mplot(tp,:)-mean(mplot(tp,1:5)),'color',[1 1 1]*tp/12)
end
 figure;imagesc(bsxfun(@minus,mplot',nanmean(mplot(:,1:5)'))')
% 
% figure;plot(squeeze(nanmean(mpos_act,2)))


% mpos_rot(mpos_rot==0)=NaN;
% figure;plot(nanmean(nanmean(mpos_rot,3),2))