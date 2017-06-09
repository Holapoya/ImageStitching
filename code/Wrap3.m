clear;
a = 'test13';
img_path = ['../img/' a '/'];
path = dir([img_path '*.jpg']);
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
%[loc1, loc2] = SIFTMatch(IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2}, IMG_KEY_POINT{3}, IMG_DESCRIPTOR{3});
%PlotMatch(IMG{2}, IMG{3}, loc1, loc2);
%error
H = {};
for i = 2:n
    IMG_LST{i}
    bundle = BundleAdjuster();
    bundle.AddShot([]); % add ref image
    for j = 2:(i - 1)
        bundle.AddShot(H{j - 1});
    end
    if true
        [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{i-1}, IMG_DESCRIPTOR{i-1}, IMG_KEY_POINT{i}, IMG_DESCRIPTOR{i});
    else
        [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{1}, IMG_DESCRIPTOR{1}, IMG_KEY_POINT{i}, IMG_DESCRIPTOR{i});
    end
    [H, ~] = findHomography(loc2, loc1, 10000);
    bundle.AddShot(H);
    bundle.FinishAddShot();
    for ref = 1:(i-1)
        for from = (ref+1):i
            try
                [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{ref}, IMG_DESCRIPTOR{ref}, IMG_KEY_POINT{from}, IMG_DESCRIPTOR{from});
                %bundle.AddObservation(loc1, loc2, ref, from);
                if size(loc1, 1) >= 10
                    bundle.AddObservation(loc1, loc2, ref, from);
                end
            end
        end
    end
    bundle.FinishAddObservation(); 
    bundle.Run();
    H = bundle.Homography;
end

T = bundle.getTransform(bundle.x0); 
save('T.mat', 'T');

%tmp = load('T.mat');
%T = tmp.T;
sz = size(IMG{1});
stitch = ImageStitcher(sz(1), sz(2));
for i = 1:n
    stitch.AddShot(IMG{i}, T{i});
end

img = stitch.Stitch();

imshow(img)

imwrite(img, ['../result/result_' a '.png'])










