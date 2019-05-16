function [shifted,dx,dy]=SimMotion(orig,plot_output)
% this function simulates laser scanning motion artifacts
% input original image, output is shifted image and movement trajectory
% set plot_output = 1 to display output

% default is no visual output
if nargin<2
    plot_output=0;
end

% define trajectory parameters
a=50; %mass
b=5; %velocity damping
c=.0001; %harmonic force



image_size=size(orig);
n_pix=image_size(1)*image_size(2);


F_t=rand(n_pix,1);
F_t=find(F_t>0.95);
F_x=zeros(n_pix,1);
F_y=zeros(n_pix,1);
F_x(F_t)=1*randn(length(F_t),1);
F_y(F_t)=1*randn(length(F_t),1);

dl=zeros(2,n_pix);
dk=zeros(2,n_pix);

jacobian=[0 1; -c/a -b/a];

for ind=1:n_pix-1
    dl(:,ind+1)=dl(:,ind)+jacobian*dl(:,ind)+[0;F_x(ind)/a];
    dk(:,ind+1)=dk(:,ind)+jacobian*dk(:,ind)+[0;F_y(ind)/a];
end
dl=round(dl);
dk=round(dk);

shifted=zeros(size(orig,1),size(orig,2));

cnt=0;
for ind=1:image_size(1)
    for knd=1:image_size(2)
        cnt=cnt+1;
        shifted(ind,knd)=orig(max(min(ind+dl(1,cnt),image_size(1)),1),max(min(knd+dk(1,cnt),image_size(2)),1));
    end
end


% plot output if requested
if plot_output
    figure(1);
    clf
    plot(dl(1,:))
    hold on
    plot(dk(1,:),'r')
    
    figure(2);
    axes('position',[0 1/2 1 1/2])
    imagesc(shifted)
    axis off
    axes('position',[0 0 1 1/2])
    imagesc(orig)
    axis off
    colormap gray
end






