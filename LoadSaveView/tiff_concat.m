clear 
frames = input('Images per slice? ')

folder = uigetdir
cd(folder);
dirtxt = dir('*ChanB*.tif');

tic
h = waitbar(0,'Please wait...');

info = imfinfo(dirtxt(1).name);
st = 0;

for k = 1:length(dirtxt)/frames;
    
    for frm = 1:frames
    A(:,:,frm) = imread(dirtxt(frm+st).name);
    
    end
    img = uint16(mean(A,3));
    st = st + frames;
    imwrite(img, ['stack_' dirtxt(1).name(6:end-8) 'multipage.tif'], 'writemode', 'append');
    waitbar(k / (length(dirtxt)/frames));
    % ... Do something with image A ...
end
toc
close(h)

% 
% 
% tagstructure = cell2struct(A.getTagNames,A.getTagNames)
% 
% % fname = 'my_file_with_lots_of_images.tif';
% % info = imfinfo(fname);
% % num_images = numel(info);
% % for k = 1:num_images
% %     A = imread(fname, k, 'Info', info);
% %     % ... Do something with image A ...
% % end
% 
% A.getTag(A.getTagNames{1})
% % for k = 1:length(dirtxt);
%     A = Tiff(dirtxt(k).name, 'r');
%     t = Tiff([dirtxt(1).name(1:end-8) 'multipage.tif'], 'w')
%     frame = A.read;
%     t.write(frame);
%     t.writeDirectory(); 
%     waitbar(k / length(dirtxt));
%      
%     % ... Do something with image A ...
% end
% toc