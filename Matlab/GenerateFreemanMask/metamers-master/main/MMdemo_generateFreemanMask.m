close all

%one might need to manually add directory and subdirectories into path
addpath(genpath(['../../metamers-master/']));
addpath('../matlabPyrTools');

imgpath = '../../../WriteGIFKarla/data/'; %path for raw images
saveimgpath = '../../../WriteGIFKarla/FreemanMask/'; %save generated PortillaMask
imgorilist = dir([imgpath '*_Original.jpg']);
NumImg = length(imgorilist);


squares = 512; %use author's default parameters

for imgnum = 1: NumImg

    display(['processing image number: ' num2str(imgnum) ]);
    
    imgorifullname = [imgpath imgorilist(imgnum).name ];
    im0 = imread(imgorifullname);	% im0 is a double float matrix!
    im0 = rgb2gray(im0);
    ori = im0;
    sizeim0 = size(im0);
    im0 = imresize(im0,[squares squares]);
    oim = double(im0);

    % set options
    opts = metamerOpts(oim,'printing = 0','windowType=square','nSquares=[3 1]');

    % make windows
    m = mkImMasks(opts);

    % plot windows
    plotWindows(m,opts);

    % do metamer analysis on original (measure statistics)
    params = metamerAnalysis(oim,m,opts);

    % do metamer synthesis (generate new image matched for statistics)
    res = metamerSynthesis(params,size(oim),m,opts);

    % close all
    % figure(1)
    % imshow(ori);
    % 
    % figure(2)
    % imshow(res);
    res = mat2gray(res);
    res = imresize(res,sizeim0);
    imwrite(res,[saveimgpath imgorilist(imgnum).name(1:end-13) '_FMask.jpg']);

end
close all;