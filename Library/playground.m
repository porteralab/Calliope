whos frame_times
data_explorer(aux_data,ROIs,data{1},frame_times(1:4:end),data{2},frame_times(2:4:end))
edit load_eye_monitor_data.m
imeta_info
imeta_data
figure;plot(imeta_data(:,1))
figure;plot(imeta_data(1,:))
figure;plot(imeta_data(1,2:end))
figure;plot(imeta_data(2,2:end))
figure;plot(aux_data(1,:))
edit get_frame_times
frame_times(1)
figure;plot(aux_data(1,:))
hold on
plot(aux_data(2,:),'r')
iframe_times
iframe_times(1)
iframe_times(2)
whos idata
whos iframe_times
iframe_times(1)
ca;data_explorer(aux_data,ROIs,data{1},frame_times(1:4:end),idata,iframe_times)
data_explorer(aux_data,ROIs,data{1},frame_times(1:4:end),idata,iframe_times)
ca
data_explorer(aux_data,ROIs,data{1},frame_times(1:4:end),idata,iframe_times)