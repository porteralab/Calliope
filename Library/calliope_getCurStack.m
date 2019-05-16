function stack=calliope_getCurStack
% returns currently selected stack in calliope window
%
% FW 2018

if ishandle(1001)
    cal=handle(1001);
    stack=str2double((regexp(cal.Children(15).String{cal.Children(15).Value},'[0-9]*(?= - )','match','once')));
else
    warning('Couldn''t find calliope figure');
    stack=[];
end

end