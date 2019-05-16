function [ImOut]=donut_adjustcontrast(ImIn,CMin,CMax)

ImOut=max(min((ImIn-CMin)/(CMax-CMin),1),0);