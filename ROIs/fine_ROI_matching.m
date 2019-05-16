function [dxf,dyf,dxF,dyF]=fine_ROI_matching(ROIs,t_fil,ot_fil,do_global_shift,ROItrans)

if nargin<4
    do_global_shift=1;
end

win_size=30;
[dxF,dyF]=register_frames(t_fil,ot_fil,0.15);
if do_global_shift
    tmp=circshift(t_fil,-[dxF dyF]);
else
    tmp=circshift(t_fil,-[ROItrans(1) ROItrans(2)]);
end

for ind=1:numel(ROIs)
    [Rx,Ry]=ind2sub(size(t_fil),ROIs(ind).indices);
    
    txs=[-win_size:win_size]+round(mean(Rx));
    tys=[-win_size:win_size]+round(mean(Ry));
    txs=txs(txs>0);
    tys=tys(tys>0);
    txs=txs(txs<=size(t_fil,1));
    tys=tys(tys<=size(t_fil,2));
    
    t_win=zeros(size(tmp));
    t_win(txs,tys)=tmp(txs,tys)-mean(mean(tmp(txs,tys)));
    
    ot_win=zeros(size(ot_fil));
    ot_win(txs,tys)=ot_fil(txs,tys)-mean(mean(ot_fil(txs,tys)));
    
    [dxf(ind),dyf(ind)]=register_frames(t_win,ot_win,0);
end