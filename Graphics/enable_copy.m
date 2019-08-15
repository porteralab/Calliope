function enable_copy(src,a,b)
%enable shift+rightclick to copy figures to clipboard preserving core
%functionalities, esp. of MatLab>2019
%FW 2019

try
    addlistener ( gcf, 'WindowMousePress', @(src,~) pressme(src,[]));
catch
end
    function pressme(src,~)
        %         fprintf('%s %s\n',src.SelectionType, strjoin(src.CurrentModifier))
        if strcmp(src.SelectionType,'extend') && numel(src.CurrentModifier)==1 &&  strcmp(src.CurrentModifier,'shift')
            try
                addprop(gcf,'goahead');
                src.goahead=true;
            catch
            end
            if src.goahead==true
                disp('copied figure to clipboard');
                print(gcf,'-clipboard','-dmeta')
            else
                disp('prevented copying')
            end
        end
    end
end