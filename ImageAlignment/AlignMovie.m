function shifted_data=AlignMovie(data,template)
% aligns a series of images stored in data
% data: series of images stored in a matrix l x k x n, where n is the
% number of images
% template: (optional) - if omitted, images are aligned to the average of
% data.

nFrames=size(data,3);

if nargin<2
    template=mean(data,3);
end

template=double(template);
shifted_data=zeros(size(data,1),size(data,2),size(data,3));

for ind=1:nFrames
    disp(['Now processing frame ' num2str(ind) ' of ' num2str(nFrames)])
    
%     % just for illustrational purposes
%     if rem(ind,2)==0
%         data(100:end,:,ind)=circshift(data(100:end,:,ind),[0 4]);
%     end
        
    [dl,dk,offset]=MotionCorrection_HMM(double(data(:,:,ind)),template);
    if length(offset)==1
        offset=[offset offset];
    end 
    
    % if dl and dk are vectors, create the corresponding matrix
    if sum(size(dk)==1)
        if size(dk,1)>1
            dk=dk'
        end
        dk=dk'*ones(1,length(dk));
    end
    if sum(size(dl)==1)
        if size(dl,1)>1
            dl=dl'
        end
        dl=dl'*ones(1,length(dl));
    end
    for n=offset(1)+1:size(data,1)-offset(1)
        for m=offset(2)+1:size(data,2)-offset(2)
            shifted_data(n+dl(n-offset(1),m-offset(2)),m+dk(n-offset(1),m-offset(2)),ind)=data(n,m,ind);
        end
    end
%     figure(123);
%     clf
%     imagesc(shifted_data(:,:,ind));
%     colormap gray
end

% % % 
% % % figure;
% % % colormap gray
% % % ha1=axes('position',[0 0 1 1/2]);
% % % ha2=axes('position',[0 1/2 1 1/2]);
% % % 
% % % color_scale_boundary=1;
% % % 
% % % min_scale=prctile(reshape(double(template),size(template,1)*size(template,2),1),color_scale_boundary);
% % % max_scale=prctile(reshape(double(template),size(template,1)*size(template,2),1),100-color_scale_boundary);

% while 1
%     for ind=1:nFrames
%         axes(ha1)
%         image(64*(shifted_data(:,:,ind)-min_scale)/(max_scale-min_scale));
%         axis off
%         axes(ha2)
%         image(64*(data(:,:,ind)-min_scale)/(max_scale-min_scale));
%         axis off
%         pause(0.1)
%     end
% end
% 
% 
% ind=1;
% imwrite([ data(:,:,ind) shifted_data(:,:,ind) ],'example','gif','loopcount',Inf,'delaytime',0.1);
% 
% for ind=2:nFrames
%     imwrite([ data(:,:,ind) shifted_data(:,:,ind) ],'example','gif','delaytime',0.1,'writemode','append');
% end



