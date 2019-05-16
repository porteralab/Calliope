function donut_loadfunc

global gh

[FileName,PathName]=uigetfile;
FilePath=[PathName FileName];

donut_updateparam({'FilePath'},{FilePath});

DataTemp=load(FilePath,'ImRaw');

% gh.data.ImRaw=permute(DataTemp.ImRaw,[2 1 3]);
gh.data.ImRaw=single(DataTemp.ImRaw);
gh.data.ImRawAvg=mean(gh.data.ImRaw,3);
gh.param.InferFlag=0;

donut_disp;