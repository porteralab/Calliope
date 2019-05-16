% running on LFM_GC5_2_meta

siteID=1;
tp=1;
zl=1;

dark_lenght=5000;

figure;
for siteID=1:5
    for tp=1
        
        ccP=[];
        ccM=[];

        fbsess=find(proj_meta(siteID).rd(zl,tp).nbr_frames==5000);
        fbsess(end)=[];
        pbsess=fbsess+1;
        
        frame_win=[];
        for ind=1:length(pbsess)
            frame_win=[frame_win sum(proj_meta(siteID).rd(zl,tp).nbr_frames(1:pbsess(ind)-1))+1:sum(proj_meta(siteID).rd(zl,tp).nbr_frames(1:pbsess(ind)))];
        end
        
        mda=mean(proj_meta(siteID).rd(zl,tp).act(:,end-dark_lenght+1:end)');
        
        for ind=1:size(proj_meta(siteID).rd(zl,tp).act,1)
            tmp=corrcoef(proj_meta(siteID).rd(zl,tp).act(ind,frame_win),proj_meta(siteID).rd(zl,tp).velP_smoothed(frame_win));
            ccP(ind)=tmp(2);
            tmp=corrcoef(proj_meta(siteID).rd(zl,tp).act(ind,frame_win),proj_meta(siteID).rd(zl,tp).velM_smoothed(frame_win));
            ccM(ind)=tmp(2);
        end
        
        
%         subplot(1,3,1)
%         hold on
%         plot(ccP,mda,'.')
%         
%         subplot(1,3,2)
%         hold on
%         plot(ccM,mda,'.')
%         
%         subplot(1,3,3)
        plot(ccP,ccM,'.','markersize',20)
        hold on
        plot(ccP(mda>1.0125),ccM(mda>1.0125),'r.','markersize',20)
        
        
    end
end