clear;
img_path = '../img/test5/';
path = dir([img_path '*.png']);
n = length(path);

IMG_LST = cell(1, n);
IMG = cell(1, n);
IMG_KEY_POINT = cell(1, n);
IMG_DESCRIPTOR = cell(1, n);
for i = 1:n
    name = [img_path path(i).name];
    IMG_LST{1, i} = name;
end
NEW_IMG_LST = cell(1, n);
cen = round((1 + n) / 2);
j = 1;
for i = cen:n
    NEW_IMG_LST{j} = IMG_LST{i};
    j = j + 1;
end
for i = (cen-1):-1:1
    NEW_IMG_LST{j} = IMG_LST{i};
    j = j + 1;
end
for i = 1:n
    name = IMG_LST{i};
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
%[loc1, loc2] = SIFTMatch(IMG_KEY_POINT{1}, IMG_DESCRIPTOR{1}, IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2});
%PlotMatch(IMG{1}, IMG{2}, loc1, loc2)
H = {};
bundle = BundleAdjuster();
bundle.AddShot([]); % add ref image
for i = 2:n
    IMG_LST{i}
    [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{i-1}, IMG_DESCRIPTOR{i-1}, IMG_KEY_POINT{i}, IMG_DESCRIPTOR{i});
    [H, ~] = findHomography(loc2, loc1, 1000);
    bundle.AddShot(H);
end
bundle.FinishAddShot();
T = bundle.getTransform(bundle.x0);

sz = size(IMG{1});
stitch = ImageStitcher(sz(1), sz(2));
for i = 1:n
    stitch.AddShot(IMG{i}, T{i});
end

img = stitch.Stitch();

imshow(img)

imwrite(img, 'result.png')










