function varargout=checkAux(exp,varargin)
% data=checkAux(exp)
%
% Plot and evaluate the Aux data on data aquisition machines.
%
% Note: the calculation of the number of feedback mismatches and playback
% halts always assumes that ps_id is on the 3rd channel, and visual flow
% and running are on the 4th and 5th channel of the lvd file, respectively.
%
% e.g.
% checkAux();      - looks for the last aux file and displays the data
% checkAux(12345); - displays data from a particular experimentID
% checkAux(-2);    - displays data from a aux file 2 timepoints further
%                    down the history, 0 is the last.
% optional arguments
% 'check_ps'        - some tests for fb, pb and pb halts

% Modified by ML on 20150603.
% Modified by BW on 20150313.
% Modified by FW on 20180221.

if ~isempty(varargin)
    p = inputParser;
    if verLessThan('matlab','8.2')
        p.addParamValue('check_ps',0,@isnumeric)
        p.parse(varargin{:})
    else
        addRequired(p,'exp',@isnumeric)
        addParameter(p,'check_ps',0,@isnumeric)
        parse(p,exp,varargin{:})
        exp = p.Results.exp;
    end
end

tmppath = 'D:\tempData\';

if exist('exp','var') && isa(exp,'string'), exp=char(exp); end

if ~exist(tmppath,'dir') && ishandle(1001) && ~exist('exp','var') %if path not found, calliope open and no parameters given, substitute parameters from calliope
    fprintf('- checking aux of exp/stack selected in calliope...')
    a=handle(1001);
    exp=str2double((regexp(a.Children(15).String{a.Children(15).Value},'[0-9]*(?= - )','match','once')));
    selected_stack=a.Children(3).Value;
    if isempty(selected_stack), selected_stack=1; end
    loc = cell2mat(getfield(getfield(read_info_from_ExpLog(exp,1),'aux_files'),{selected_stack})); %get first stack auxfile
    fprintf('\b\b\b (%i,%i)\n',exp,selected_stack);
