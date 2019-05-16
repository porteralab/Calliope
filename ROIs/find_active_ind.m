function [act]=find_active_ind(act,nbr_std,offset)

% figure(111);
% clf
% subplot(211)
% plot(act)
% hold on

act=ftfil(act,10,0,5);
act=psmooth(act);
med_act=median(act);
l_act=act(act<med_act);
std_act=sqrt(sum((l_act-med_act).^2)/length(l_act));

% % % act=act/(med_act);
% % % act_ind=act>1.5;

%act_ind=act>med_act+nbr_std*std_act;

%act_ind=smooth(act_ind,3)>0.5;
% 
% subplot(212)
% plot(act)
% hold on
% plot(act_ind*max(act),'r.')
