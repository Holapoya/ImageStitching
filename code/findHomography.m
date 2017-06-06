function [Homography, Dist] = findHomography(pt1, pt2, maxIter)
%
%   Find Homography for correspondence using ransac
%   pt1/pt2 is n x 2 matrix
%

    n = size(pt1, 1);
    indice = 1:n;
    best_dist = 1000;
    best_H = 0;
    pt1_homo_T = toHomogeneous(pt1)';
    %pt2_homo_T = toHomogeneous(pt2)';
    for it = 1:maxIter
        sample_indice = randsample(indice, 4);
        sampple_pt1 = pt1(sample_indice, :);  
        sampple_pt2 = pt2(sample_indice, :);
        H = solveHomography(sampple_pt1, sampple_pt2);
        align_result = (H * pt1_homo_T)';
        align_result(:, 1) = align_result(:, 1) ./ align_result(:, 3);
        align_result(:, 2) = align_result(:, 2) ./ align_result(:, 3);
        align_result = align_result(:, 1:2);
        dist = sum(sqrt(sum((align_result - pt2).^2))) / n;
        if dist < best_dist
            best_dist = dist;
            best_H = H;
        end
    end
    Homography = best_H;
    Dist = best_dist;
end
function [H] = solveHomography(pt1, pt2)
%
%   pt1/pt2 is 4 x 2 matrix
%
    pt1_homo = toHomogeneous(pt1);
    pt2_homo = toHomogeneous(pt2);
    %H_t = (pt1_homo) \ (pt2_homo);
    %H = H_t';
    %H(3, :) = [0 0 1];
    
    pt2_homo(:, 3) = 0;
    b = reshape(pt2_homo', [1, 12])';
    A = zeros([12, 8]);
    for i=1:4
        A(3 * (i-1) + 1, 1:3) = pt1_homo(i, :);
        A(3 * (i-1) + 2, 4:6) = pt1_homo(i, :);
        A(3 * (i-1) + 3, 7:8) = pt1_homo(i, 1:2);
    end
    x = A\b;
    H = reshape([x', 1], [3, 3])';
    
end