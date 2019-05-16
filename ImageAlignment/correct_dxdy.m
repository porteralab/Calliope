function []=correct_dxdy(ExpID,recalc,varargin)
%CORRECT_DXDY(ExpID, recalc, varargin): correct registration dx and dy values using manually corrected values or using
%dx and dy from one of the z-planes (for multilayer stacks). The template
%and act_map are recalculated automaticaly.
%
%inputs:
%ExpID = ExpID of stack for dx and dy correction
%recalc = specifies whether template and activity map need to be
%         recalculated. Accepted arguments are 0 (no) and 1 (yes). WARNING:
%         recalculation requires loading the .bin file
%varargin = specifies additional parameters and their values. Valid
%parameters are the following:
%
%   Parameter           Value
%   'man_corr'          manually corrected dx and dy values. For multilayer
%                       experiments the values need to be entered as a cell array
%                       with the same number of entries as there are z layers.
%                       Always enter dx values first and then dy (see example below).
%   'z_plane'           takes two arguments! 1. z-plane to select dx and dy values from.
%                       2. z-planes to correct
%
%
%e.g. correct_dxdy(1234,1,'man_corr',corrected_dx,corrected_dy)
%e.g. correct_dxdy(1234,1,'z_plane',1,[3 4])
%
% written by AA 2014-03-19
% modified by PZ 2014-03-20
% modified by DM 2014-05-14
% modified by ML 2014-06-23
% modified by PZ 2014-07-06
% modified by PZ 2015-07-30 changed .bin file loading routine to load_exp.m
% modified by PZ 2015-08-01 corrected error check by setting man_corr to depend on varargin 

adata_dir=set_lab_paths();

[adata_file,mouse_id,userID] = find_adata_file(ExpID,adata_dir);
fname=[adata_dir userID '\' mouse_id '\' adata_file];
curr_file_struct = load(fname);

switch lower(varargin{1})
    case 'man_corr'
        man_corr=1;
        dxNew=varargin{1 + 1};
        dyNew=varargin{1 + 2};
    case 'z_plane'
        man_corr=0;
        z_plane=varargin{1 + 1};
        z_to_correct=varargin{1 + 2};
end

if ~exist('recalc','var') || ~exist('man_corr','var')
    error('Incorrect arguments - check documentation')
end


% save registration correaction log
path_to_curr_file = eval(['which(''' mfilename ''')']);
[~,svn_revision_nbr]=system(['svn info --show-item revision "' path_to_curr_file '"']);
arg_input_str = cellfun(@num2str,varargin(~cellfun(@(x) isa(x,'cell'),varargin)),'UniformOutput',0);
arg_input_str = sprintf('%s, ',arg_input_str{:});
reg_log_str = [datestr(now) ' - SVN revision nbr: ' num2str(str2num(svn_revision_nbr)) ' : correct_dxdy - ' arg_input_str ': EOL'];

if ~isfield(curr_file_struct,'registration_log')
   curr_file_struct.registration_log{1}=reg_log_str;
else
   curr_file_struct.registration_log{end+1}=reg_log_str;
end


ExpInfo = read_info_from_ExpLog(ExpID,1);
pdef=getProjDef(ExpInfo.proj);

% load the 2P data
% pre-allocate space for data
if recalc
    ExpLog=getExpLog;
    assignin('base','load_noregister',1)
    load_fype=[pdef.main_channel(3:end) '.bin'];
    load_exp(ExpID,adata_dir,load_fype,ExpLog,'caller')
end

if man_corr
    if recalc
        disp(['Now registering data on new dx dy values and correcting line shift']);
        if ~isa(dxNew,'cell')
            data=shift_data(data,dxNew,dyNew);
            data=correct_line_shift(data,mean(data,3));
            act_map=calc_act_map(data);
            template=mean(data,3);
        else
            act_map={};
            template={};
            for rnd=1:length(dxNew)
                data{rnd}=shift_data(data{rnd},dxNew{rnd},dyNew{rnd});
                data{rnd}=correct_line_shift(data{rnd},mean(data{rnd},3));
                act_map{rnd}=calc_act_map(data{rnd});
                template{rnd}=mean(data{rnd},3);
            end
        end
        curr_file_struct.act_map=act_map;
        curr_file_struct.template=template;
    end
    curr_file_struct.dx=dxNew;
    curr_file_struct.dy=dyNew;
else
    correct_dx=curr_file_struct.dx{z_plane};
    correct_dy=curr_file_struct.dy{z_plane};
    for rnd=z_to_correct
        if recalc
            disp(['Now registering z-plane ' num2str(rnd) ' with dx dy values from z-plane ' num2str(z_plane) ' and correcting line shift']);
            data{rnd}=shift_data(data{rnd},correct_dx,correct_dy);
            data{rnd}=correct_line_shift(data{rnd},mean(data{rnd},3));
            curr_file_struct.act_map{rnd}=calc_act_map(data{rnd});
            curr_file_struct.template{rnd}=mean(data{rnd},3);
        end
        curr_file_struct.dx{rnd}=correct_dx;
        curr_file_struct.dy{rnd}=correct_dy;
    end
end

save(fname,'-struct','curr_file_struct','-v7.3');

disp('----Done fixing your registration...----');