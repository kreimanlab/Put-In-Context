close all; clear all; clc;

addpath('../textureSynth/matlabPyrTools');
addpath('../textureSynth/');

load(['../../ImageStatsHuman_val_50_filtered.mat']);

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);

keyframetype = '../../Stimulus/keyframe_expB'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype], 's');
% mkdir([keyframetype]);


%%% do NOT change these parameters %%%%
Nsx = 512;  % Synthetic image dimensions
Nsy = 512;

Nsc = 4; % Number of pyramid scales
Nor = 4; % Number of orientations
Na = 7; % Number of spatial neighbors considered for spatial correlations
Niter = 5; % Number of iterations of the synthesis loop

ScreenWidth = 1024;
ScreenHeight = 1280; 
ImageSize = 512; %256; %use author's default parameters
counter = 0;

for imgnum = 1: NumImg
    node = ImageStatsFiltered(imgnum);
    
    %only process visual bin 1 images; to save time
    if node.bin == 1 ||  node.bin == 4
        continue; 
    end
    
    imgorifullname = ['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    if exist(imgorifullname, 'file') ~= 2 
        warning(['either binary or original image missing']);
        continue;
    end
    
    display(['processing image: ' num2str(imgnum)]);
    
    %% Image read in; pre-processing
    img = imread(imgorifullname);
    if length(size(img))~=3
        img = cat(3, img, img, img);
    end
    img = imresize(img,[ImageSize ImageSize]);
    
    try
        imginput = double(img);
        [params] = textureColorAnalysis(imginput, Nsc, Nor, Na);
        mask = textureColorSynthesis(params, [Nsy Nsx], Niter);
        mask = imresize(mask, [ScreenWidth ScreenHeight]);
        %subplot(1,2,1);imshow(img);subplot(1,2,2);imshow(mask);pause;
        imwrite(mask,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_PortillaMask.jpg']);
    
    catch
        warning('whoops: texturecolor gives error');
        counter = counter + 1;
%         imginput = rgb2gray(img);
%         imginput = double(imginput);
%         params = MMtextureAnalysis(imginput, Nsc, Nor, Na);
%     	mask = MMtextureSynthesis(params, [Nsy Nsx], Niter);
%         imshow(mask); pause;
    end
    
end
display(['there are ' num2str(counter) ' imgs having function errors']);