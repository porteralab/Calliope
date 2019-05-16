function [out]=ntzo(in)
% normalize input matrix "in" to the range zero to one 
% AF - 08.05.2014

if isinteger(in)
    in = single(in);
end

in=in-min(in(:));

if max(in(:))>min(in(:))
    out=in./max(in(:));
else
    out=in;
end