function [match_loc1, match_loc2] = SIFTMatch(loc1, des1, loc2, des2)
    pairs = matchFeatures(des1, des2);
    [~, idx, ~] = unique(pairs(1:end, 2), 'stable'); 
    pairs = pairs(idx, :);
    match_loc1 = loc1(pairs(1:end, 1), 1:2);
    match_loc2 = loc2(pairs(1:end, 2), 1:2);
%     try
%         [F,inliersIndex] = estimateFundamentalMatrix(match_loc1, match_loc2);
%         match_loc1 = match_loc1(inliersIndex, :);
%         match_loc2 = match_loc2(inliersIndex, :);
%     end
end