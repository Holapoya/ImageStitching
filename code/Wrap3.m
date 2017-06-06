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

% H = {};
% for i = 2:n
%     bundle = BundleAdjuster();
%     bundle.AddShot([]); % add ref image
%     for j = 2:(i - 1)
%         bundle.AddShot(H{j - 1});
%     end
%     [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{i-1}, IMG_DESCRIPTOR{i-1}, IMG_KEY_POINT{i}, IMG_DESCRIPTOR{i});
%     [H, ~] = findHomography(loc2, loc1, 10000);
%     bundle.AddShot(H);
%     bundle.FinishAddShot();
%     for ref = 1:(i-1)
%         for from = (ref+1):i
%             try
%                 [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{ref}, IMG_DESCRIPTOR{ref}, IMG_KEY_POINT{from}, IMG_DESCRIPTOR{from});
%                 if size(loc1, 1) > 40
%                     bundle.AddObservation(loc1, loc2, ref, from);
%                 end
%             end
%         end
%     end
%     bundle.FinishAddObservation(); 
%     bundle.Run();
%     H = bundle.Homography;
% end
% 
% T = bundle.getTransform(bundle.x0); 
% %save('T.mat', 'T');

tmp = load('T.mat');
T = tmp.T;
sz = size(IMG{1});
stitch = ImageStitcher(sz(1), sz(2));
for i = 1:n
    stitch.AddShot(IMG{i}, T{i});
end

img = stitch.Stitch();

%imshow(img)

imwrite(img, 'result.png')










