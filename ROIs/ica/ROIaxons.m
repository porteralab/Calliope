
ExpLog = getExpLog;
adata_dir=set_lab_paths;
% stacks=[61452 61512 61660 61701 61786 61706 61791 61464 61518 61600 ...
%     61711 61676 61680 61495 61530 61685 61800 61725]

% stacks=[61786 61669 61719 61722 61795 61460 61552 61527 61613]
stacks=[61504 61505 61508 61874 62137 62140 62144 62147];

for knd=1:length(stacks)
    try
        clear data;
        ExpID=stacks(knd);
        load_exp(ExpID,adata_dir,'525.bin',ExpLog,'base');
        
        % save_adata(adata_dir,ROIs,bv,np,template,dx,dy,aux_files,fnames,nbr_frames,mouse_id,userID,act_map)
        
        for layer = 1:4
            
            avgdata = avgStack(data{layer}, 10, [dx{layer}, dy{layer}]);
            
            [mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
                movtm] = CellsortPCA(avgdata, [], 100, [], [], []);
            %  [PCuse] = CellsortChoosePCs(mixedfilters);
            
            PCuse = 1:20;
            [ica_sig, ica_filters, ica_A, numiter] = ...
                CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, 0.7, [], [], [], []);
            
            [L] = ...
                CellsortSegmentation_axon(ica_filters, 0, 1.5, [20 10000], 0);
            
            clear tempROIs
            tempROIs.indices = [];
            % tempROIs.Centroid = [];
            segments = permute(L,[2 3 1]);
            for ind = 1:size(segments,3)
                temp = regionprops(segments(:,:,ind) > 0 , 'Area', 'PixelIdxList');
                tempROIs(ind).indices = cell2mat({temp.PixelIdxList}');
            end
            % ROIs_ICA = ROI_activity(data{layer},tempROIs);
            
            tempROIs = struct;
            count = 1;
            segments = permute(L,[2 3 1]);
            for ind = 1:size(segments,3)
                temp = regionprops(segments(:,:,ind) > 0 , 'Area', 'PixelIdxList');
                for jnd=1:size(temp,1)
                    if temp(jnd).Area > 40
                        tempROIs(count).indices = temp(jnd).PixelIdxList;
                        tempROIs(count).Area = temp(jnd).Area;
                        tempROIs(count).ica = ind;
                        count = count + 1;
                    end
                end
            end
            ROIs_ICA_single = ROI_activity(data{layer},tempROIs);
            
            % % % %kmeans
            % % % matrix_ROIs = zeros(15000,length(ROIs_ICA_single));
            % % % for ind = 1:length(ROIs_ICA_single)
            % % %     matrix_ROIs(:,ind) = ROIs_ICA_single(ind).activity;
            % % % end
            % % % idx = kmeans(matrix_ROIs',100);
            % % % for ind=1:length(ROIs_ICA_single),ROIs_ICA_single(ind).kmeans = idx(ind);end;
            smooth_it = 5;
            corr_result = zeros(length(ROIs_ICA_single));
            if smooth_it > 0
                
                for ind = 1:length(ROIs_ICA_single)
                    for jnd = ind + 1:length(ROIs_ICA_single)
                        corr_result(ind,jnd) = corr2(smooth2([ROIs_ICA_single(ind).activity]',smooth_it),smooth2([ROIs_ICA_single(jnd).activity]',smooth_it));
                    end
                end
            else
                for ind = 1:length(ROIs_ICA_single)
                    for jnd = ind + 1:length(ROIs_ICA_single)
                        corr_result(ind,jnd) = corr2(ROIs_ICA_single(ind).activity,ROIs_ICA_single(jnd).activity);
                    end
                end
            end
            
            
            % combine ROIs based on correlation
            ROIs_ICA_single_comb = struct;
            processed = 0;
            count = 1;
            for ind = 1:length(ROIs_ICA_single)
                if ~ismember(processed,ind)
                    match = [find(corr_result(ind,:) > 0.6) find(corr_result(:,ind) > 0.6)'];
                    if ~isempty(match)
                        processed = [processed match];
                        ROIs_ICA_single_comb(count).indices = unique(cell2mat({ROIs_ICA_single([ind match]).indices}'));
                    else
                        ROIs_ICA_single_comb(count).indices = ROIs_ICA_single(ind).indices;
                    end
                    count = count + 1;
                end
            end
            ROIs_ICA_single_comb = ROI_activity(data{layer},ROIs_ICA_single_comb);
            
            ROIs{layer} = ROIs_ICA_single_comb;
        end
        
        %     act_map={};
        %     template={};
        %     for rnd=1:length(dx)
        %
        % act_map{rnd}=calc_act_map(data{rnd});
        % template{rnd}=mean(data{rnd},3);
        % end
        %
%         for qnd=1:length(ROIs)
%             ROIs_act=ROI_activity(data{qnd},ROIs{qnd});
%             ROIs{qnd}=ROIs_act;
%         end
        
        save_adata(adata_dir,ROIs,bv,np,template,dx,dy,aux_files,fnames,nbr_frames,mouse_id,userID,act_map,[],[])
    catch
        disp(['error occured: ' num2str(stacks(knd))])
    end
end
% ind=1
% ROIs2image(ROIs{ind},size(template{ind}),'display',1);
% ROIs2image(ROIs{ind},size(template{ind}),'template',template{ind},'display',1);
% ROIs2image(ROIs{ind},size(template{ind}),'template',template{ind},'display',1,'singlecolor',[1 0 0]);
