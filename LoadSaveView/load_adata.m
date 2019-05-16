function [adata,path]=load_adata(ExpID,ws,ExpLog,varargin)
% loads adata (or parts of it) into designated workspace (optional)
%
% usage:
% adata=load_adata(99501);
% ROIs =load_adata(99501,[],'ROIs');
%
% 23.01.2018 FW

if ~exist('ExpLog','var'), ExpLog=getExpLog; end
if ~exist('ws','var') || isempty(ws), ws='default'; end
if ~exist('varargin','var') || isempty(varargin), varargin={}; end

[adata,path,filename]=deal([]);

adata_dir=set_lab_paths;
ExpLog=getExpLog;

%find adata_file (see also find_adata_file)
idx=find([ExpLog.stackid{:}]==ExpID);
filename=dir([adata_dir ExpLog.pi{idx} '\' ExpLog.animalid{idx} '\*' num2str(ExpID) '*.mat']);
path=[adata_dir ExpLog.pi{idx} '\' ExpLog.animalid{idx} '\' filename.name];

%if file does not exist, correct potentially stackID => ExpID
idx=find([ExpLog.expid{:}]==ExpID);
if isempty(idx)
    if ~exist(path,'file')==7
        ExpID=ExpLog.expid{idx};
        idx=find([ExpLog.expid{:}]==ExpID);
        idx=idx(1);
        filename=dir([adata_dir ExpLog.pi{idx} '\' ExpLog.animalid{idx} '\*' num2str(ExpID) '*.mat']);
        path=[adata_dir ExpLog.pi{idx} '\' ExpLog.animalid{idx} '\' filename.name];
        
        warning('stackID given, corrected to ExpID: [%i]\n',ExpID);
    else
        warning('stackID given, however Adatafile exists: [%i]\n',ExpID);
    end
end

switch ws
    case 'base'
        if isempty(varargin)
            evalin('base',['load(''' path  ''' )']);
        else
            evalin('base',['load(''' path ''',''' strjoin(varargin,',') ''' )' ]);
        end
        fprintf('loaded Adata into base workspace\n');
    case 'caller'
        if isempty(varargin)
            evalin('caller',['load(''' path  ''' )']);
        else
            evalin('caller',['load(''' path ''',''' strjoin(varargin,',') ''' )' ]);
        end
    case 'default'
        adata=load(path,varargin{:});
end

end
