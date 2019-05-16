function [saccade_frames, pupil_diam, pupil_pos, blink] = find_saccades(idata)
% [saccade_frames, pupil_diam, pupil_pos, blink] = find_saccades(idata)
% extracts saccades, pupil diameter, pupil position and blinks from idata
% GK - long ago...


tmp=idata(:,:,1);

center_tmp=round(size(tmp)/2);

pupil_diam=zeros(length(idata),1);
pupil_pos=ones(2,length(idata));
blink=zeros(length(idata),1);
thresh_mem=ones(1,length(idata));

pupil_pos(1,:)=pupil_pos(1,:)*center_tmp(1);
pupil_pos(2,:)=pupil_pos(2,:)*center_tmp(2);

nothing_yet=1;
for ind=4:size(idata,3)-2
    tmp=idata(:,:,ind);
    
    if nothing_yet
        center_tmp=round(size(tmp)/2);
        thrsh=0.81*mean(mean(tmp(center_tmp(1)-10:center_tmp(1)+10,center_tmp(2)-10:center_tmp(2)+10)));
    else
        center_tmp=round(mean(pupil_pos(:,max(1,ind-10):ind-1),2))';
        thrsh=mean([0.81*mean(mean(tmp(max(1,center_tmp(1)-10):min(size(tmp,1),center_tmp(1)+10),max(1,center_tmp(2)-10):min(size(tmp,2),center_tmp(2)+10)))) thresh_mem(max(1,ind-10):max(1,ind-1))]);
    end
    
    thresh_mem(ind)=thrsh;
    
    offsets=[0 1 -1 2 -2 3 -3 4 -4; 0 2 -2 -1 1 4 -4 -3 3];
    
    try
        for jnd=1:9
            x1(jnd)=find(tmp(center_tmp(1)+offsets(1,jnd):end,center_tmp(2)+offsets(2,jnd))<thrsh,1,'first');
            x2(jnd)=find(tmp(center_tmp(1)+offsets(1,jnd):-1:1,center_tmp(2)+offsets(2,jnd))<thrsh,1,'first');
            y1(jnd)=find(tmp(center_tmp(1)+offsets(1,jnd),center_tmp(2)+offsets(2,jnd):end)<thrsh,1,'first');
            y2(jnd)=find(tmp(center_tmp(1)+offsets(1,jnd),center_tmp(2)+offsets(2,jnd):-1:1)<thrsh,1,'first');
        end
        x1=mean(x1);
        x2=mean(x2);
        y1=mean(y1);
        y2=mean(y2);
    catch
        x1=[];
        x2=[];
        y1=[];
        y2=[];
    end


    if sum([isempty(x1) isempty(x2) isempty(y1) isempty(y2)])==0
        pupil_diam(ind)=sqrt(((x1+x2)/2)^2+((y1-y2)/2)^2);
        pupil_pos(:,ind)=center_tmp+[x1-x2 y1-y2]/2;
        nothing_yet=0;
    else
        pupil_diam(ind)=pupil_diam(ind-1);
        pupil_pos(:,ind)=pupil_pos(:,ind-1);
    end
    
    blink(ind)=mean(mean(tmp(max(1,round(pupil_pos(1,ind))-10):min(size(tmp,1),round(pupil_pos(1,ind))+10),max(1,round(pupil_pos(2,ind))-10):min(size(tmp,2),round(pupil_pos(2,ind))+10))));
end

saccade_frames=sqrt(sum(diff(pupil_pos').^2,2))>5;
saccade_frames=round((find(diff(saccade_frames)==1)+find(diff(saccade_frames)==-1))/2);



% % ccc=squeeze(max(idata(round(size(idata,1)/4):round(3*size(idata,1)/4),round(size(idata,2)/4):round(3*size(idata,2)/4),:),[],1));
% % 
% % for ind=1:size(ccc,2)
% %     tmp=double(ccc(:,ind));
% %     pos(ind)=tmp'*[1:length(tmp)]'/sum(tmp);
% %     
% %     
% %     pupil_diam(ind)=sum(((tmp-min(tmp))/(max(tmp)-min(tmp)))>0.75);
% % end
% %     
% % diff_pos=zeros(length(pos),1);
% % eye_blink=zeros(length(pos),1);
% % 
% % for ind=11:length(pos)-11
% %     diff_pos(ind)=mean(pos(ind:ind+10))-mean(pos(ind-10:ind-1));
% % end
% % 
% % saccade_frames=(abs(diff_pos)>1);
% % 
% % 
% % eye_blink=abs(diff(pupil_diam))>20;
% % eye_blink(1:10)=0;
% % eye_blink(end-10:end)=0;
% % 
% % for ind=find(eye_blink)
% %     eye_blink(ind-5:ind+5)=1;
% % end
% % 
% % saccade_frames(eye_blink)=0;
% % 
% % eye_blink=find(eye_blink);
% % saccade_frames=round((find(diff(saccade_frames)==1)+find(diff(saccade_frames)==-1))/2);


% pupil_vel=abs([0 diff(imeta_data(8,:))]);
% pupil_vel=pupil_vel+abs([0 diff(imeta_data(7,:))]);
% 
% pupil_vel(smooth(abs(diff(imeta_data(9,:)))>5,50)>0)=0;
% 
% %remove file transitions
% pupil_vel(pupil_vel>20)=0;
% pupil_vel(pupil_vel<-20)=0;
% 
% saccade_frames=(abs(pupil_vel)>5);
% 
% for ind=find(saccade_frames)
%     try
%         saccade_frames(ind+1:ind+3)=0;
%     end
% end
% 
% saccade_frames=find(saccade_frames);



% % 
% % pupil_diam=zeros(length(idata),1);
% % pupil_pos=zeros(2,length(idata));
% % nothing_yet=1;
% % for ind=3:size(idata,3)-2
% %     tmp=mean(idata(round(size(idata,1)/5):round(4*size(idata,1)/4),round(size(idata,2)/5):round(4*size(idata,2)/5),[ind-2:ind+2]),3);
% %     if nothing_yet | ind<200
% %         center_tmp=round(size(tmp)/2);
% %     else
% %         center_tmp=round(median(pupil_pos(:,ind-198:ind-1),2))';
% %         keyboard
% %     end
% %     thrsh=0.8*tmp(center_tmp(1),center_tmp(2));
% %     x1=find(tmp(center_tmp(1):end,center_tmp(2))<thrsh,1,'first');
% %     x2=find(tmp(center_tmp(1):-1:1,center_tmp(2))<thrsh,1,'first');
% %     y1=find(tmp(center_tmp(1),center_tmp(2):end)<thrsh,1,'first');
% %     y2=find(tmp(center_tmp(1),center_tmp(2):-1:1)<thrsh,1,'first');
% %     if sum([isempty(x1) isempty(x2) isempty(y1) isempty(y2)])==0
% %         pupil_diam(ind)=sqrt(((x1+x2)/2)^2+((y1-y2)/2)^2);
% %         pupil_pos(:,ind)=center_tmp+[x1-x2 y1-y2];
% %         nothing_yet=0;
% %     else
% %         pupil_diam(ind)=pupil_diam(ind-1);
% %         pupil_pos(:,ind)=pupil_pos(:,ind-1);
% %     end
% % end
% % 
% % end

