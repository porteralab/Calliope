fig_rep='C:\temp\zmarpawe\canc\';
frame_avg=20;
num_img=size(data,3)/(4*frame_avg);
cnt=0;
for gnd=1:num_img
    cur_img=mean(data(:,:,cnt+1:4:cnt+(4*frame_avg)),3);
    cur_img=cur_img./max(cur_img(:));
    cnt=cnt+(4*frame_avg);
    imwrite(cur_img,[fig_rep num2str(gnd) '.tiff'])
end

