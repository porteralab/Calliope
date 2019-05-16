function result = register_MI(refIM, floatIM, varargin)
% 2-D rigid body Image registration using mutual information.
% Rigid body 2-D image co-registration (translation and rotation) is performed
% using maximization of mutual information.
%
% For single frames only. Frames have to be at least 256*256 px, otherwise Matlab is
% going to crash. Compiled mex for Win7 64bit (Matlab 2010b - but might
% work also for other Matlab versions).
% download and install at least Visual C++ 2010 Express: http://www.microsoft.com/visualstudio/en-us/products/2010-editions/visual-cpp-express
% or recompile mi_hpv_2d.cpp
%
% Input:
%
%   Reference Image: image that will be compared too.  Must be uint8.  Take
%   care to scale image properly.
%
%   Floating Image: image that will be rotated and translated.  Must be
%   uint8.  Take care to scale image properly.
%
% Output:
%
%   parameters: 3x1 Array with the form [DeltaX  DeltaY  DeltaTheta].
%   Theta is counterclockwise in-plane rotation in radians.  DeltaX/Y
%   are translations in pixels.
%
%   xy: Optional output.  8x1 Array with the x and y coordinates of the
%   corners of the output matix.
%
%   xy_0: Optional output.  8x1 Array with the x and y coordinates of the
%   corners of the input matrix.

returnFloatIM = 0;

if ~isempty(varargin)
    numIndex = find(cellfun('isclass', varargin(1:end-1), 'char'));
    for ind = 1:length(numIndex)
        switch lower(varargin{numIndex(ind)})
            case 'returnfloatim'   % if true gives registered image back
                returnFloatIM = varargin{numIndex(ind) + 1};
        end
    end
end

result = struct;

dim = size(refIM);
dim = [dim size(floatIM)];

if min(dim) < 256
    error('Images have to be at least 256*256px. Otherwise Matlab crashes!')
end


[para, xy, xy_0] = mi_hpv_2d(refIM,floatIM);  % image registration
result.para = para;
result.xy = reshape(xy,[2 4])';
result.xy_0 = reshape(xy_0,[2 4])';

if returnFloatIM
    T = maketform('projective',result.xy_0,result.xy);
    R = makeresampler('cubic','replicate');
    result.coregIM = tformarray(floatIM,T,R,[1 2],[1 2],[size(refIM,1) size(refIM,2)],[],[]);
end

