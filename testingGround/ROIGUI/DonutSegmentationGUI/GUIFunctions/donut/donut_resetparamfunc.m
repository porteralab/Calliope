function donut_resetparamfunc(ParamList,ValueList)

global gh

donut_updateparam(ParamList,ValueList);
for ii=1:size(ParamList,1)    
    donut_setsliderfunc({ParamList{ii,1}},{ValueList{ii,1}*eval(['gh.param.SclFact' ParamList{ii,1}])},...
        {eval(['gh.param.MaxValue' ParamList{ii,1}])});
end