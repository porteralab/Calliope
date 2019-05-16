function []=shift_data_global(shift_x,shift_y)
global data
median_data=median(double(data(1,1,:)));
%min_data=-16374;
dimensions = size(data);
for ind=1:size(data,3)
    tmp_im=int16(median_data)*ones(size(data,1),size(data,2),'int16');
    tmp_im(max(1,-round(shift_x(ind))+1):min(dimensions(1),dimensions(1)-round(shift_x(ind))),max(1,-round(shift_y(ind))+1):min(dimensions(2),dimensions(2)-round(shift_y(ind)))) = ...
        data(max(1,round(shift_x(ind))+1):min(dimensions(1)+round(shift_x(ind)),dimensions(1)),max(1,round(shift_y(ind))+1):min(dimensions(2)+round(shift_y(ind)),dimensions(2)),ind);
    data(:,:,ind)=tmp_im;
end

