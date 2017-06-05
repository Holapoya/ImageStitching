function [r] = residual(x0)
    r = [(1000 - x0(1))^2  (50 - x0(2))^2  (1 - x0(3))^2];
end
