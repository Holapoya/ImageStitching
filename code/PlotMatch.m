function PlotMatch(I1, I2, loc1, loc2)
    loc1 = round(loc1);
    loc2 = round(loc2);
    [height, width, ch] = size(I1);
    
    img = uint8(zeros([height, 2 * width, 3]));
    img(:, 1:width, :) = I1(:, :, :);
    img(:, width+1:end, :) = I2(:, :, :);
    loc2(:, 1) = loc2(:, 1) + width;
    imshow(img);
    
    for i = 1:size(loc1, 1)
        line([loc1(i, 1) loc2(i, 1)], [loc1(i, 2) loc2(i, 2)], 'Color', [1, 0, 0]);
    end
    
end