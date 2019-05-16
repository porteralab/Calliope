% generate ICA tiffs of dendrites for ENU - GK 27.12.2014


expIDs = [2441 2443 2869 2883 2606 2613 2977 2984];


adata_dir=set_lab_paths;
ExpLog=getExpLog;

allICAs=[];
figure(111);

for knd=1:length(expIDs)
    knd
    load_exp(expIDs(knd),adata_dir,{'.bin'},ExpLog,'caller');
    mkdir('C:\ENU\',num2str(expIDs(knd)));
    
    for zl=1:4
        for ind=1:800
            avgdata(:,:,ind)=mean(data{zl}(:,:,1000+10*(ind-1)+1:1000+10*(ind)),3);
        end

        
        
        [PcaFilters PcaTraces] = runPCA(avgdata,100);
%         [PcaFilters, PcaTraces] = PCAchooser(PcaFilters,PcaTraces);
        [IcaFilters IcaTraces] = runICA(PcaFilters, PcaTraces, 100);
        
        allICAs(:,:,:,knd)=permute(IcaFilters,[2 3 1]);
        
        for ind=1:100
            clf;
            set(gca,'position',[0 0 1 1])
            imagesc(squeeze(IcaFilters(ind,:,:)));
%             title([num2str(ind) ' PRE']);
            colormap gray
            set(gca,'clim',[-0.005 0.05])
            axis off
            print(gcf,['C:\ENU\' num2str(expIDs(knd)) '\' num2str(expIDs(knd)) '-' num2str(zl) '-' num2str(ind) '.tif'],'-dtiff');
        end
    end
end








