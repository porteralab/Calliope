function [xL,xR,yL,yR]=donut_retrbound(CellNum)

global gh

xL=floor(max(gh.data.ix(CellNum,1)-gh.param.HlfWid,1));
xR=floor(min(gh.data.ix(CellNum,1)+gh.param.HlfWid,gh.data.sze(1)));
yL=floor(max(gh.data.iy(CellNum,1)-gh.param.HlfWid,1));
yR=floor(min(gh.data.iy(CellNum,1)+gh.param.HlfWid,gh.data.sze(2)));