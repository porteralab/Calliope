function fildata=ftfil(data,frequency,hi_pass,lo_pass)

% apply high-pass (hi-pass) or low-pass (lo-pass) filter
%-------------------------------------------------------------------------
% applies a high- or low- pass filter through the largest dimension of the
% dataset (e.g. if more columns than rows, takes the fourier transform over
% the columns


if size(data,1)>size(data,2)
    data=data';
end

s=size(data);
fildata=data;

for i=1:s(1)
    y=fft(data(i,:));
    % cut of everysting below hi_pass Hz
    lim=round((hi_pass/frequency)*length(y));
    y(1:lim)=0;
    y(end-lim+2:end)=0;
    %         % cut of everysting above lo_pass Hz
    lim=round((lo_pass/frequency)*length(y));
    y(lim:end-lim+1)=0;
    fildata(i,:)=real(ifft(y));
end
