function [x] = toHomogeneous(p)
%
% p is N x 2 matrix, convert it to homogeneous coordinates
%
    n = size(p, 1);
    x = [p'; ones(1, n)]';
end