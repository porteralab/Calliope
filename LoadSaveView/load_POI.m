function [out] = load_POI(fname)
% LOAD_POI reads data from POI Navigator including snapshots.
%
%Input the file name to the function.
%
%
%documented by DM - 08.05.2014

out = struct;

delimiter = '\t'; % for now, might change later

fi = fopen(fname, 'r');
lineID = 1;
while ~feof(fi)
    str = fgetl(fi); % the 1st line we got already
    temp = regexp(str, delimiter, 'split');
    out(lineID).x = convert2num(temp(1));
    out(lineID).y = convert2num(temp(2));
    out(lineID).z = temp(3);
    out(lineID).rel_x = temp(4);
    out(lineID).rel_y = temp(5);
    out(lineID).rel_z = temp(6);
    out(lineID).date = temp(7);
    out(lineID).comment = temp(8);
    
    lineID = lineID + 1;
    
end
fclose(fi);

% read in snapshots
[a,b,c] = fileparts(fname);
if ~isempty(c)
    filename = [b '.' c];
else
    filename = b;
end

filepath = [fname '_snapshots\'];
for ind = 1:lineID-1
    if exist([filepath filename '-' num2str(ind-1) '.tif'], 'file')
        out(ind).image = imread([filepath filename '-' num2str(ind-1) '.tif']);
    end
end

function result = convert2num(string)
if strcmp(string,'*')
    result = [];
else
    result = str2num(cell2mat(string));
end

