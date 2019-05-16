function []=save_ROIs_df(adata_dir,ROIs,ROItrans,fnames,mouse_id,userID,ExpGroup,template,z_plane)

%ca;
drawnow;
warning('off','MATLAB:load:variableNotFound')

ExpLog = getExpLog;

% append causes strange .mat file size increases in certain matlab versions
% this seems to be a matlab bug/feature...

%these lines are an ugly hack to cope with the new dynamic path management
%AA 4.6.14
temp = strsplit(fnames{1},'\');
fn = temp{end};
fnames{1}=fn; %only fnames{}
fn = fn(1:strfind(fn,'_')-1);
fname=[adata_dir userID '\' mouse_id '\Adata-' fn];

disp(['Now saving ' fname])

curr_file_struct=load(fname);
curr_file_struct.ROIs=ROIs;
curr_file_struct.ROItrans=ROItrans;
save(fname,'-struct','curr_file_struct','-v7.3');

save_all=0;
type_deviation=0;
if iscell(template)
    win_size=round(min(size(template{z_plane}))/20);
else
    win_size=round(min(size(template))/20);
end

if ExpGroup(1)~=str2num(fnames{1}(5:strfind(fnames{1},'_')-1))
    [main_adata_file]=get_adata_filename(ExpGroup(1),adata_dir,ExpLog);
    main=load([adata_dir userID '\' mouse_id '\' main_adata_file]);
    
    local_average = filter2(ones(win_size)/win_size^2,main.template{z_plane});
    ot_fil = main.template{z_plane}./local_average;
    
    nbr_main_ROIs=length(main.ROIs{z_plane});
    ROIs_in_main_coord=ROIs{z_plane};
    for ind=1:length(ROIs{z_plane})
        ROIs_in_main_coord(ind).indices=ROIs_in_main_coord(ind).indices-(ROItrans{z_plane}(1)+ROIs{z_plane}(ind).shift(1))-(ROItrans{z_plane}(2)+ROIs{z_plane}(ind).shift(2))*size(template{z_plane},1);
    end
    
    if length(ROIs_in_main_coord)<length(main.ROIs{z_plane})
        disp('WARNING - ROIs were deleted!')
    else
        for ind=1:length(main.ROIs{z_plane})
            % require 70% overlap
            prc_ovlp=length(intersect(main.ROIs{z_plane}(ind).indices,ROIs_in_main_coord(ind).indices))/length(ROIs_in_main_coord(ind).indices);
            if 0.5<prc_ovlp & prc_ovlp<1.5
            else
                disp(['Warning - ROI nbr ' num2str(ind) ' does not meet min overlap criteria']);
            end
            if ROIs_in_main_coord(ind).type~=main.ROIs{z_plane}(ind).type
                disp(['Warning - ROI nbr ' num2str(ind) ' has a type deviation']);
                type_deviation=1;
            end
        end
        if length(ROIs_in_main_coord)==length(main.ROIs{z_plane})
            disp('No ROIs added - checking correspondence of ROIs')

        elseif length(ROIs_in_main_coord)>length(main.ROIs{z_plane})
            disp('New ROIs added - checking correspondence of old ROIs');
            save_all=1;
        end
        
        if type_deviation
            type_deviation=input('Do you want to continue changing types to the currently selected ones? (0/1): ');
            save_all=1;
        end
        
    end
    
    if save_all==1
        
        for ind=1:length(main.ROIs{z_plane})
            % require 70% overlap
            prc_ovlp=length(intersect(main.ROIs{z_plane}(ind).indices,ROIs_in_main_coord(ind).indices))/length(ROIs_in_main_coord(ind).indices);
            if 0.5<prc_ovlp & prc_ovlp<1.5
            else
                disp(['Warning - ROIs nbr ' num2str(ind) ' does not meet min overlap criteria']);
            end
        end
        
        go_on=1;%input(['Do you want to add these new ROIs to all other Exps of the same ExpGroup? ']);
        if go_on
            if  isfield(main.ROIs{z_plane},'activity')
                main.ROIs{z_plane}=rmfield(main.ROIs{z_plane},'activity');
            end
            if ~isfield(main.ROIs{z_plane},'shift')
                main.ROIs{z_plane}(1).shift=[0 0];
            end
            local_average = filter2(ones(win_size)/win_size^2,template{z_plane});
            t_fil = template{z_plane}./local_average;
            
            [dxf,dyf,dxF,dyF]=fine_ROI_matching(ROIs{z_plane},t_fil,ot_fil);
            
            curr_roi_inds=length(main.ROIs{z_plane})+1:length(ROIs_in_main_coord);
            
            if type_deviation
                for ind=1:length(main.ROIs{z_plane})
                    main.ROIs{z_plane}(ind).type=ROIs{z_plane}(ind).type;
                end
            else
                
                for ind=curr_roi_inds
                    main.ROIs{z_plane}(ind)=ROIs_in_main_coord(ind);
                    main.ROIs{z_plane}(ind).indices=ROIs{z_plane}(ind).indices-(ROItrans{z_plane}(1)+dxf(ind))-(ROItrans{z_plane}(2)+dyf(ind))*size(template{z_plane},1);
                    main.ROIs{z_plane}(ind).shift=[-dxf(ind) -dyf(ind)];
                    main.ROIs{z_plane}(ind).type=ROIs{z_plane}(ind).type;
                end
                tmp_t=overlay_ROIs_on_image(t_fil,ROIs{z_plane}(curr_roi_inds));
                tmp_ot=overlay_ROIs_on_image(ot_fil,main.ROIs{z_plane}(curr_roi_inds));
                figure('position',[50 50 1800 940]);imagesc([tmp_t tmp_ot]);axis off;
                title(['Left: current Right: original']);
                drawnow;
            end
            fname=[adata_dir userID '\' mouse_id '\' main_adata_file];
            disp(['Now saving ' fname])
            save(fname,'-struct','main','-v7.3');
            
            other_expIDs=setdiff(ExpGroup(2:end),str2num(fnames{1}(5:strfind(fnames{1},'_')-1)));
            other_expIDs = other_expIDs(:)'; % make sure its a row vectors
            
            for knd=other_expIDs
                [curr_adata_file]=get_adata_filename(knd,adata_dir,ExpLog);
                if ~isempty(curr_adata_file)
                    if ~strcmp(curr_adata_file(1:4),'mean')
                        fname=[adata_dir userID '\' mouse_id '\' curr_adata_file];
                        curr=load(fname);
                        
                        if  isfield(curr.ROIs{z_plane},'activity')
                            curr.ROIs{z_plane}=rmfield(curr.ROIs{z_plane},'activity');
                        end
                        
                        if length(curr.ROIs{z_plane})==nbr_main_ROIs
                            local_average = filter2(ones(win_size)/win_size^2,curr.template{z_plane});
                            t_fil = curr.template{z_plane}./local_average;
                            
                            [dxf,dyf,dxF,dyF]=fine_ROI_matching(ROIs_in_main_coord,t_fil,ot_fil);
                            
                            %                         if curr.ROItrans{pl}(1)~=dxF || curr.ROItrans{pl}(2)~=dyF
                            %                             disp('WARNING ROItrans seems outdated');
                            %                         end
                            ROIs_in_curr_coord=main.ROIs{z_plane};
                            for ind=1:length(ROIs_in_curr_coord)
%                                 ROIs_in_curr_coord(ind).indices=ROIs_in_curr_coord(ind).indices+(curr.ROItrans{z_plane}(1)+dxf(ind))+(curr.ROItrans{z_plane}(2)+dyf(ind))*size(template{z_plane},1);
                                newROIindices=ROIs_in_curr_coord(ind).indices+(curr.ROItrans{z_plane}(1)+dxf(ind))+(curr.ROItrans{z_plane}(2)+dyf(ind))*size(template{z_plane},1);
                                if min(newROIindices)<1
                                    display(['WARNING: ROI ' num2str(ind) ' could not be matched in Exp ' num2str(knd) ' - match manually'])
                                else
                                    ROIs_in_curr_coord(ind).indices=newROIindices;
                                end
                            end
                            
                            curr_roi_inds=length(curr.ROIs{z_plane})+1:length(ROIs_in_curr_coord);
                            
                            if type_deviation
                                for ind=1:length(curr.ROIs{z_plane})
                                    curr.ROIs{z_plane}(ind).type=ROIs{z_plane}(ind).type;
                                end
                            else
                                
                                for ind=curr_roi_inds
                                    curr.ROIs{z_plane}(ind)=ROIs_in_curr_coord(ind);
                                    curr.ROIs{z_plane}(ind).shift=[dxf(ind) dyf(ind)];
                                end
                                tmp_t=overlay_ROIs_on_image(t_fil,curr.ROIs{z_plane}(curr_roi_inds));
                                tmp_ot=overlay_ROIs_on_image(ot_fil,main.ROIs{z_plane}(curr_roi_inds));
                                figure('position',[50 50 1800 940]);imagesc([tmp_t tmp_ot]);axis off;
                                title(['Left: ExpID ' num2str(knd) ' Right: original']);
                                drawnow;
                            end
                            disp(['Now saving ' fname])
                            save(fname,'-struct','curr','-v7.3');
                        else
                            disp(['Exp ' num2str(knd) ' has probably not been analyzed yet']);
                        end
                    end
                else
                    disp(['Exp ' num2str(knd) ' is probably a z stack']);
                end
            end
            
        end
    end
end
disp('--- Done saving ROIs ---');