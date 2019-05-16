function [lft_inj,rgt_inj]=chat_bl_corr(b,l)

% input ML AP DV

b=b*10;
l=l*10;

atlas_bl=4.21;
cur_bl=b(2)-l(2);
cur_f=cur_bl/atlas_bl;

inj=[1.8 -0.5 4.3; 1.5 -0.35 4.5; 1 0.13 4.7; 0.7 0.61 4.7];
inj=inj*cur_f;

lft_inj=round([(b(1)-inj(:,1))/10 (b(2)+inj(:,2))/10 inj(:,3)],2);
rgt_inj=round([(b(1)+inj(:,1))/10 (b(2)+inj(:,2))/10 inj(:,3)],2);