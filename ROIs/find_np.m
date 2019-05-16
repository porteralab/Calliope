function [np]=find_np(template,ROIs,bv,z_plane)
% calculates indices of neuropil (np), i.e. everything that is not blood
% vessel (bv) or ROI

tmp_mask=ones(size(template,1)*size(template,2),1);

for ind=1:length(ROIs)
    tmp_mask(ROIs(ind).indices)=0;
end
tmp_mask(bv.indices)=0;

np.indices=find(tmp_mask);

    