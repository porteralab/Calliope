function zstack=normZstack(zstack)
% normalize the frames of a z stack to median fluorescence and smooth a bit
% GK - 23.01.2014


% smoothed median brightness
mbr=smooth2(squeeze(median(median(zstack,1),2)),5);

for ind=1:size(zstack,3)
    zstack(:,:,ind)=zstack(:,:,ind)/mbr(ind);
end

    