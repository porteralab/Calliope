function [out] = readini(fname, tag)
% READINI reads all kind of ini files and gives it back as a structure if 'tag' is not specified.
%
%   readini('foobar.ini') reads in ini file in the following format
%       tag = "value"
%       ...
%
%   NOTE:
%       - the delimiter '=' can also be \t
%       - tag names will be modified if they don't match fieldname
%       convention of matlab, e.g.
%           tag test -> tag_test
%           tag.1.test ->   tag_1.test
%       - numbers will be converted to double numbers, the rest are strings
%
% ML: still to fix: fieldnames with values of higher hierarchy, e.g. test=0 and test.foo=2

if nargin<2
    read_all=1;
else
    read_all=0;
end

delimiter = '\t'; % for now, might change later
dateformats = {'yyyy-mm-dd HH:MM:SS.FFF' 'yyyy-mm-dd_HH-MM-SS'};

fi=fopen(fname, 'r');
str = fgetl(fi);
if strcmp(str, '[main]') % skip first line in that case
    str = fgetl(fi); 
end
temp = regexp(str, delimiter, 'split');
lineID = 1;
if length(temp) == 1 % determine final delimiter
    delimiter = '=';
else
    delimiter = '\t';
end


while ~feof(fi)
    if lineID > 1
        str = fgetl(fi); % the 1st line we got already
    end
    
    temp = regexp(str, delimiter, 'split');
    temp1 = strtrim(cell2mat(temp(1))); % tag
    temp2 = strtrim(cell2mat(temp(2)));  % value
    temp1 = regexprep(temp1, ' ', '_'); % white space in fieldnames not allowed

    
    tmpexpr = regexp(temp1, '\.\d', 'once');   % foo.\d.bar not allowed as fieldname 
    if ~isempty(tmpexpr)  %
        tmpexpr = regexp(temp1, '\.\d', 'match');
        tmpexpr2 = regexprep(tmpexpr, '\.', '_');
        temp1 = regexprep(temp1, tmpexpr, tmpexpr2);
    end
    temp1 = regexp(temp1, '_[', 'split');  % remove everything after _[
    temp1 = cell2mat(temp1(1));
    
    temp2 = regexprep(temp2, '"', '');  % remove "
    temp2 = strtrim(temp2);
    
    % assign value to tag, try to convert numbers and date
    try
        if length(regexp(temp2,'[0-9eE+\-\. ]','match')) == length(temp2)
            eval(['data.' temp1 '=[' temp2 '];']);  % for numbers
        else
            iserror = 0;
            for ind=1:length(dateformats)
                try
                    eval(['data.' temp1 '=datenum(''' temp2 ''', ''' dateformats{ind} ''');']);
                    iserror = 0;
                    break
                catch
                    iserror = 1;
                end
            end
            if iserror    % everthing else is a string
                eval(['data.' temp1 '=''' temp2 ''';']);
            end
        end
    end
    
    lineID = lineID + 1;
end
fclose(fi);

if ~read_all
    try
        eval(['out = data.' tag ';']);
    catch
        out = [];
    end
else
    out = data;
end
