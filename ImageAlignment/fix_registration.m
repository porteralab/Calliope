function [shift_x,shift_y]=fix_registration(data,template,shift_x,shift_y)
% aligns images in stack to a template using xcorr
% input image (data) has to be a matrix of the form w x h x n, where w: width
% h: height and n: number of images in stack.

max_shift=100;

% initialize matrices
dimensions = size(data);

template=template-mean(template(:));

% determine how much of the images to use for alignment, the larger the
% boundary the less pixels are used for alignment and the faster the
% algorithm runs.
boundary=round(0.05*max(size(data(:,:,1))));
template=template(boundary+1:end-boundary,boundary+1:end-boundary);

%c=fft_xcorr(template,data(boundary+1:end-boundary,boundary+1:end-boundary,ind));
F_template_size = [size(template,1) size(template,2)];
F_in_size = [size(data,1)-2*boundary size(data,2)-2*boundary];
outsize = F_template_size + F_in_size - 1;

low_pass_thresh=round(min(F_template_size)/4);
high_pass_thresh=round(min(F_template_size)/40);

template = double(template);

% fourier transform and band pass filter the template
F_template = fft2(rot90(template,2),outsize(1),outsize(2));

F_template([1:high_pass_thresh size(F_template,1)-high_pass_thresh+2:size(F_template,1)],:)=0;
F_template(:,[1:high_pass_thresh size(F_template,2)-high_pass_thresh+2:size(F_template,2)])=0;

F_template(low_pass_thresh+2:end-low_pass_thresh,:)=0;
F_template(:,low_pass_thresh+2:end-low_pass_thresh)=0;


if abs(shift_x(1)-median(shift_x))>max_shift || abs(shift_y(1)-median(shift_y))>max_shift
    disp('Initial values of dx/dy already bad')
end

% % % if sum(abs(diff(shift_x))>max_shift & abs(diff(shift_y))>max_shift)
% % %     use_cond2=1;
% % % else
    use_cond2=0;
% % % end
cond1_mem=0;
for ind=2:size(data,3)
    cond1=abs(shift_x(ind)-shift_x(ind-1))>max_shift || abs(shift_y(ind)-shift_y(ind-1))>max_shift;
    if rem(ind,1000)==1 && cond1_mem==0
        cond1=0;
    end
    if cond1 && cond1_mem==0
        shift_x_mem=shift_x(ind-1);
        shift_y_mem=shift_y(ind-1);
    end
    if cond1 && abs(shift_x(ind)-shift_x_mem)<=max_shift && abs(shift_y(ind)-shift_y_mem)<=max_shift
        cond1=0; 
    end
    cond1_mem=cond1;
    if use_cond2
        cond2=shift_x(ind)-shift_x(ind-1)==0 & shift_y(ind)-shift_y(ind-1)==0;
    else
        cond2=0;
    end
    
    if  cond1 || cond2
        sc_in=double(data(:,:,ind))-mean(mean(data(:,:,ind)));
        % fourier transform and band pass filter current frame
        F_in = fft2(sc_in(boundary+1:end-boundary,boundary+1:end-boundary),outsize(1),outsize(2));
        F_in(low_pass_thresh+2:end-low_pass_thresh,:)=0;
        F_in(:,low_pass_thresh+2:end-low_pass_thresh)=0;
        F_in([1:high_pass_thresh size(F_in,1)-high_pass_thresh+2:size(F_in,1)],:)=0;
        F_in(:,[1:high_pass_thresh size(F_in,2)-high_pass_thresh+2:size(F_in,2)])=0;
        
        % calculate the cross correlation (in fourier space convolution is a
        % multiplication
        c = real(ifft2(F_template .* F_in));
        c=c(boundary+1:end-boundary,boundary+1:end-boundary);
        
        tmpl=shift_x(ind-1)+ceil(size(c,1)/2)-max_shift;
        tmpr=shift_x(ind-1)+ceil(size(c,1)/2)+max_shift;
        tmpu=shift_y(ind-1)+ceil(size(c,2)/2)-max_shift;
        tmpd=shift_y(ind-1)+ceil(size(c,2)/2)+max_shift;
        c([1:tmpl tmpr:end],:)=0;
        c(:,[1:tmpu tmpd:end])=0;
        
        % determine the indices of the maximum
        [~,max_ind] = max(c(:));
        [max_x,max_y] = ind2sub(size(c),max_ind);
        
        
        
        % calulate the x and y shifts.
        shift_x(ind)=max_x-ceil(size(c,1)/2);
        shift_y(ind)=max_y-ceil(size(c,2)/2);
    end
end


% 
% for ind=1:size(data,3)
%     % shift the image
%     % zero padded shift
%     tmp_im=zeros(size(data,1),size(data,2),'uint16');
%     tmp_im(max(1,-round(shift_x(ind))+1):min(dimensions(1),dimensions(1)-round(shift_x(ind))),max(1,-round(shift_y(ind))+1):min(dimensions(2),dimensions(2)-round(shift_y(ind)))) = ...
%         data(max(1,round(shift_x(ind))+1):min(dimensions(1)+round(shift_x(ind)),dimensions(1)),max(1,round(shift_y(ind))+1):min(dimensions(2)+round(shift_y(ind)),dimensions(2)),ind);
%     
%     data(:,:,ind)=tmp_im;
%     
% end
% 




















