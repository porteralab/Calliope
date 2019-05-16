function exportMeanToTiff(expIDs)

if exist('D:\tempData\','file') == 7
    tmp_dir='D:\tempData\';
else
    tmp_dir='E:\tempData\';
end

cnt=0;
for ind=expIDs
    cnt=cnt+1;
    
    fnameCh1=['S1-T' num2str(ind) '_ch610.bin'];
    fnameCh2=['S1-T' num2str(ind) '_ch525.bin'];
    
    data=load_bin([tmp_dir fnameCh1]);
    
    for jnd=1:4
        im=mean(data(:,:,jnd+8:4:end),3);
        imwrite(uint16(im), ['D:\tempExport\610_L' num2str(jnd) '_Exp' num2str(ind) '.tif'],'tif');
    end
    
    data=load_bin([tmp_dir fnameCh2]);
    
    for jnd=1:4
        im=mean(data(:,:,jnd+8:4:end),3);
        imwrite(uint16(im), ['D:\tempExport\525_L' num2str(jnd) '_Exp' num2str(ind) '.tif'],'tif');
    end
    
end
