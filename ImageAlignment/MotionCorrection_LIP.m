function [dl,dk,params]=MotionCorrection_LIP(rawimage,template,offset)
%this is an implementation of the greenberg&kerr linear interpolation
%algorithm for movment artifact correction

%default image boundary in px
im_bound=10;

%if rawimage is of the same size as the template, artificially reduce the
%rawimage
rawimage=rawimage(im_bound+1:end-im_bound,im_bound+1:end-im_bound);

%if offset is omitted, assume, that the rawimage is centerd on the template
if nargin<3
    offset=(size(template)-size(rawimage))/2;
    if sum(rem(offset,1)>0)
        disp('please specify offset, it cannot be determined unambiguously')
        return
    end
end

%number of discreet line segments
n=size(rawimage,1);

%length of the interval in px
lInterval=size(rawimage,1)*size(rawimage,2)/n;

%initialize the path parameters
params=zeros(2*n+2,1);

% iterate until convergence
for loop_count=1:5
    TD=MotionCorrection_LIP_shift(template,params,offset,n);
    dTx=([diff(TD); zeros(size(TD,2),1)']+[zeros(size(TD,2),1)'; diff(TD)])/2;
    dTy=([diff(TD')' zeros(size(TD,1),1)]+[zeros(size(TD,1),1) diff(TD')'])/2;

    H=zeros(2*n+2);
    M=zeros(2*n+2,1);


    for ind=1:size(rawimage,1)

        
        for knd=1:size(rawimage,2)

            Iind=floor(((ind-1)*size(rawimage,1)+knd-1)/lInterval)+1;
            Icnt=mod(((ind-1)*(size(template,1)-2*offset(1))+knd)-1,lInterval)+1;

            Ev=[dTx(ind,knd)*Icnt/lInterval; dTx(ind,knd)*(1-Icnt/lInterval); dTy(ind,knd)*Icnt/lInterval; dTy(ind,knd)*(1-Icnt/lInterval)];

            ind_vec=[Iind Iind+1 n+Iind+1 n+Iind+2];
            H(ind_vec,ind_vec)=H(ind_vec,ind_vec) + Ev*Ev';
            M(ind_vec)=M(ind_vec)+(rawimage(ind,knd)-TD(ind,knd))*Ev;

        end
        
    end
    eps=1;
    params=params+eps*(inv(H)*M);
    

figure;
plot(params)
    drawnow
    
end

%reconstruct the path dl and dk from the params

for ind=1:(size(template,1)-2*offset(1))
    for knd=1:(size(template,2)-2*offset(2))
        Iind=floor(((ind-1)*(size(template,1)-2*offset(1))+knd-1)/lInterval)+1;
        Icnt=mod(((ind-1)*(size(template,1)-2*offset(1))+knd),lInterval);
        
        dl(ind,knd)=round(params(Iind)+(params(Iind+1)-params(Iind))*Icnt/lInterval);
        dk(ind,knd)=round(params(Iind+n)+(params(Iind+n+1+1)-params(Iind+n+1))*Icnt/lInterval);

    end
end





figure;
plot(params)
    
