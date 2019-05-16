function xcorr_TA = fft_xcorr(T,A,high_pass_thresh,low_pass_thresh)
% FFT_XCORR calculates the xcorr between T and A using fourier transofrms.
% T and A are bandpass filtered to remove influence of low (DC & aperature
% effects) and high (noise) frequencies.

T_size = size(T);
A_size = size(A);
outsize = A_size + T_size - 1;

% use default filter values if none provide, values are heuristic and
% filters for objects 2-20% of total image size
if nargin<3
    low_pass_thresh=round(min(T_size)/5);
    high_pass_thresh=round(min(T_size)/30);
end

% fourier transform both template and 
Fa = fft2(rot90(T,2),outsize(1),outsize(2));
Fb = fft2(A,outsize(1),outsize(2));

% Filter the imagesc before calculating the cross correlation
Fa(low_pass_thresh+2:end-low_pass_thresh,:)=0;
Fa(:,low_pass_thresh+2:end-low_pass_thresh)=0;
Fa([1:high_pass_thresh size(Fa,1)-high_pass_thresh+2:size(Fa,1)],:)=0;
Fa(:,[1:high_pass_thresh size(Fa,2)-high_pass_thresh+2:size(Fa,2)])=0;

Fb(low_pass_thresh+2:end-low_pass_thresh,:)=0;
Fb(:,low_pass_thresh+2:end-low_pass_thresh)=0;
Fb([1:high_pass_thresh size(Fb,1)-high_pass_thresh+2:size(Fb,1)],:)=0;
Fb(:,[1:high_pass_thresh size(Fb,2)-high_pass_thresh+2:size(Fb,2)])=0;

% calculate the cross correlation (in fourier space convolution is a
% multibplication
xcorr_TA = real(ifft2(Fa .* Fb));


