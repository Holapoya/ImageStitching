% x0 = [0 0 0];
% 
% residual(x0);
% options = optimoptions('lsqnonlin','Display','iter', 'JacobPattern', [1 0 1; 1 0 1; 1 0 1]);
% x = lsqnonlin(@residual, x0, [], [], options); 
% x

a = Bundler(0.85, 5000, 1, [25 56]);
a.AddCamera([1 2 3], 1);
a.x0
 
