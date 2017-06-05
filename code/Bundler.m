classdef Bundler < handle
    properties
        focal;
        nameras;
        npoints;
        x0;
        H_index;
        Matches;
        jacobian_sparsity;
        center;
        pt_id;
        camera_indice1;
        camera_indice2;
    end
    
    methods
        function obj = Bundler(f, ncamera, npoint, center)
            obj.focal = f;
            obj.nameras = ncamera;
            obj.npoints = npoint;
            obj.x0 = zeros([1 (1 + 3 * ncamera)]);
            obj.x0(1) = f;
            obj.H_index = zeros([1, npoint]);
            obj.center = center;
            obj.Matches = zeros([npoint 4]);
            obj.pt_id = 1;
            
            obj.jacobian_sparsity = sparse(npoint, 1 + 3 * ncamera);
            obj.camera_indice1 = zeros([1, npoint]);
            obj.camera_indice2 = zeros([1, npoint]);
        end
        function AddCamera(obj, R, index)
            if index > obj.nameras
                error('Camera index out of bound');
            end
            obj.x0(2 + (index-1) * 3: 1 + index * 3) = R(:);
        end
        function AddObservation(obj, pt1, pt2, camera1, camera2, H_id)
            obj.Matches(obj.pt_id, :) = [pt1 pt2];
            obj.H_index(obj.pt_id) = H_id;
            obj.camera_indice1(obj.pt_id) = camera1;
            obj.camera_indice2(obj.pt_id) = camera2;  
            obj.pt_id = obj.pt_id + 1;
        end
        function H = updateHomography(obj, x0)
            f = x0(1);
            H_id = 1;
            H = {};
            for ref = 1:(obj.nameras - 1)
                R1 = x0(2 + (ref-1) * 3: 1 + ref * 3);
                for from = (ref + 1):obj.nameras
                    R2 = x0(2 + (from-1) * 3: 1 + from * 3);
                    H{H_id} = computeHomography(f, R1, R2, obj.center);
                    H_id = H_id + 1; 
                end
            end
        end
        function Run(obj)
            index = 1:obj.npoints;
            indice1 = obj.camera_indice1;
            indice2 = obj.camera_indice2;     
            for i = 0:2
                obj.jacobian_sparsity(index, 2 + (indice1 - 1)*3 + i) = 1;
                obj.jacobian_sparsity(index, 2 + (indice2 - 1)*3 + i) = 1;
            end
            obj.jacobian_sparsity(:, 1) = 1;
            obj.jacobian_sparsity(:, 2:4) = 0;
            %obj.jacobian_sparsity
            %error('yh')
            func = @(x0)Residual(x0, obj);
            %func(obj.x0)
            
            options = optimoptions('lsqnonlin','Display','iter', 'MaxFunEvals', 1000000, 'MaxIter', 100000, 'JacobPattern', obj.jacobian_sparsity);
            %options = optimoptions('lsqnonlin', 'JacobPattern', obj.jacobian_sparsity);
            %options = optimoptions('lsqnonlin','Display','iter');
            obj.x0 = lsqnonlin(func, obj.x0, [], [], options);
            obj.x0
           %func(obj.x0)
        end
    end
end
function H = computeHomography(f, vec1, vec2, center) % homography of img2 to img1
    vec1 = vec1 / norm(vec1);
    vec2 = vec2 / norm(vec2);
    vec1(isnan(vec1)) = 0;
    vec2(isnan(vec2)) = 0;
    K = [f 0 center(1); 0 f center(2); 0 0 1];
    %error('gg')
    %R1 = Rodrigues(vec1);
    %R2 = Rodrigues(vec2);
    R1 = zeros([3 3]);
    R2 = zeros([3 3]);
    R1(1, 2) = -1 * vec1(3);
    R1(1, 3) = vec1(2);
    R1(2, 1) = vec1(3);
    R1(2, 3) = -1 * vec1(1);
    R1(3, 1) = -1 * vec1(2);
    R1(3, 2) = vec1(1);
    
    R2(1, 2) = -1 * vec2(3);
    R2(1, 3) = vec2(2);
    R2(2, 1) = vec2(3);
    R2(2, 3) = -1 * vec2(1);
    R2(3, 1) = -1 * vec2(2);
    R2(3, 2) = vec2(1);
    
    R1 = exp(R1);
    R2 = exp(R2);
    H = K * R1 * R2' * inv(K);
end

function R = Residual(x0, bundle)
%
%   point is N x 4 matrix [x1 y1 x2 y2]
%   H_index is the index of homography
%   
    
    H_index = bundle.H_index;
    H_all = bundle.updateHomography(x0);
    %bundle.H{1}
    max_id = max(H_index);
    pt1 = (toHomogeneous(bundle.Matches(:, 1:2)))';
    pt2 = (toHomogeneous(bundle.Matches(:, 3:4)))';
    r = zeros([bundle.npoints 3]);
    for i = 1:max_id
        H = H_all{i};
        indice = (H_index == i);
        r(indice, :) = (H * pt2(:, indice) - pt1(:, indice))';
    end
    r(:, 1) = r(:, 1) ./ r(:, 3);
    r(:, 2) = r(:, 2) ./ r(:, 3);
    R = sqrt(r(:, 1).^2 + r(:, 2).^2);
end
