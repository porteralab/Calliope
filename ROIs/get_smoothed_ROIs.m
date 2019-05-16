function [act,ROIinfo]=get_smoothed_ROIs(ROIs,par)
% highly useless little function thingy... "it saves space - that's what makes it useful" quote Mr. P.

ROIinfo=rmfield(ROIs,'activity');
act=zeros(length(ROIs),length(ROIs(1).activity));
if ~exist('par','var') || ~par
    for gnd=1:length(ROIs)
        cur_act=psmooth(ROIs(gnd).activity);
        act(gnd,:)=cur_act/median(cur_act);
    end
elseif par==1
    parfor gnd=1:length(ROIs)
        cur_act=psmooth(ROIs(gnd).activity);
        act(gnd,:)=cur_act/median(cur_act);
    end
end
end