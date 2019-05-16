function roi_overlap(proj_meta)
ini=LFMini;
RO=struct;
for dnd=1:length(proj_meta)
    cur_site=dnd;
    display(['******** now evaluating site ' num2str(cur_site) ' ********'])
    all_temp=[];
    for ynd=1:4
        cur_temp=zeros(400,750);
        cur_info=proj_meta(cur_site).rd(ynd,1).ROIinfo;
        for znd=1:size(cur_info,2)
            cur_temp(cur_info(znd).indices)=1;
        end
        all_temp(:,:,ynd)=cur_temp;
    end
    centroids={};
    for ynd=1:4
        s=regionprops(logical(all_temp(:,:,ynd)), 'centroid');
        centroids{ynd}=cat(1, s.Centroid);
    end
    all_sizes=[];
    for ynd=1:4
        cur_info=proj_meta(cur_site).rd(ynd,1).ROIinfo;
        all_sizes(ynd,1)=size(cur_info,2);
        for vnd=1:size(centroids{ynd},1)
            cur_centroid=(round(centroids{ynd}(vnd,1))*400)+round(centroids{ynd}(vnd,2));
            qqq=[];
            for znd=1:size(cur_info,2)
                cur_roi=cur_info(znd).indices;
                qqq(znd)=min(abs(cur_centroid-cur_roi));
            end
            [~,centroids{ynd}(vnd,3)]=min(qqq);
        end
        if length(unique(centroids{ynd}(:,3)))~=length(centroids{ynd}(:,3))
            display('too many centroids detected - probably due to detached ROIs. Correcting!')
            [a,b]=hist(centroids{ynd}(:,3),unique(centroids{ynd}(:,3)));
            centroid_dbl=b(a>1);
            for snd=1:length(centroid_dbl)
                cur_dbl_ind=find(centroids{ynd}(:,3)==centroid_dbl(snd));
                cur_dbl=centroids{ynd}(cur_dbl_ind,:);
                corr_dbl=mean(cur_dbl);
                centroids{ynd}(cur_dbl_ind(1),:)=corr_dbl;
                centroids{ynd}(cur_dbl_ind(2:end),:)=[];
            end
        end
        all_sizes(ynd,2)=size(centroids{ynd},1);
    end
    if sum(diff(all_sizes,[],2))<0
        error('correction failed - not enough centroids')
    elseif sum(diff(all_sizes,[],2))>0
        error('correction failed - too many centroids')
    end
    distance_dist={};
    for ynd=1:3
        cnt=1;
        for znd=1:size(centroids{ynd},1)
            for pnd=1:size(centroids{ynd+1},1)
                distance_dist{ynd}(cnt,:)=[sqrt(((centroids{ynd}(znd,1)-centroids{ynd+1}(pnd,1))^2)+((centroids{ynd}(znd,2)-centroids{ynd+1}(pnd,2))^2))...
                    centroids{ynd}(znd,3) ynd centroids{ynd+1}(pnd,3) ynd+1];
                cnt=cnt+1;
            end
        end
    end
    roi_size_dist=[];
    for ynd=1:size(proj_meta(cur_site).rd,1)
        cur_temp=zeros(400,750);
        cur_info=proj_meta(cur_site).rd(ynd,1).ROIinfo;
        for znd=1:size(cur_info,2)
            cur_temp(cur_info(znd).indices)=1;
        end
        cur_temp=logical(cur_temp);
        a=regionprops(cur_temp, 'area');
        cur_area = cat(1, a.Area);
        roi_size_dist(end+1:end+size(cur_area,1))=cur_area;
    end
    max_radius=round(max(sqrt(roi_size_dist/pi)));
    put_overlap=[];
    for ynd=1:3
        put_overlap(end+1:end+sum(distance_dist{ynd}(:,1)<=max_radius),:)=distance_dist{ynd}(distance_dist{ynd}(:,1)<=max_radius,2:end);
    end
    temp_overlap=put_overlap;
    new_res={};
    res_cnt=1;
    stop=0;
    while stop==0
        cur_roi=[];
        snd_roi=[];
        thr_roi=[];
        cur_ids=[];
        snd_ids=[];
        thr_ids=[];
        back_snd_ids=[];
        back_thr_ids=[];
        cur_roi=temp_overlap(1,1:2);
        cur_ids=find(temp_overlap(:,1)==cur_roi(1)&temp_overlap(:,2)==cur_roi(2));
        for hnd=1:length(cur_ids)
            snd_roi(hnd,:)=temp_overlap(cur_ids(hnd),3:4);
        end
        snd_ids=find(ismember(temp_overlap(:,1:2),snd_roi,'rows'));
        for hnd=1:length(snd_ids)
            thr_roi(hnd,:)=temp_overlap(snd_ids(hnd),3:4);
        end
        if ~isempty(thr_roi)
            thr_ids=find(ismember(temp_overlap(:,1:2),thr_roi,'rows'));
        end
        to_check_ids=[cur_ids;snd_ids;thr_ids];
        cur_cells=temp_overlap(to_check_ids,:);
        cur_cells=[cur_cells(:,1:2);cur_cells(:,3:4)];
        all_ids=[find(ismember(temp_overlap(:,1:2),cur_cells,'rows'));find(ismember(temp_overlap(:,3:4),cur_cells,'rows'))];
        all_ids=unique(all_ids);
        new_res{res_cnt}=temp_overlap(all_ids,:);
        res_cnt=res_cnt+1;
        temp_overlap(all_ids,:)=[];
        if isempty(temp_overlap)
            stop=1;
        end
    end
    cols='rgcmbk';
    cells_to_keep=[];
    cnt=1;
    for ond=1:size(new_res,2)
        figure(1);
        set(gcf,'pos',[1620         460        1523         325])
        clf
        cur_cells=new_res{ond};
        cur_cells=[cur_cells(:,1:2);cur_cells(:,3:4)];
        cur_cells=unique(cur_cells,'rows');
        [~,b]=sort(cur_cells(:,2));
        cur_cells=cur_cells(b,:);
        hold on
        title_str=char;
        for ynd=1:size(cur_cells,1)
            plot(proj_meta(cur_site).rd(cur_cells(ynd,2),1).act(cur_cells(ynd,1),:)-(ynd*2),'col',cols(ynd))
            cur_str=[num2str(cur_cells(ynd,1)) ' ' num2str(cur_cells(ynd,2))];
            title_str(ynd,1:length(cur_str))=cur_str;
        end
        legend(title_str)
        
        figure(2);
        set(gcf,'pos',[3155        -156         373         954])
        clf
        for ynd=1:size(cur_cells,1)
            subplot(size(cur_cells,1),1,ynd)
            params.ta_win=50;
            ts=size(proj_meta(cur_site).rd(cur_cells(ynd,2),1).template);
            [cx,cy]=ind2sub(ts,proj_meta(cur_site).rd(cur_cells(ynd,2),1).ROIinfo(cur_cells(ynd,1)).indices);
            cx=round(mean(cx));
            cy=round(mean(cy));
            tmp_im=zeros(2*params.ta_win+1);
            tmp_im(2-min(1,cx-params.ta_win):2*params.ta_win+1+min(0,ts(1)-(cx+params.ta_win)), ...
                2-min(1,cy-params.ta_win):2*params.ta_win+1+min(0,ts(2)-(cy+params.ta_win)))= ...
                proj_meta(cur_site).rd(cur_cells(ynd,2),1).template(max(1,cx-params.ta_win):min(ts(1),cx+params.ta_win), ...
                max(1,cy-params.ta_win):min(ts(2),cy+params.ta_win));
            imagesc(tmp_im)
            colormap gray
            axis off
        end
        cell_ids=input('which cells to keep (0 for both)? ');
        if cell_ids==0
            cells_to_keep(cnt:cnt+size(cur_cells,1)-1,:)=cur_cells;
            cnt=cnt+size(cur_cells,2);
        else
            for znd=1:length(cell_ids)
                cells_to_keep(cnt,:)=cur_cells(cell_ids(znd),:);
                cnt=cnt+1;
            end
        end
    end
    put_del=[put_overlap(:,1:2);put_overlap(:,3:4)];
    put_del=unique(put_del,'rows');
    put_del(ismember(put_del,cells_to_keep,'rows'),:)=[];
    cells_to_del={};
    for ond=1:4
        cells_to_del{ond}=put_del(put_del(:,2)==ond,1)';
    end
    RO.(['siteID_' num2str(dnd)])=cells_to_del;
end
display(['saving roi overlap matrix in ' ini.roi_overlap_path])
save([ini.roi_overlap_path proj_meta(1).projID '_roi_overlap.mat'],'RO');

