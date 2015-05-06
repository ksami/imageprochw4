function [affineLKContext] = initAffinePyramidLKTracker(imgScaled, mskScaled)
% The function will input a greyscale image (img) along with a logical mask image
% (msk) that is the same size as img. The mask is true at pixels that lie inside the
% user defined bounding box and are hence part of the tracking template and is false
% everywhere else.
% The function should output a MATLAB structure affineLKContext that contains the
% Jacobian of the affine warp with respect to the 6 affine warp parameters and the
% inverse of the approximated Hessian matrix (J and inv(H) in Equation 11).

% load img and test
% load('../data/initTest.mat');
% 
% testJ = affineLKContext.Jacobian;

img = imgScaled{3};
msk = mskScaled{3};

[row, col] = size(img);
J = zeros([row*col,6]);

[row, col] = size(img);

T = img .* msk;
[Tx, Ty] = gradient(T);

i=1;

for x = 1:row
    for y = 1:col
        J(i,:) = [Tx(i), Ty(i)]*[ x 0 y 0 1 0;0 x 0 y 0 1];
        i = i+1;
    end
end

H = J' * J;

affineLKContext.Jacobian = J;
affineLKContext.HessianInv = inv(H);

% res = testJ - J;