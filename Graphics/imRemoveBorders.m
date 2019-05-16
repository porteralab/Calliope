function im = imRemoveBorders(im, borders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sets specified border regions to zero.
%
% borders either
% borders = x - remove x lines from each borders
% borders = [x y] - remove x lines from x borders and equivalent removal for y
% borders = [x1 x2 y1 y2] - x1 left, x2 right, y1 top, y2 bottom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

borders = abs(borders);

switch length(borders)
    case 1
        im(1:borders,:)=0;
        im(:,1:borders)=0;
        im(end-borders+1:end,:)=0;
        im(:,end-borders+1:end)=0;
    case 2
        im(1:borders(2),:)=0;
        im(:,1:borders(1))=0;
        im(end-borders(2)+1:end,:)=0;
        im(:,end-borders(1)+1:end)=0;
    case 4
        im(1:borders(3),:)=0;
        im(:,1:borders(1))=0;
        im(end-borders(4)+1:end,:)=0;
        im(:,end-borders(2)+1:end)=0;
    otherwise
        error('Wrong number of border values!');
end