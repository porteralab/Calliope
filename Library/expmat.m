function y = expmat(b, m)
% expand a matrix from b = [1 2; 3 4];
% to
% 1 1 1 2 2 2
% 3 3 3 4 4 4
% inputs:
%         b: your input matrix
%         m: number of repetitions per element in the matrix
% doc edited by AF, 08.05.2014

y = reshape(repmat(b',1,m)', length(b(:,1)), m*length(b(1,:)));
end

