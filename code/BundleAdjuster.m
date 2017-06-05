classdef BundleAdjuster < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ncameras % n images
        npoints % n observation
        Homography % H12, H23, H34 .....
        Matches % [x1 y1 x2 y2]....
        CameraIndice1
        CameraIndice2
        x0
    end
    
    methods
        function obj = BundleAdjuster()
            obj.ncameras = 0;
            obj.npoints = 0;
            obj.Homography = {};
            obj.Matches = [];
            obj.CameraIndice1 = [];
            obj.CameraIndice2 = [];
        end
        
        function AddShot(obj, H)
            if ~isempty(H)
                obj.Homography{obj.ncameras} = H;
            end
            obj.ncameras = obj.ncameras + 1;
        end
        
        function AddObservation(obj, loc1, loc2, shot_id1, shot_id2)
            %
            % loc1 and loc2 is N x 2 vector
            %
            count = size(loc1, 1);
            obj.npoints = obj.npoints + count;
            tmp = zeros([1 count]);
            obj.Matches = [obj.Matches; [loc1 loc2]];
            tmp(:) = shot_id1;
            obj.CameraIndice1 = [obj.CameraIndice1 tmp];
            tmp(:) = shot_id2;
            obj.CameraIndice2 = [obj.CameraIndice2 tmp];
        end
        
        function FinishAddShot(obj)
            obj.x0 = zeros([1 (obj.ncameras - 1) * 8]);
            for i = 1:(obj.ncameras - 1)
                H = reshape(obj.Homography{i}', [1 9]);
                obj.x0( 1 + (i-1) * 8 : 8 + (i-1) * 8) = H(1:8);
            end
        end
        
        function FinishAddObservation(obj)
            
        end
        
        function updateHomography(obj, x0) 
            for i = 1:(obj.ncameras-1)
                H = ones([1 9]);
                H(1:8) = x0(1 + (i-1)*8: 8 + (i-1)*8);
                H = (reshape(H, [3 3]))';
                obj.Homography{i} = H;
            end
        end
        
        function T = getTransform(obj, x0)
            T = cell(1, obj.ncameras);
            T{1} = eye(3);
            %buf = reshape(x0, [3 (obj.ncameras-1)*8])';
            for i = 2:obj.ncameras
                idx = i - 1;
                H = ones([1 9]);
                H(1:8) = x0( 1 + (idx - 1) * 8 : 8 + (idx - 1) * 8);
                H = reshape(H, [3 3])';
                if idx >= 2
                    H = T{idx} * H;
                end
                T{i} = H;
            end
        end
        
        function Run(obj)
            func = @(x0)Error(x0, obj);
            %options = optimoptions('lsqnonlin','Display','iter');
            options = optimoptions('lsqnonlin','Display','iter', 'MaxFunEvals', 1000000, 'MaxIter', 100000);
            obj.x0 = lsqnonlin(func, obj.x0, [], [], options);
            obj.updateHomography(obj.x0);
        end
    end
end

function E = Error(x0, bundle)
    T = bundle.getTransform(x0); % get transfformation relation for new x0
    npoints = bundle.npoints;
    indice1 = bundle.CameraIndice1;
    indice2 = bundle.CameraIndice2;
    
    loc1 = (toHomogeneous(bundle.Matches(:,1:2)))';
    loc2 = (toHomogeneous(bundle.Matches(:,3:4)))';
    
    new_loc1 = zeros([npoints 3]);
    new_loc2 = zeros([npoints 3]);
    for camera = 1:bundle.ncameras
        H = T{camera};
        idx1 = (indice1 == camera);
        idx2 = (indice2 == camera);
        new_loc1(idx1, :) = (H * loc1(:, idx1))';
        new_loc1(idx1, 1) = new_loc1(idx1, 1) ./ new_loc1(idx1, 3); 
        new_loc1(idx1, 2) = new_loc1(idx1, 2) ./ new_loc1(idx1, 3);
        
        new_loc2(idx2, :) = (H * loc2(:, idx2))';
        new_loc2(idx2, 1) = new_loc2(idx2, 1) ./ new_loc2(idx2, 3); 
        new_loc2(idx2, 2) = new_loc2(idx2, 2) ./ new_loc2(idx2, 3);
    end
    E = sqrt(sum((new_loc1(:, 1:2) - new_loc2(:, 1:2)).^2, 2));
end

