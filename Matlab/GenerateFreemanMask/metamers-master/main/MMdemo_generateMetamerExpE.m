close all;clear all; clc;

load(['../../../ImageStatsHuman_val_50_filtered.mat']);

%one might need to manually add directory and subdirectories into path
addpath(genpath(['../../metamers-master/']));
addpath('../matlabPyrTools');

imgpath = ['../../../Stimulus/img/img_']; %path for raw images
saveimgpath = '../../../Stimulus/img_metamer/'; %save generated PortillaMask

NumImg = length(ImageStatsFiltered);


squares = 512; %use author's default parameters

for imgnum = 1430: NumImg

    display(['processing image number: ' num2str(imgnum) ]);
    
    node = ImageStatsFiltered(imgnum);
    
    imgorifullname = ['../../../Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    %imgbinfullname = ['../Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    
    im0 = imread(imgorifullname);	% im0 is a double float matrix! 
    
    if length(size(im0))==3
        im0 = rgb2gray(im0);
    end
    
    im0 = imresize(im0,[squares squares]);
    
    ori = im0;
    oim = double(im0);
    sizeim0 = size(im0);
    sizeim0 = sizeim0(1:2);

    % set options
    opts = metamerOpts(oim,'printing = 0','windowType=square','nSquares=[3 1]','nIters=3');

    % make windows
    m = mkImMasks(opts);

    % plot windows
    plotWindows(m,opts);

    % do metamer analysis on original (measure statistics)
    params = metamerAnalysis(oim,m,opts);

    % do metamer synthesis (generate new image matched for statistics)
    res = metamerSynthesis(params,size(oim),m,opts);
    res = uint8(res);
    
    %res = mat2gray(res);
    res = imresize(res,sizeim0);
    imwrite(res,[saveimgpath 'img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg']);
    %pause;
end
close all;