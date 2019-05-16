function [outnum]=datenumGER(instr)

instr=strrep(instr,'Mrz','Mar');
instr=strrep(instr,'Okt','Oct');

outnum=datenum(instr);




