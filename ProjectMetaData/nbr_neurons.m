function non=nbr_neurons(proj_meta,siteID,tp)
% returns the total number of neurons in one site
% GK 10.09.2018

if nargin<3
    
    for tp=1:size(proj_meta(siteID).rd,2)
        for ind=1:size(proj_meta(siteID).rd,1)
            ncells(ind,tp)=size(proj_meta(siteID).rd(ind,tp).act,1);
        end
    end
    
    
    
    if min(sum(ncells))==max(sum(ncells))
        non=max(sum(ncells));
    else
        disp('Warning! Number of neurons not constant across time points!')
        disp(['Site nbr: ' num2str(siteID)])
        disp(num2str(sum(ncells)))
        disp('Proceed with caution')
        non=median(sum(ncells));
    end
    
else
    for ind=1:size(proj_meta(siteID).rd,1)
        ncells(ind)=size(proj_meta(siteID).rd(ind,tp).act,1);
    end
    non=sum(ncells);
end



