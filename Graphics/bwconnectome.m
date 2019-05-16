function [cat,mask]=bwconnectome(img,min_nbr_pix)
% ------- OBSOLETE --------
% ------- DESTROY ---- DESTROY --- DESTROY
cnt=0;
cat=zeros(size(img));
equiv=[];
pix_count=[];

for ind=1:size(img,1)
    for knd=1:size(img,2)
        if img(ind,knd)==1
            nn=zeros(4,1);
            if ind>1
                nn(1)=cat(ind-1,knd);
            end
            if ind<size(img,1)
                nn(2)=cat(ind+1,knd);
            end
            if knd>1
                nn(3)=cat(ind,knd-1);
            end
            if knd<size(img,2)
                nn(4)=cat(ind,knd+1);
            end
            if any(~nn==0)
                tmp=min(nn(nn>0));
                cat(ind,knd)=tmp;
                if length(pix_count)<tmp
                    pix_count(tmp)=1;
                else
                    pix_count(tmp)=pix_count(tmp)+1;
                end
                equiv(tmp)=tmp;
                if max(nn)>tmp
                    if length(equiv)<tmp
                        equiv(max(nn))=tmp;
                    else
                        if equiv(tmp)==0
                            equiv(max(nn))=tmp;
                        else
                            equiv(max(nn))=equiv(tmp);
                        end
                    end
                end
            else
                cnt=cnt+1;
                cat(ind,knd)=cnt;
                equiv(cnt)=cnt;
                if length(pix_count)<cnt
                    pix_count(cnt)=1;
                else
                    pix_count(cnt)=pix_count(cnt)+1;
                end
            end
        end
    end
end


cats=unique(equiv);
for ind=1:numel(cats)
    if sum(pix_count(equiv==cats(ind)))<min_nbr_pix
        equiv(equiv==cats(ind))=0;
    end
end

for ind=1:size(img,1)
    for knd=1:size(img,2)
        if cat(ind,knd)>0
            cat(ind,knd)=equiv(cat(ind,knd));
        end
    end
end

labels=unique(cat(:));
for ind=1:numel(labels)
    cat(cat==labels(ind))=ind-1;
end

mask=zeros(size(cat));
mask(find(cat))=1;
mask=logical(mask);



