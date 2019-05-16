function [ImOut]=NormIm(ImIn)

M=max(ImIn(:));
m=min(ImIn(:));

ImOut=(ImIn-m)/(M-m);