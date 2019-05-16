function [] = plot_activity_gen(ROIs,bv,np,template,aux_fct)
% this function displays all ROIs superimposed on a the template. click on
% a ROI to display its activity
% white: raw df/f
% yellow: np activity & np subtracet df/f
% blue: bv activity & bv subtracted df/f
% use aux_fct (string) to define an arbitrary function that is executed
% when a cell is selected.

if nargin<5
    aux_fct='';
end

% plot template with cells overlayed
max_cont=mean(template(:))+2*std(template(:));
min_cont=mean(template(:))-2*std(template(:));

hf = figure(1002);
set(hf,'menubar','none');
ha = axes('position',[0 0 1 1]);

tmp=(template-min_cont)/(max_cont-min_cont);
tmp(tmp>1)=1;
tmp(tmp<0)=0;

t_mask=zeros(size(template));
bv_mask=zeros(size(template));

for ind=1:length(ROIs)
    t_mask(ROIs(ind).indices)=1;
% % %     bv_mask(bv.indices)=1;
end

overlay(:,:,1)=tmp;
overlay(:,:,2)=bwperim(t_mask);
overlay(:,:,3)=bwperim(bv_mask);
hi=imagesc(overlay);
hold on

for ind=1:length(ROIs)
    [txt_x,txt_y]=ind2sub(size(template),min(ROIs(ind).indices));
    ht(ind)=text(txt_y,txt_x-10,num2str(ind),'color','w','fontweight','bold','fontsize',12);
end
sel_roi=1;
set(hi,'buttondownfcn',{@plot_activity_bdf,aux_fct,template,ROIs,ha,hf,ht});
set(hf,'keypressfcn',{@plot_activity_kpf,aux_fct,template,ROIs,ha,hf,ht});
set(hf,'userdata',sel_roi);
box off
%axis off

function [] = plot_activity_kpf(h,e,aux_fct,template,ROIs,ha,hf,ht)

set(ht,'color','w');

sel_roi=get(hf,'userdata');
switch e.Key
    case 'rightarrow'
        sel_roi=mod(sel_roi+1-1,length(ROIs))+1;
    case 'leftarrow'
        sel_roi=mod(sel_roi-1-1,length(ROIs))+1;

end

assignin('base','sel_roi',sel_roi);
set(hf,'userdata',sel_roi);
set(ht(sel_roi),'color','k');
evalin('base',aux_fct);
figure(hf);

function [] = plot_activity_bdf(h,e,aux_fct,template,ROIs,ha,hf,ht)

set(ht,'color','w');
cp=get(ha,'currentpoint');
sel_ind = sub2ind(size(template),round(cp(3)),round(cp(1)));

for ind=1:length(ROIs)
    if sum(sel_ind == ROIs(ind).indices) == 1
        sel_roi = ind;
    end
end

if exist('sel_roi')
    assignin('base','sel_roi',sel_roi);
    set(hf,'userdata',sel_roi);
    set(ht(sel_roi),'color','k');
    evalin('base',aux_fct);
else
    sel_roi=-1;
    disp('No cell selected')
    assignin('base','sel_roi',sel_roi);
    evalin('base',aux_fct);
end


