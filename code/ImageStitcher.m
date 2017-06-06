classdef ImageStitcher < handle
    
    properties
        IMG
        T
        height
        width
        ncamera
        mapPos
    end
    
    methods
        function obj = ImageStitcher(h, w)
            obj.height = h;
            obj.width = w;
            obj.ncamera = 0;
            obj.IMG = {};
            obj.T = {};
            obj.mapPos = {};
        end
        
        function AddShot(obj, img, H)
            obj.ncamera = obj.ncamera + 1;
            obj.IMG{obj.ncamera} = img;
            obj.T{obj.ncamera} = H;
        end
        
        function result = Stitch(obj)
            [X, Y] = meshgrid(1:obj.width, 1:obj.height);
            X = reshape(X, [obj.height * obj.width 1]);
            Y = reshape(Y, [obj.height * obj.width 1]);
            posMat = zeros([obj.height * obj.width 2]);
            posMat(:, 1) = X;
            posMat(:, 2) = Y;
            
            homo_pos = toHomogeneous(posMat);
            
            min_x_y = [0 0];
            max_x_y = [0 0];
            
            for i = 1:obj.ncamera
                H = obj.T{i};
                map_pos = (H * homo_pos')';
                map_pos(:, 1) = map_pos(:, 1) ./ map_pos(:, 3);
                map_pos(:, 2) = map_pos(:, 2) ./ map_pos(:, 3);
                map_pos = round(map_pos(:, 1:2));
                obj.mapPos{i} = map_pos;
                min_x_y = min([min_x_y; map_pos]);
                max_x_y = max([max_x_y; map_pos]);
            end
            if min_x_y(1) <= 0
                offset_x = -1 * min_x_y(1) + 1;
            else
                offset_x = 0;
            end
            if min_x_y(2) <= 0
                offset_y = -1 * min_x_y(2) + 1;
            else
                offset_y = 0;
            end
            
            new_width = max_x_y(1) + offset_x;
            new_height = max_x_y(2) + offset_y;
            
            result = zeros([new_height new_width 3]);
            for i = 1:obj.ncamera
                map_pos = obj.mapPos{i};
                map_pos(:, 1) = map_pos(:, 1) + offset_x;
                map_pos(:, 2) = map_pos(:, 2) + offset_y;
                
                image = obj.IMG{i};
                for j = 1:(obj.width * obj.height)
                    result(map_pos(j, 2), map_pos(j, 1), :) = image(posMat(j, 2), posMat(j, 1), :);
                end
            end
            
            result = uint8(result);
        end
    end
    
end

