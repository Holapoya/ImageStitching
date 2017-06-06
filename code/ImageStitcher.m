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
            i = 1;
            img = obj.IMG{i};
            t = maketform('projective', obj.T{i}');
            result = imtransform(im2single(img), t, 'bicubic', ...
            'XData', [min_x_y(1) max_x_y(1)], 'YData', [min_x_y(2) max_x_y(2)], 'FillValues', NaN, 'XYScale', 1);
            
            for i = 2:obj.ncamera
                img = obj.IMG{i};
                t = maketform('projective', obj.T{i}');
                img = imtransform(im2single(img), t, 'bicubic', ...
                'XData', [min_x_y(1) max_x_y(1)], 'YData', [min_x_y(2) max_x_y(2)], 'FillValues', NaN, 'XYScale', 1);
                result_mask = ~isnan(result(:, :, 1));
                temp_mask = ~isnan(img(:, :, 1));
                plot_mask = temp_mask & (~result_mask);
                
                for ch = 1:3
                    result_ch = result(:, :, ch);
                    temp_ch = img(:, :, ch);
                    result_ch(plot_mask) = temp_ch(plot_mask);
                    result(:, :, ch) = result_ch;
                end
            end
            result(isnan(result)) = 0;
        end
    end
end

