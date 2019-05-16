function analyze_MLRstim_data

data_dir='C:\Data\MLRstim';

files=dir([data_dir '\*.lvd']);

stwin=0;
endwin=3000;

for ind=1:length(files)
    data=load_lvd([data_dir '\' files(ind).name]);

    velM=diff(data(2,:));
    velM(velM>10)=velM(velM>10)-20;
    velM(velM<-10)=velM(velM<-10)+20;
    velM=ftfil(velM,1000,0,10);
    
    stim_pulses=find(diff(data(3,:)>1)==1);
    stim_pulses=stim_pulses([1 find(diff(find(diff(data(3,:)>1)==1))>50)+1]);
    
    for knd=1:length(stim_pulses)
        loc_act(knd,ind)=mean(velM(stim_pulses(knd)+stwin:min(stim_pulses(knd)+endwin,length(velM))));
        lat=find(abs(velM(stim_pulses(knd):end))>0.01,1,'first');
        if isempty(lat)|lat>endwin
            lat=NaN;
        end
        loc_lat(knd,ind)=lat;
    end
end

figure;imagesc(loc_act')
figure;plot(mean(loc_act'))