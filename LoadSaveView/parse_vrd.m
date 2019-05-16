function [res,sections,raw_txt]=parse_vrd(fname,ExpLog)
% attempt to parse *.vrd files, automatically escapes (0) indices 
% and by default, reads all values as 'char' class
%
% FW 2019

if isnumeric(fname) %get .vrd from ExpID
    if ~exist('ExpLog','var'),ExpLog=getExpLog; end
    [data_path,ExpIDinfo]=get_data_path_all(fname,[],ExpLog);
    fname=[data_path ExpIDinfo.userID filesep ExpIDinfo.mouse_id filesep 'S1-T' num2str(fname) '.vrd'];
end

if exist(fname)==7 %assume it is the datadir
    if isempty(regexpi(fname,'\.vrd'))
        [file,path]=getlatestfile([fname '*.vrd']);
    else
        [file,path]=getlatestfile([fname]);
    end
    fname=[path file];
end

%read the thing
fprintf('loading file: %s\n',fname)
fi=fopen(fname,'r');
raw_txt=fscanf(fi,'%c');
fclose(fi);
sections=strsplit(raw_txt,'\[\w+\-\w+\-\w+ \d+:\d+:\d+\]','DelimiterType','RegularExpression'); %split according to timestamp
sections=sections(~cellfun('isempty',cellfun(@(x) regexprep(strtrim(x),'\n\r\t',''),sections,'uni',0))); %remove empty sections 

%attempt to eval sections line-by-line and return as struct: 'res'
for s=1:numel(sections)
    if isempty(regexprep(strtrim(sections{s}),'\n\r\t','')), continue; end
    this_section=sections{s};
    this_section=strsplit(this_section,'\n');
    for row=1:size(this_section,2)
        if ~isempty(regexpi(this_section{row},'='))
            try
                evalme=strsplit(this_section{row},'='); %assumes only 1x equal sign per line
%                 evalstr=(regexprep(['res{' num2str(s) '}.' regexprep(regexprep(strtrim(evalme{1}),{'(',')'},{'{','}'}),'\{0\}','first') '=''' strtrim(evalme{2}) ''';'],'\n|\r|\t',''));
                evalstr=(regexprep(['res{' num2str(s) '}.' regexprep(regexprep(strtrim(lower(evalme{1})),{'(',')'},{'{','}'}),'\{0\}','first') '=''' strtrim(evalme{2}) ''';'],'\n|\r|\t',''));

                eval(evalstr);
            catch
                warning('couldn''t evaluate line: %s',evalstr);
            end
        end
    end
 
end
end