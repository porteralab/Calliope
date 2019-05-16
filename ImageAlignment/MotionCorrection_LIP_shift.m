function [shifted]=MotionCorrection_LIP_shift(template,params,offset,n)
% this function piecewise linearly shifts the template according to the path
% specified by the params.
%
% template: template image of size l lines x k columns
% params: 2n+2 dimensional parameter vector
% offset: shift of the rawimage relative to the template

%interval length
lInterval=(length(params)-2)/2;


for ind=1:(size(template,1)-2*offset(1))
    for knd=1:(size(template,2)-2*offset(2))
        Iind=floor(((ind-1)*(size(template,1)-2*offset(1))+knd-1)/lInterval)+1;
        Icnt=mod(((ind-1)*(size(template,1)-2*offset(1))+knd)-1,lInterval)+1;

        Dx=min(max(round(params(Iind)+(params(Iind+1)-params(Iind))*Icnt/lInterval),-offset(1)),offset(1));
        Dy=min(max(round(params(Iind+n+1)+(params(Iind+n+1+1)-params(Iind+n+1))*Icnt/lInterval),-offset(2)),offset(2));
        
        shifted(ind,knd)=template((ind+offset(1)+Dx),(knd+offset(2)+Dy));
    end
end


