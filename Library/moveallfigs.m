function moveallfigs
% moves all open figures to next consecutive screen
% 16.01.2018 FW

figs=findall(0,'type','figure');
if numel(figs)>0
    [~,idx]=sort([figs.Number]);
    figs=figs(idx);
    for ind=[figs.Number]
        figure(ind)
        movewindow
    end
else
    disp('no figures found, moving currently active window')
    movewindow;
end
end

function movewindow
        import java.awt.*;
        import java.awt.event.*;
        robot = java.awt.Robot;
        Toolkit.getDefaultToolkit().setLockingKeyState(KeyEvent. VK_NUM_LOCK, false);
        %arrowkeys are only pressable if numlock key is off
        robot.keyPress(KeyEvent.VK_SHIFT);
        robot.keyPress(KeyEvent.VK_WINDOWS);
        robot.keyPress(KeyEvent.VK_LEFT);
        robot.keyRelease(KeyEvent.VK_LEFT)
        robot.keyRelease(KeyEvent.VK_SHIFT)
        robot.keyRelease(KeyEvent.VK_WINDOWS);
end