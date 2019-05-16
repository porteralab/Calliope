
zl=1;

for zl=1:4
figure;
img(:,:,1)=act_map{zl}/max(act_map{zl}(:))*255*2;
img(:,:,2)=template{zl}/max(template{zl}(:))*255;
img(:,:,3)=zeros(size(act_map{zl}));
img=uint8(img);
imagesc(img)
end




colormap gray

figure;
imagesc(template{zl})
colormap gray



[a,b,c]=ind2sub(size(data),params.marks(ind));


for ind=1:size(md,3);
    md(:,:,ind)=md(:,:,ind)/mean(mean(md(:,:,ind)));
end