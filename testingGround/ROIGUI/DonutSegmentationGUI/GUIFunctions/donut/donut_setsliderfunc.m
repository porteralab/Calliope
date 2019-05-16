function donut_setsliderfunc(slider,value,numStep)

global gh

for ii=1:length(slider)
    set(eval(['gh.main.Slider' slider{ii,1}]),...
        'Value',(value{ii,1}-1)/(numStep{ii,1}-1),...
        'SliderStep',[1/(numStep{ii,1}-1) 0.1]);
end