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
    loc = round(loc(1:end, 1:2));
    [~, idx, ~] = unique(loc, 'rows', 'stable');
    loc = (loc(idx, :));
    des = des(idx, :);
    IMG_KEY_POINT{i} = loc;
    IMG_DESCRIPTOR{i} = des; 
end

[loc1, loc2] = SIFTMatch(IMG_KEY_POINT{1}, IMG_DESCRIPTOR{1}, IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2});
[H, D] = findHomography(loc1, loc2, 1000);
[height, width, ~] = size(IMG{1});
[X, Y] = meshgrid(1:width, 1:height);
X = reshape(X, [height * width 1]);
Y = reshape(Y, [height * width 1]);
posMat = zeros([height * width 2]);
posMat(:, 1) = X;
posMat(:, 2) = Y;
 
homo_pos = toHomogeneous(posMat);
map_pos = (H * homo_pos')';
map_pos(:, 1) = map_pos(:, 1) ./ map_pos(:, 3);
map_pos(:, 2) = map_pos(:, 2) ./ map_pos(:, 3);
map_pos = round(map_pos(:, 1:2));
mx_loc = max([posMat; map_pos]);
max_x = mx_loc(1);
max_y = mx_loc(2);
offset = min(map_pos);
offset_x = offset(1);
offset_y = offset(2);
if offset_x <= 0
    offset_x = -1 * offset_x + 1;
else
    offset_x = 0;
end
if offset_y <= 0
    offset_y = -1 * offset_y + 1;
else
    offset_y = 0;
end

map_pos(:, 1) = map_pos(:, 1) + offset_x;
map_pos(:, 2) = map_pos(:, 2) + offset_y;
pos = posMat;
pos(:, 1) = pos(:, 1) + offset_x;
pos(:, 2) = pos(:, 2) + offset_y;

new_width = max_x + offset_x;
new_height = max_y + offset_y;

img = zeros([new_height, new_width, 3]);


tmp = IMG{1};
for i = 1:size(map_pos, 1)
    img(map_pos(i, 2), map_pos(i, 1), :) = tmp(posMat(i, 2), posMat(i, 1), :);
end 
tmp = IMG{2};
for i = 1:size(pos, 1)
    img(pos(i, 2), pos(i, 1), :) = tmp(posMat(i, 2), posMat(i, 1), :);
end
 
imshow(uint8(img))
        












