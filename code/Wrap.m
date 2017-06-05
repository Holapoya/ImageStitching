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
    [~, idx, ~] = unique(loc, 'rows', 'stable');
    loc = loc(idx, :);
    des = des(idx, :);
    IMG_KEY_POINT{i} = loc;
    IMG_DESCRIPTOR{i} = des; 
end
      
%  [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{1}, IMG_DESCRIPTOR{1}, IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2});
%  PlotMatch(IMG{1}, IMG{2}, loc1, loc2);  
%  error('gg')

% %ref_index = round((1 + n) / 2);
% [H, d] = findHomography(loc1, loc2, 1000)  
npoints = 0;
tic
for ref = 1:(n-1)
    for from = (ref+1):n
        try
            [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{ref}, IMG_DESCRIPTOR{ref}, IMG_KEY_POINT{from}, IMG_DESCRIPTOR{from});
            if size(loc1, 1) > 15
                npoints = npoints + size(loc1, 1);
            end
        end
    end
end
toc
s = [517 388];
f = 0.85 * s(1);
cen = round((1 + s) / 2);
bundle = Bundler(f, n, npoints, cen);
[loc1, loc2] = SIFTMatch(IMG_KEY_POINT{1}, IMG_DESCRIPTOR{1}, IMG_KEY_POINT{2}, IMG_DESCRIPTOR{2});
H_id = 1;
%init_H = findHomography(loc1, loc2, 1000)
%error
R1 = ([0.1 0.1 0.1]);
R2 = ([0.2 0.1 0.1]);
bundle.AddCamera(R1, 1);
bundle.AddCamera(R2, 2);
  
%error('ff') 
for ref = 1:(n-1)
    for from = (ref+1):n
        try
            [loc1, loc2] = SIFTMatch(IMG_KEY_POINT{ref}, IMG_DESCRIPTOR{ref}, IMG_KEY_POINT{from}, IMG_DESCRIPTOR{from});
            if size(loc1, 1) > 15
                for i = 1:size(loc1, 1)
                    bundle.AddObservation(loc1(i,:), loc2(i,:), ref, from, H_id);
                end
            end
        end
        H_id = H_id + 1;
    end
end
bundle.Run();
% H_index = bundle.H_index
% npoints = bundle.npoints 
% bundle.jacobian_sparsity













