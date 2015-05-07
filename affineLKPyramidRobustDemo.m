%folder containing data (a sequence of jpg images)
dirname = '../data/car';

%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.jpg', dirname));
nframes = numel(dirlist);

W = eye(3,3);
startFrame = 1;

%loop over the images in the video sequence
for i=startFrame:nframes
    
    %read a new image, convert to double, convert to greyscale
    img = imread(sprintf('%s/%s', dirname, dirlist(i).name));
    
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end
    
    img = double(img) / 255;
    
    %if this is the first image, this is the frame to mark a template on
    if (i == startFrame)
        %display the image and ask the user to click where the template is
        hold off;
        imshow(img);
        hold on;
        drawnow;
        title('Click on the upper left corner of the template region to track');
        [xt1 yt1] = ginput(1);
        title('Click on the lower right corner of the template region to track');
        [xt2 yt2] = ginput(1);
        
        yt1 = round(yt1); yt2 = round(yt2);
        xt1 = round(xt1); xt2 = round(xt2);
        
        template = img;
    
        %build a mask defining the extent of the template
        mask     = false(size(template));
        mask(yt1:yt2, xt1:xt2) = true;
        templateBox = [xt1 xt1 xt2 xt2 xt1; yt1 yt2 yt2 yt1 yt1];
        
        %initialize pyramid template, mask
        tmpScaled = cell(3,1);
        mskScaled = cell(3,1);
        tmpScaled{1} = template;
        mskScaled{1} = mask;

        for ii=2:3
            tmpScaled{ii} = imresize(tmpScaled{ii-1}, 0.5,'bilinear');
            mskScaled{ii} = imresize(mskScaled{ii-1}, 0.5,'bilinear');
        end
        
        %initialize the LK tracker for this template
        affineLKContext = initAffinePyramidRobustLKTracker(tmpScaled, mskScaled);
        
    end
    
    %actually do the LK tracking to update transform for current frame
    tic;   
    W = affineTrackerPyramidRobustMasked(img,tmpScaled,mskScaled,W,affineLKContext);
    ftime = toc;
    
    %draw the location of the template onto the current frame, display
    %stuff
    currentBox = W \ [templateBox; ones(1,5)];
    currentBox = currentBox(1:2,:);
    
    hold off;
    imshow(img);
    hold on;
    plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
    title(sprintf('frame #%g. %g FPS', i, 1./ftime));
    drawnow;
end