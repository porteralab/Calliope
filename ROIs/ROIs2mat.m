function act_mat=ROIs2mat(ROIs)
%%%%%
% takes the activity traces of all ROIs in all layers and concatenates them
% into an array.

if iscell(ROIs)
    
    for layer_ind = 1:size(ROIs,2)
        n_cells(layer_ind)=size(ROIs{layer_ind},2);
    end
    act_mat=zeros(sum(n_cells),length(ROIs{1}(1).activity));
    n_cells = [0 n_cells];
    for layer_ind = 1:size(ROIs,2)
        act_mat(sum(n_cells(1:layer_ind))+1:sum(n_cells(1:layer_ind+1)),:) = ...
            [ROIs{layer_ind}.activity]';
    end
    
else
    act_mat=[ROIs.activity]';
end