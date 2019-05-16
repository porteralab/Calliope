

[dx,dy]=register_frames(mean_data,template{2});

md=shift_data(mean_data,dx,dy);

tmpB=template{2}-mean(mean(template{2}));
for ind=1:size(md,3)
    tmpA=md(:,:,ind)-mean(mean(md(:,:,ind)));
    xcAB(ind)=sum(sum(tmpA.*tmpB));
end



[~,pos]=max(xcAB'.*(abs(dx)<10).*(abs(dy)<10))


md=mean_data;
for ind=1:size(mean_data,3)
    md(:,:,ind)=md(:,:,ind)/mean(mean(md(:,:,ind)));
end
md(100:104,100:104,100:102)=10000;
view_stack(permute(md,[3 2 1]));