function OverlayImage(orig, template, dl, dk, offset)
% this function plots the overlay of an image on a template image to check
% for quality of alignment (dk and dl)
% orig: the original n by m image
% template: the s by t template image, s>=n, t>=m
% dk: matrix of n by m pixel k-displacements (k: row index) or vector of
% length n
% dl: matrix of n by m pixel l-displacements (l: scan line index) or vector
% of length n
% offset: offset between orig and template >=0, optional, if omitted it is
% assumed, that the image is centered on the template

prctile_color_scale_boundary=1;

% if dl and dk are vectors, create the corresponding matrix
if sum(size(dk)==1)
    if size(dk,1)>1
        dk=dk';
    end
    dk=dk'*ones(1,length(dk));
end
if sum(size(dl)==1)
    if size(dl,1)>1
        dl=dl';
    end
    dl=dl'*ones(1,length(dl));
end

if nargin<5
    offset(1)=(size(template,1)-size(orig,1))/2;
    offset(2)=(size(template,2)-size(orig,2))/2;
end

if length(offset)==1
    offset=[offset offset];
end

max_shift=max(max(max(abs(dk))),max(max(abs(dl))));
shift_offset=offset;

if sum(max_shift>offset)
    shift_offset(:)=max_shift;
end


shifted_image=zeros(size(orig,1)+2*shift_offset(1),size(orig,2)+2*shift_offset(2));

for n=1:size(orig,1)
    for m=1:size(orig,2)
        shifted_image(n+dl(n,m)+shift_offset(1),m+dk(n,m)+shift_offset(2))=orig(n,m);
    end
end

min_scale=prctile(reshape(template,size(template,1)*size(template,2),1),prctile_color_scale_boundary);
max_scale=prctile(reshape(template,size(template,1)*size(template,2),1),100-prctile_color_scale_boundary);

%fill the color map matrix with template and shifted image scaled to the
%interval [0 1]
Cdat=zeros(size(shifted_image,1),size(shifted_image,2),3);
Cdat((size(shifted_image,1)-size(template,1))/2+1:end-(size(shifted_image,1)-size(template,1))/2,(size(shifted_image,2)-size(template,2))/2+1:end-(size(shifted_image,2)-size(template,2))/2,1)=(template-min_scale)/(max_scale-min_scale);
Cdat(:,:,2)=(shifted_image-min_scale)/(max_scale-min_scale);
Cdat(Cdat>1)=1;
Cdat(Cdat<0)=0;

figure;
axes('position',[1/3 0 2/3 1])
image(Cdat)
axis off
text(10,10,'Overlay','color','w','fontsize',10,'fontweight','bold');

axes('position',[0 0 1/3 1/2])
Tdat=Cdat;
Tdat(:,:,2)=0;
image(Tdat)
axis off
text(20,20,'Template','color','w','fontsize',10,'fontweight','bold');

axes('position',[0 1/2 1/3 1/2])
Odat=Cdat;
Odat(:,:,1)=0;
image(Odat)
axis off
text(20,20,'Corrected image','color','w','fontsize',10,'fontweight','bold');


Cdat=zeros(size(template,1),size(template,2),3);
Cdat(:,:,1)=(template-min_scale)/(max_scale-min_scale);
Cdat(offset(1)+1:end-offset(1),offset(2)+1:end-offset(2),2)=(orig-min_scale)/(max_scale-min_scale);
Cdat(Cdat>1)=1;
Cdat(Cdat<0)=0;

figure;
axes('position',[1/3 0 2/3 1])
image(Cdat)
axis off
text(10,10,'Overlay','color','w','fontsize',10,'fontweight','bold');

axes('position',[0 0 1/3 1/2])
Tdat=Cdat;
Tdat(:,:,2)=0;
image(Tdat)
axis off
text(20,20,'Template','color','w','fontsize',10,'fontweight','bold');

axes('position',[0 1/2 1/3 1/2])
Odat=Cdat;
Odat(:,:,1)=0;
image(Odat)
axis off
text(20,20,'Original image','color','w','fontsize',10,'fontweight','bold');

















