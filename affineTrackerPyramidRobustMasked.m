function Wout = affineTrackerPyramidRobustMasked(img, tmpScaled, maskScaled, Win, context)
% The function will input a greyscale image of the current frame (img),
% the template image (tmp), the logical mask (msk) that marks out the 
% template region in tmp, the affine warp matrix for the previous frame (Win)
% and the precomputed J and inv(H) matrices context.
% The function should output the 3x3 matrix Wout that contains the new
% affine warp matrix updated so that it aligns the current frame with the template.

threshold = 1;
mag = 100;

Hinv = context.HessianInv;
J = context.Jacobian;

imgScaled = cell(3, 1);
imgScaled{1} = img;

for ii=2:3
    imgScaled{ii} = imresize(imgScaled{ii-1}, 0.5,'bilinear');
end

for level=3:-1:1
    % choose level of pyramid
    img = imgScaled{level};
    tmp = tmpScaled{level};
    mask = maskScaled{level};
    
    % scale for brightness
    avgTmp = mean(tmp(:));
    avgImg = mean(img(:));
    scalingFactor = avgImg/avgTmp;
    tmp = tmp * scalingFactor;
    
    % apply mask
    T = tmp .* mask;

    while mag > threshold
        Iw = warpImageMasked(img, Win, mask);
        error = T - Iw;
        deltaP = Hinv * J' * error(:);
        Win = Win / [1+deltaP(1), deltaP(3), deltaP(5);
                     deltaP(2), 1+deltaP(4), deltaP(6);
                     0,0,1];
        mag = norm(deltaP);
    end

    Wout = inv(Win);
end