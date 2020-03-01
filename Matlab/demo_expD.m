clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

% QR configure
qrsize = 97;
addpath('qr_code');
javaaddpath('jar/core-3.3.0.jar');
javaaddpath('jar/javase-3.3.0.jar');
expType = 'expD';

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
ScreenWidth = 1024;
ScreenHeight = 1280; 
exptime = [500 1000 200 100]; %in millisecs
cf = 100; %this is the greatest common factor of experiment time

blurlist = [2 4 8 16 32];

boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expD'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype '_gif']);
mkdir([keyframetype]);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    
    %only process visual bin 1, 2, 3 images; to save time
%     if node.bin == 4 || node.bin == 1
%         continue; 
%     end
    
    imgorifullname = ['Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    if exist(imgorifullname, 'file') ~= 2 || exist(imgbinfullname, 'file') ~= 2
        warning(['either binary or original image missing']);
        continue;
    end
    
    display(['processing image: ' num2str(imgnum)]);
    
    %% Image read in; pre-processing
    img = imread(imgorifullname);
    if length(size(img))~=3
        img = cat(3, img, img, img);
    end
    
    %bbox
    type2img = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_2.jpg']);
    %full context
    type8img = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_8.jpg']);
    %screen2 with bbox location and fixation cross
    screen2 = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1.jpg']);
    %fixation cross in the center
    screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
    %purely gray background
    screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
    imgbin = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarycontour.jpg']);
    
    % extract bounding box; x is horinzontal axis; y is vertical axis; (0,0) is
    % at top left corner of the image
    [row, col] = find(imgbin(:,:,1)==1);
    leftx = min(col);lefty = min(row);rightx = max(col);righty = max(row);
    ctrx = floor((leftx + rightx)/2);ctry = floor((lefty + righty)/2);
    oh = rightx - leftx;
    ow = righty - lefty;
    
    imgbin = double(im2bw(imgbin));    
    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    counter = 1; %keep track of gif types
    
    %%%% subcategory: bbox wo mask    
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1, screen2, type2img, screen3, exptime, namegif,cf,keyframetype, repeat);
    counter = counter + 1;
    
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1, screen2, type8img, screen3, exptime, namegif,cf,keyframetype, repeat);
    counter = counter + 1;
    
    type8img = double(type8img);
    
    %blurry sigma (standard deviation)
    for blur = blurlist
        blurtype8 = double(imgaussfilt(type8img, blur));
        
        for channel = 1:3
            %ensure bbox is still clear
            blurtype8(:,:,channel) = blurtype8(:,:,channel).*(imgbin)+ type8img(:,:,channel).*(1-imgbin);
        end
    
        blurtype8 = uint8(blurtype8);
        
        blurtype8 = insertShape(blurtype8 ,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
    
        imwrite(blurtype8,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_blur.jpg']);
        
        %imshow(blurtype8);pause;
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        fcn_WriteGIF(screen1, screen2, blurtype8, screen3, exptime, namegif,cf,keyframetype, repeat);
        counter = counter + 1;
    end
    
    display(['writing gif complete']);
end