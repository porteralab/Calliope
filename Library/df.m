function df(screen,rows)
%%df(screen,rows)
% Arrange figures to snuggly fit in your monitor (as long as your screens
% are horizontally arranged)
% doc edited by AF, 08.05.2014
%
if nargin < 1
    screen = 1;
end


figHandles = findobj('Type','figure');
[~,ind] = sort([figHandles.Number]);
figHandles = figHandles(ind);

num_figs=length(figHandles);

mon_pos=get(0,'monitorposition');

[~,max_ind]=max(mon_pos(:,3));

dxtot=mon_pos(max_ind,3);
minx=mon_pos(max_ind,1)+20;
miny=mon_pos(max_ind,2)+20;
dytot=mon_pos(max_ind,4);

if nargin < 2
    if num_figs<7
        num_rows=1;
    else
        num_rows=2;
    end
else
    num_rows=rows;
end

num_cols=ceil(num_figs/num_rows);
dx=floor(dxtot/num_cols);
dy=floor(dytot/num_rows);

cnt=0;
for knd=num_rows:-1:1
    for ind=1:num_cols
        cnt=cnt+1;
        if cnt<=num_figs
            set(figHandles(cnt),'position',[minx+(ind-1)*dx-1 miny+(knd-1)*dy+ mon_pos(screen,2)-1 dx-50 dy-100]);
            figure(figHandles(cnt))
        end
    end
end