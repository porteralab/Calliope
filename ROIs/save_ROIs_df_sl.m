function []=save_ROIs_df_sl(adata_dir,ROIs,ROItrans,fnames,mouse_id,userID,ExpGroup,template,act_map)

%ca;
drawnow;
warning('off','MATLAB:load:variableNotFound')

fname=[adata_dir userID '\' mouse_id '\Adata-S1-T' fnames{1}(strfind(fnames{1},'S1-T')+4:strfind(fnames{1},'S1-T')+8)]
disp(['Now saving ' fname])
save(fname,'ROIs','ROItrans','template','act_map','fnames','-append');


win_size=round(min(size(template))/20);

if ExpGroup(1)~=str2num(fnames{1}(5:strfind(fnames{1},'_')-1))
    [main_adata_file]=find_adata_file(ExpGroup(1),adata_dir);
    main=load([adata_dir userID '\' mouse_id '\' main_adata_file],'ROIs','ROItrans','template');
    
    local_average = filter2(ones(win_size)/win_size^2,main.template);
    ot_fil = main.template./local_average;
       
    nbr_main_ROIs=length(main.ROIs);
    ROIs_in_main_coord=ROIs;
    for ind=1:length(ROIs)
        ROIs_in_main_coord(ind).indices=ROIs_in_main_coord(ind).indices-(ROItrans(1)+ROIs(ind).shift(1))-(ROItrans(2)+ROIs(ind).shift(2))*size(template,1);
    end
    
    if length(ROIs_in_main_coord)<length(main.ROIs)
        disp('WARNING - ROIs were deleted!')
        
    elseif length(ROIs_in_main_coord)==length(main.ROIs)
        disp('No ROIs added - checking correspondence of ROIs')
        for ind=1:length(ROIs_in_main_coord)
            % require 70% overlap
            prc_ovlp=length(intersect(main.ROIs(ind).indices,ROIs_in_main_coord(ind).indices))/length(ROIs_in_main_coord(ind).indices);
            if 0.5<prc_ovlp & prc_ovlp<1.5
            else
                disp(['Warning - ROIs nbr ' num2str(ind) ' does not meet min overlap criteria']);
            end
        end
    else
        disp('New ROIs added - checking correspondence of old ROIs')
        for ind=1:length(main.ROIs)
            % require 70% overlap
            prc_ovlp=length(intersect(main.ROIs(ind).indices,ROIs_in_main_coord(ind).indices))/length(ROIs_in_main_coord(ind).indices);
            if 0.5<prc_ovlp & prc_ovlp<1.5
            else
                disp(['Warning - ROIs nbr ' num2str(ind) ' does not meet min overlap criteria']);
            end
        end
        
        go_on=1;%input(['Do you want to add these new ROIs to all other Exps of the same ExpGroup? ']);
        if go_on
            if  isfield(main.ROIs,'activity')
                main.ROIs=rmfield(main.ROIs,'activity');
            end
            if ~isfield(main.ROIs,'shift')
                main.ROIs(1).shift=[0 0];
            end
            local_average = filter2(ones(win_size)/win_size^2,template);
            t_fil = template./local_average;
            
            [dxf,dyf,dxF,dyF]=fine_ROI_matching(ROIs,t_fil,ot_fil);
            
            for ind=length(main.ROIs)+1:length(ROIs_in_main_coord)
                main.ROIs(ind)=ROIs_in_main_coord(ind);
                main.ROIs(ind).indices=ROIs(ind).indices-(ROItrans(1)+dxf(ind))-(ROItrans(2)+dyf(ind))*size(template,1);
                main.ROIs(ind).shift=[-dxf(ind) -dyf(ind)];
            end
            
            
            ROIs=main.ROIs;
            fname=[adata_dir userID '\' mouse_id '\' main_adata_file];
            disp(['Now saving ' fname])
            save(fname,'ROIs','-append');

            other_expIDs=setdiff(ExpGroup(2:end),str2num(fnames{1}(5:strfind(fnames{1},'_')-1)));
            
            for knd=other_expIDs'
                [curr_adata_file]=find_adata_file(knd,adata_dir);
                if ~isempty(curr_adata_file)
                    fname=[adata_dir userID '\' mouse_id '\' curr_adata_file];
                    curr=load(fname,'ROIs','ROItrans','template');
                    
                    if  isfield(curr.ROIs,'activity')
                        curr.ROIs=rmfield(curr.ROIs,'activity');
                    end
                    
                    if length(curr.ROIs)==nbr_main_ROIs
                        local_average = filter2(ones(win_size)/win_size^2,curr.template);
                        t_fil = curr.template./local_average;
                        
                        [dxf,dyf,dxF,dyF]=fine_ROI_matching(ROIs_in_main_coord,t_fil,ot_fil);
                        
%                         if curr.ROItrans{pl}(1)~=dxF || curr.ROItrans{pl}(2)~=dyF
%                             disp('WARNING ROItrans seems outdated');
%                         end
                        ROIs_in_curr_coord=main.ROIs;
%                         for ind=1:length(ROIs_in_curr_coord)
%                             ROIs_in_curr_coord(ind).indices=ROIs_in_curr_coord(ind).indices+(curr.ROItrans{pl}(1)+dxf(ind))+(curr.ROItrans{pl}(2)+dyf(ind))*size(template{pl},1);
%                         end
                        
                        for ind=length(curr.ROIs)+1:length(ROIs_in_curr_coord)
                            curr.ROIs(ind)=ROIs_in_curr_coord(ind);
                            curr.ROIs(ind).shift=[dxf(ind) dyf(ind)];
                        end
                        ROIs=curr.ROIs;
                        
                        disp(['Now saving ' fname])
                        save(fname,'ROIs','-append');
                    else
                        disp(['Exp ' num2str(knd) ' has probably not been analyzed yet']);
                    end
                end
            end
            
        end
    end
end
disp('--- Done saving ROIs ---');