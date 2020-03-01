close all

addpath('matlabPyrTools');

imgpath = '../../WriteGIFKarla/data/'; %path for raw images
saveimgpath = '../../WriteGIFKarla/PortillaMask/'; %save generated PortillaMask
imgorilist = dir([imgpath '*_Original.jpg']);
NumImg = length(imgorilist);


%%% do NOT change these parameters %%%%
Nsc = 4; % Number of scales
Nor = 4; % Number of orientations
Na = 9;  % Spatial neighborhood is Na x Na coefficients
	 % It must be an odd number!
Niter = 25;	% Number of iterations of synthesis loop
Nsx = 192;	% Size of synthetic image is Nsy x Nsx
Nsy = 128;	% WARNING: Both dimensions must be multiple of 2^(Nsc+2)

squares = 512; %use author's default parameters

for imgnum = 1: NumImg

    display(['processing image number: ' num2str(imgnum) ]);
    
    imgorifullname = [imgpath imgorilist(imgnum).name ];
    im0 = imread(imgorifullname);	% im0 is a double float matrix!
    im0 = rgb2gray(im0);
    ori = im0;
    sizeim0 = size(im0);
    im0 = imresize(im0,[squares squares]);
    im0 = double(im0);

    params = MMtextureAnalysis(im0, Nsc, Nor, Na);
    res = MMtextureSynthesis(params, [Nsy Nsx], Niter);

    res = imresize(res,sizeim0);
    res = mat2gray(res);

    % close all
    % figure(1)
    % imshow(ori);
    % 
    % figure(2)
    % imshow(res);
    
    imwrite(res,[saveimgpath imgorilist(imgnum).name(1:end-13) '_PMask.jpg']);

end
close all;