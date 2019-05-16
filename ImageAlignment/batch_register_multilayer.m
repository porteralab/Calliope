function batch_register_multilayer
% Loads BIN files and register the data,then try to save the tiff stacks.
reg_dir = uigetdir;

files=dir(reg_dir);

for ind=3:length(files)
    if strcmp(files(ind).name(end-3:end),'.bin')
        data=load_bin([reg_dir '\' files(ind).name]);
        mean_data=register_multilayer(data,100);
        try 
            save_tiff_stack(mean_data,[files(ind).name(1:8) '_mean_data.tif']);
        catch
            try
                save_tiff_stack(mean_data,[files(ind).name(1:8) '_mean_data.tif']);
            catch
                disp(['Could not save ' files(ind).name(1:8)])
            end
        end
    end
end

