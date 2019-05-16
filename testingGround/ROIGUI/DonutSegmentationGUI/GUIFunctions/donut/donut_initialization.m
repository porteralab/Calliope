function donut_initialization(GUI)

global gh

switch GUI
    case 'main'
        InitParamList   = {'NumParam';      'ConvCret';     'NumLoop';      ...
                           'Sig1';          'Sig2';         'ClusterCutoff';...
                           'NumPC';         'NumIC';        'InclCret';     ...
                           'CretCorr0';     'CretCorr1';    'CretCorr2';    'NumRing'};
        InitParamValue  = {16;              10;             20;             ...
                           0.9;             1.2;            1.5;            ...
                           2;               2;              10;             ...
                           0.4;             0.25;           0.8;            1};
        InitSliderValue = {16;              10;             20;             ...
                           9;               12;             15;             ...
                           2;               2;              10;             ...
                           40;              25;             80;             1};
        InitSliderStep  = {64;              100;            100;            ...
                           300;             500;            100;            ...
                           30;              30;             100;            ...
                           100;             100;            100;            20};
        InitSclFact     = {1;               1;              1;              ...
                           10;              10;             10;             ...
                           1;               1;              1;              ...
                           100;             100;            100;            1};
                       
        donut_updateparam(InitParamList,InitParamValue);
        donut_setsliderfunc(InitParamList,InitSliderValue,InitSliderStep);
                       
        for ii=1:length(InitParamList)
            eval(['gh.param.SclFact' InitParamList{ii,1} '=' num2str(InitSclFact{ii,1}) ';']);
            eval(['gh.param.MaxValue' InitParamList{ii,1} '=' num2str(InitSliderStep{ii,1}) ';']);
        end
        
        gh.param.InferFlag=0;
        gh.param.ICAFlag=0;
        gh.param.ClusterFlag=0;
        
        gh.main.opened=1;
        gh.disp.opened=0;
        
    case 'disp'
        gh.data.sze=size(gh.data.ImRaw);
        gh.data.nFrame=gh.data.sze(3);
        gh.data.cFrame=1;
        gh.data.cMax=1;
        gh.data.cMin=0;
        gh.data.cSlice=zeros(gh.data.sze(1),gh.data.sze(2),3);
        
        set(gh.disp.TextNFrame,'String',num2str(gh.data.nFrame));
        set(gh.disp.SliderMain,'Value',0, 'SliderStep',[1/(gh.data.nFrame-1) 0.1]);
        
        gh.disp.ih=image(zeros(1,1,3),'Parent',gh.disp.AxesMain);
        set(gh.disp.ih,'ButtonDownFcn',@donut_axesfunc);
        daspect([1 1 1]);
        set(gh.disp.AxesMain,'XLim',[1,gh.data.sze(1)],'YLim',[1,gh.data.sze(2)]);
        
        donut_dispdrawfunc;
    
        gh.disp.opened=1;
        gh.param.CurrentCellNum=0;
end