elseif nargin==1 && isa(exp,'char') && ~isempty(regexp(exp,'\:\\|\\\\')) %if absolute path to file...
    [~,~,extens]=fileparts(exp);
    if ~isempty(extens)
        loc=exp;
    else %if absolute path to dir...
        tmppath=exp;
        if ~strcmp(tmppath(end),'\') %user forgot to specify the last char as 'backslash'
            tmppath=[tmppath '\'];
        end
        tmpfiles = dir([tmppath 'S1-T*.lvd']);
        [~,tmp_time_ind] =  sort([tmpfiles.datenum],'descend');
        loc = fullfile(tmppath,tmpfiles(tmp_time_ind(1)).name);
    end
elseif nargin<1
        tmpfiles = dir([tmppath 'S1-T*.lvd']);
        [~,tmp_time_ind] =  sort([tmpfiles.datenum],'descend');
        loc = fullfile(tmppath,tmpfiles(tmp_time_ind(1)).name);
elseif exp < 1
        tmpfiles = dir([tmppath 'S1-T*.lvd']);
        [~,tmp_time_ind] =  sort([tmpfiles.datenum],'descend');
        loc = fullfile(tmppath,tmpfiles(tmp_time_ind(1+abs(exp))).name);
else
    loc = [tmppath 'S1-T' num2str(exp) '.lvd'];
end

display(['Loading Aux data from ' loc])

data = load_lvd(loc);
inidata = readini(regexprep(loc,'.lvd','.ach'));
inifields = fieldnames(inidata.auxrec);
ind = 1;
for ii = 1:length(inifields)
    temp = regexp(inifields(ii),'channel');
    if ~isempty(cell2mat(temp))
        legendfield(ind) = {eval(['regexprep(inidata.auxrec.' cell2mat(inifields(ii)) ',''\_'',''\\_'')'])};
        ind = ind + 1;
    end
end

h1 = specTraces(data,'downsample',1,'legendNames',legendfield,'title',regexprep(loc,'\\','\\\\'));
set(h1,'Position',[100 300 800 400])

if max(data(2,:))>1 && strcmp(legendfield(2),'FrameGalvo')
    fr_times = diff(get_frame_times(data(2,:)));
    h2 = figure;
    set(h2,'Position',[700 300 300 300])
    hist(fr_times);title('frame times')
    m1 = mean(fr_times);
    std1 = std(fr_times);
    outlierframes = sum(fr_times < m1-2*std1 | fr_times > m1+2*std1);
    textsnip = ['mean frame time: ' num2str(m1) ' and std: ' num2str(std1) ...
        ' # outlier frames: ' num2str(outlierframes) '\n'];
    if outlierframes ~= 0
        fprintf(2,textsnip);
    else
        fprintf(textsnip);
    end
end

% execute extra function given by arguments
if exist('p','var')
    if p.Results.check_ps
        check_ps(data,loc);
    end
end



% prevent accidental flooding of console with function output
if nargout>0
    varargout{1}=data;
end

end

function check_ps(data,loc)
try
    parameters_main;
    ps_bi = data(3,:) > 0.8;
    ps_ons = find(diff(ps_bi)>0.5)+1;
    %     running_t=0.005; warning('strict running threshold (0.005)')
    [~,run_bi,velM_smoothed,~] = get_vel_ind_from_adata(data(5,:));
    [~,vis_bi,velP_smoothed,~] = get_vel_ind_from_adata(data(4,:));
    velP_ons = find(diff(velP_smoothed>running_t))+1;
    cc = corrcoef(+run_bi,+vis_bi);
    if sum(ps_bi) == 0;
        display(['There are no visual perturbations in this session.' ...
            char(10) '              animal ran ' num2str(round(sum(velM_smoothed>running_t)/size(velM_smoothed,2)*100,2)) '% of the time' ...
            char(10) '              avg speed ' num2str(round(mean(velM_smoothed),3)) '[a.u.]' ...
            ])
    elseif cc(2) > 0.6
        display('This looks like a feedback session.')
        rps_nbr = 0;
        for ps_id = 1:length(ps_ons)
            try % catch if ps too early or late
                if sum(run_bi(ps_ons(ps_id)-300:ps_ons(ps_id)+1000)) == 1301
                    rps_nbr = rps_nbr+1;
                end
            end
        end
        display(['It has ' num2str(rps_nbr) ' effective feedback mismatches.' ...
            char(10) '         animal ran ' num2str(round(sum(velM_smoothed>running_t)/size(velM_smoothed,2)*100,2)) '% of the time' ...
            char(10) '         avg speed ' num2str(round(mean(velM_smoothed),3)) '[a.u.]' ...
            ])
    else
        display('This looks like a playback session.')
        rps_nbr = 0;
        rps_id = [];
        rph_nbr = 0;
        velP_ons_n=0;
        for ps_id = 1:length(ps_ons)
            if sum(vis_bi(ps_ons(ps_id)-300:ps_ons(ps_id))) == 301
                if sum(vis_bi(ps_ons(ps_id)+1000:ps_ons(ps_id)+1300)) == 301
                    rps_nbr = rps_nbr+1;
                    rps_id(rps_nbr) = ps_id;
                end
            end
        end
        for ph_id = rps_id
            if sum(run_bi(ps_ons(ph_id)-300:ps_ons(ph_id)+1000)) == 0
                rph_nbr = rph_nbr+1;
            end
        end
        for ind=1:length(velP_ons)
            if all(velM_smoothed(velP_ons(ind)+sitting_period)<.0005)
                velP_ons_n=velP_ons_n+1;
            end
        end
        display(['It has about ' num2str(rph_nbr)    ' effective playback halts, '...
            char(10) '             ' num2str(velP_ons_n) ' effective visual onsets.'...
            char(10) '              animal ran ' num2str(round(sum(velM_smoothed>running_t)/size(velM_smoothed,2)*100,2)) '% of the time' ...
            char(10) '              avg speed ' num2str(round(mean(velM_smoothed),3)) '[a.u.]' ...
            ])
        
        
    end
catch me
    display('There was an error when calculating MM and PBH')
    display(me.message)
end
end