function donut_editfunc(hObject)

global gh

EditValue=str2double(get(hObject,'String'));
EditName=get(hObject,'Tag');
ParamName=EditName(5:end);

donut_updateparam({ParamName},{EditValue});
donut_setsliderfunc({ParamName},{EditValue*eval(['gh.param.SclFact' ParamName])},{eval(['gh.param.MaxValue' ParamName])});