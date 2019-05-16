function [mean1,cov1] = fit2Dgaussian(X,factors,handle,color,plotpoints)
%fit2Dgaussian fits a 2D gaussian to your Data
%   it will plot your data into a new figure and overlay ellipses of the
%   fitted gaussian at .5std, 1std and 2stds
%   Data needs to be a [nx2] with n observations, first row is x axis,
%   second row is y axis.
%   
if nargin ==1
    factors =[.5 1 2];
    handle=axes();
    color='b';
    plotpoints=true;

elseif nargin ==2
    handle=axes();
    color='b';
    plotpoints=true;
elseif nargin ==3
    color='b';
    plotpoints=true;
elseif nargin == 4
    plotpoints=true;
end

h=handle;

XLIM=[min(X(:,1)) max(X(:,2))];
YLIM=[min(X(:,2)) max(X(:,2))];
mean1=nanmean(X,1)';
cov1=nancov(X);

[x, y]=meshgrid(linspace(XLIM(1),XLIM(2),50),linspace(YLIM(1),YLIM(2),50));
x1=[x(:) y(:)]';
%%%multivar Gassiaan
mn=repmat(mean1,1,size(x1,2));
mulGau= 1/(2*pi*det(cov1)^(1/2))*exp(-0.5.*(x1-mn)'*inv(cov1)*(x1-mn));
G=reshape(diag(mulGau),50,50);
%figure
%mesh(x,y,G)
%contour(x,y,G)


hold on
if plotpoints
plot(X(:,1),X(:,2),'.','Color',color,'MarkerSize',4)
end
for f = factors
drawSTD(h,mean1,cov1,f,color)
end


end

function drawSTD(h,mean1,cov1,mf,color)
axes(h);
tt=linspace(0,2*pi,100)';
x = cos(tt); y=sin(tt);
ap = [x(:) y(:)]';
[v,d]=eig(cov1); 
d = mf * sqrt(d); % convert variance to sdwidth*sd
bp = (v*d*ap) + repmat(mean1, 1, size(ap,2)); 
hold on
plot(bp(1,:), bp(2,:),'-','Color', color,'LineWidth',2)
end