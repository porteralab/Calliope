function overlay_RGB(imR,imG);

imR=ntzo(imR);
imG=ntzo(imG);

im(:,:,1)=imR;
im(:,:,2)=imG;
im(:,:,3)=0;

figure('menubar','none');
axes('position',[0 0 1 1])
imagesc(im);
axis off