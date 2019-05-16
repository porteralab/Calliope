function [data, scanrateA, numchannels, timestamp, inputrange, status] = load_lvd(file_name)
%Function loads .lvd files into the workspace.
%
%Use the filename as an input argument. The function will output the raw
%imaging data itself, scan rate, number of channels, time stamp, input
%range and status.
%This function mainly is used to feed into the "calliope" function.
%
%
%documented by DM - 08.05.2014

if nargin < 1
    disp('usage: load_labview_acute(file_name[, file_format])');
    return;
end


%% try to open file, otherwise quit

[fi, message] = fopen(file_name, 'r', 'ieee-be');

status = 0;
data = [];
scanrateA = [];

if fi == -1
    disp('There was a problem reading the following file:');
    disp(file_name);
    disp(message);
    status = -1;
    return;
end

%% get file size

[file_size, read_until] = get_file_size(fi);
fclose(fi);

read_until=0;
%% open the file again - this time to read in the data

fi = fopen(file_name, 'r', 'ieee-be');

%% get all header information

scanrateA = fread(fi, 1, 'double');
numchannels = fread(fi, 1, 'double');
timestamp = fread(fi, 1, 'double');
inputrange = fread(fi, 1, 'double');

%scanrateA needs to be a double otherwise we run into problems. The
%conversion above will deal with the rounding.
scanrateA = double(scanrateA);


%% read in the data

samples_to_read = [numchannels inf];
data = fread(fi, samples_to_read, 'double');

fclose(fi);

end

%% EOF
