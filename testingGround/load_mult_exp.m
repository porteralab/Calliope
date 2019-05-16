function data=load_mult_exp(exps,ch)

[~,host] = dos('hostname');
host = lower(strtrim(host));

if strcmp(host,'keller-rig1-2pi')
    tmp_dir='D:\tempData\';
else strcmp(host,'keller-rig2-2pi')
    tmp_dir='E:\tempData\';
end

% tmp_dir='F:\tempData2\';
% tmp_dir='\\KELLER-RIG1-2PI\tempData_fdrive\zmarpawe\cancer\';

data_sizes=[];
for jnd=1:length(exps)
    fname=['S1-T' num2str(exps(jnd)) '_ch' num2str(ch) '.bin'];
    finfo=dir([tmp_dir fname]);
    fi=fopen([tmp_dir fname],'r');
    x_res=fread(fi,1,'int16=>double');
    y_res=fread(fi,1,'int16=>double');
    nbr_images=round(finfo.bytes/x_res/y_res/2);
    data_sizes(jnd,:)=[x_res y_res nbr_images];
end
data=zeros(data_sizes(1,1),data_sizes(1,2),sum(data_sizes(:,3)),'int16');
cnt=1;
for jnd=1:length(exps)
    fname=['S1-T' num2str(exps(jnd)) '_ch' num2str(ch) '.bin'];
    fi=fopen([tmp_dir fname],'r');
    for ind=1:data_sizes(jnd,3)
        data(:,:,cnt)=fread(fi,[data_sizes(1,2) data_sizes(1,1)],'int16=>int16')';
        cnt=cnt+1;
    end
    fclose(fi);
end

