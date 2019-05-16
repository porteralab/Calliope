function donut_sliderfunc(hObject)

global gh

SliderValue=get(hObject,'Value');
SliderName=get(hObject,'Tag');
ParamName=SliderName(7:end);

MaxValue=eval(['gh.param.MaxValue' ParamName]);
SclFact=eval(['gh.param.SclFact' ParamName]);

donut_updateparam({ParamName},{round((SliderValue*(MaxValue-1)+1))/SclFact});