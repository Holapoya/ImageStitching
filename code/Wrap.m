clear;
img_path = '../img/';
path = dir([img_path '*.png']);
n = length(path);

IMG_LST = cell(1, n);
IMG = cell(1, n);
IMG_KEY_POINT = cell(1, n);
IMG_DESCRIPTOR = cell(1, n);
for i = 1:n
    name = [img_path path(i).name];
    IMG_LST{1, i} = name;
    img = imread(name);
    IMG{i} = img;
    img = im2single(rgb2gray(img));
    [loc, des] = vl_sift(img);
    loc = loc';
    des = des';
    loc = loc(1:end, 1:2);
    IMG_KEY_POINT{i} = loc;
    IMG_DESCRIPTOR{i} = des; 
end

[loc1, loc2] = SIFTMatch(IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2}, IMG_KEY_POINT{3}, IMG_DESCRIPTOR{3});
PlotMatch(IMG{2}, IMG{3}, loc1, loc2);









