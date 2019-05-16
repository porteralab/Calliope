function makePOIfile(imdir, varargin)
% generate a textfile for the POI Navigator
% from imaging data in a given directory
% imdir must be in the format ..\[expdir]\ImagingData\[date] 
%                   e.g. ..\ML_110525_1\ImagingData\2011-06-01
%
% assumes to find stage.x.set (and for y and z)
% in the image ini file

targetdir = imdir;
targetfile = 'POI';
targetext = '.txt';
Adata_dir = [];

if isempty(regexp(imdir,'*', 'once'))
    imdir = fullfile(imdir, '*.bin');
end

% process optional parameters
if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin(1:end-1), 'char'));
    for ind = 1:length(numIndex)
        switch lower(varargin{numIndex(ind)})
            case 'targetlocation'
                targetlocation = varargin{numIndex(ind) + 1};
                [targetdir, targetfile, targetext] = fileparts(targetlocation);
            case 'adata' %location of Adata incl. template file
                Adata_dir = varargin{numIndex(ind) + 1};
        end
    end
end

[imdir, name, ext] = fileparts(imdir);
imdir_parts = regexp(imdir, '\\[a-zA-Z_0-9\-]+', 'match');
filefilter = [name ext];
imfiles = dir(fullfile(imdir, filefilter));
if isempty(imfiles)
    error('No files in specified directory. Aborting ...');
end
% imfiles = imfiles(1);  % for debugging
dirSnapfiles = fullfile(targetdir, [targetfile '_snapshots']);
mkdir(dirSnapfiles);

fi = fopen(fullfile(targetdir, [targetfile targetext]), 'w');
try
    for ind = 1:20
        ind
        if ind > length(imfiles)
            fprintf(fi, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n', ...
                '*', '*', '*', '*', '*', '*', '*', '*');
        else
            fileinfo = readini(fullfile(imdir, regexprep(imfiles(ind).name, 'bin', 'ini')));
            
            fprintf(fi, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\r\n', ...
                num2str(fileinfo.stage.x.set*1e6), ...
                num2str(fileinfo.stage.y.set*1e6), ...
                num2str(fileinfo.stage.z.set*1e6), ...
                '0', '0', '0', ...
                datestr(fileinfo.time, 'mm/dd/yyyy HH:MM:SS AM'), ...
                num2str(fileinfo.experimentcounter));
            if isempty(Adata_dir)
                data = load_bin(fullfile(imdir, imfiles(ind).name));
                imwrite(image2uint8(mean(data,3)), fullfile(dirSnapfiles, [targetfile '-' num2str(ind-1) '.tiff']), 'tiff');
            else
                fileID = regexp(imfiles(ind).name, '\d+', 'match', 'once');
                load(fullfile(Adata_dir, [regexprep(imdir_parts{end-2} ,'\','') '-Adata-' fileID '.mat'] ));
                imwrite(image2uint8(template), fullfile(dirSnapfiles, [targetfile '-' num2str(ind-1) '.tiff']), 'tiff');
            end    
        end
    end
    fclose(fi);
catch
    err = lasterror;
    disp(err.message)
    fclose(fi);
end


