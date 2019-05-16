function batchZstack(folder, varargin)
% only works if ini file specifies zstack
%
% for folder, use wildcards to specify the group of files of interest
% e.g.
% folder = 'D:\data\mouse\sparse\TR_110704_7\ImagingData\2011-08-12\*525.bin';

files = dir(folder);
folder = fileparts(folder);

for fnd = 1:size(files,1);
    fnd
    scaninfo = readini(regexprep(fullfile(folder,files(fnd).name),'bin','ini'));
    if strcmp(scaninfo.job.name,'XYZ res')
        data = load_bin(fullfile(folder,files(fnd).name));
        meandata = register_multilayer(data, scaninfo.job_8.data);
        meandata = meandata - min(min(min(meandata)));
        meandata = meandata .* (65535 / max(max(max(meandata))));
        meandata = uint16(meandata);
        outputfile = regexprep(fullfile(folder,files(fnd).name),'bin','tif');
        if ~exist(outputfile,'file')
            for ind = 1:size(meandata,3)
                imwrite(meandata(:,:,ind), outputfile, 'tiff', 'Compression', 'none', ...
                    'WriteMode','append');
            end
        else
            error(['Tried to overwrite files. Aborted at pos. ' num2str(fnd)]);
        end
        close all;
    end
end