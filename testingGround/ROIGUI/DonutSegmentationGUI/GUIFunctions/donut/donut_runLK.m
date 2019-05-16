function donut_runLK

global gh

gh.data.ImReg=gh.data.ImRaw;
gh.data.ImRef=mean(gh.data.ImRaw,3);

% [gh.data.ImReg]=correctstackv16r(permute(gh.data.ImReg,[2 1 3]),gh.data.ImRef',...
%     gh.param.NumParam,1/gh.param.ConvCret,gh.param.NumLoop);
[gh.data.ImReg]=correctstackv16r(gh.data.ImReg,gh.data.ImRef,...
    gh.param.NumParam,1/gh.param.ConvCret,gh.param.NumLoop);
% gh.data.ImReg=permute(gh.data.ImReg,[2 1 3]);

set(gh.main.ChckbxInferReg,'Value',1);

gh.data.ImRegAvg=mean(gh.data.ImReg,3);