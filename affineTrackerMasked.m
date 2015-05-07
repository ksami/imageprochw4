function Wout = affineTrackerMasked(img, tmp, mask, Win, context)
% The function will input a greyscale image of the current frame (img),
% the template image (tmp), the logical mask (msk) that marks out the 
% template region in tmp, the affine warp matrix for the previous frame (Win)
% and the precomputed J and inv(H) matrices context.
% The function should output the 3x3 matrix Wout that contains the new
% affine warp matrix updated so that it aligns the current frame with the template.

threshold = 3;
mag = 100;

Hinv = context.HessianInv;
J = context.Jacobian;
T = tmp .* mask;

while mag > threshold
    Iw = warpImageMasked(img, Win, mask);
    error = T - Iw;
    deltaP = Hinv * J' * error(:);
    Win = Win / [1+deltaP(1), deltaP(3), deltaP(5);
                 deltaP(2), 1+deltaP(4), deltaP(6);
                 0, 0, 1];
    mag = norm(deltaP);
end

Wout = inv(Win);