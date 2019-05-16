function snps=pm_trig_act(proj_meta,trig_ch,thrsh,tps,frame_range)
% returns matrix of snippets triggered on threshold crossings of trig_ch
% example snps=pm_trig_act(proj_meta,'Pertubations',0.5,[1:12],[5001 10000]);
% GK - 19.02.2015


if nargin<3
    thrsh=0.5;
end

if nargin<4
    tps=1:100;
end

if nargin<5
    frame_range=[1 inf];
end

win_l=100;
win_r=100;

snps=[];
cnt=0;

for siteID=1:length(proj_meta)
    for tp=tps
        try
            for zl=1:4
                trig=eval(['proj_meta(siteID).rd(zl,tp).' trig_ch]);
                trigs=find(diff(trig>thrsh)==1);
                trigs(trigs<max(win_l+1,frame_range(1)+1))=[];
                trigs(trigs>min(length(trig)-win_r-1,frame_range(2)-1))=[];
                
                for ind=1:length(trigs)
                    cnt=cnt+1;
                    snps(:,cnt)=mean(proj_meta(siteID).rd(zl,tp).act(:,trigs(ind)-win_l:trigs(ind)+win_r),1);
                end
            end
        end
    end
end

                
            
            
            
    
    

