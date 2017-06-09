function result = PlotSIFT(I, loc)
    %imshow(I);
    result = insertMarker(I, loc, 'x', 'color', [255 0 0], 'size', 3);
    imshow(result);
end