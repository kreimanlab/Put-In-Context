clear all; close all; clc;

%First Run GeneratePortillaMask/colorTextureSynth/MM_generatePortillaMask.m
%to generate masks

%Then Run this script to generate GIF files

%% for those missing mask, we randomly pick one mask from this list
maskList = dir(['Stimulus/keyframe_expB/trial_*.jpg']);

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

% QR configure
qrsize = 97;
addpath('qr_code');
javaaddpath('jar/core-3.3.0.jar');
javaaddpath('jar/javase-3.3.0.jar');
expType = 'expB';

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
ScreenWidth = 1024;
ScreenHeight = 1280; 
exptime = [500 1000 50 100; 500 1000 100 100; 500 1000 200 100]; %in millisecs
cf = [50 100 100]; %this is the greatest common factor of experiment time

boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expB_qr'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype '_gif'], 's');
% mkdir([keyframetype '_gif']);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    
    %only process visual bin 1, 2, 3 images; to save time
    if node.bin == 4
        continue; 
    end
    
    imgPortilaMaskfullname = ['Stimulus/keyframe_expB/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_PortillaMask.jpg' ];
    imgorifullname = ['Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    if exist(imgorifullname, 'file') ~= 2 || exist(imgbinfullname, 'file') ~= 2
        warning(['either binary or original image missing']);
        continue;
    end
    %imgPortilaMaskfullname
    if exist(imgPortilaMaskfullname, 'file')~=2
        imgPortilaMaskfullname = ['Stimulus/keyframe_expB/' maskList(randperm(length(maskList),1)).name];
    end
    display(['processing image: ' num2str(imgnum)]);
    
    %% Image read in; pre-processing
    img = imread(imgorifullname);
    if length(size(img))~=3
        img = cat(3, img, img, img);
    end
    
    Pmask = imread(imgPortilaMaskfullname);
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
    
    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    counter = 1; %keep track of gif types
    
    %%%% subcategory: bbox wo mask
    for cfc = 1: length(cf)
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        
        % encode a new QR code and embed into gif file
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(1)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
        %imshow(screen1T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(2)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
        %imshow(screen2T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(3)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        type2imgT = fcn_addQRcodeToStimulus(test_encode, type2img);
        %imshow(type2imgT);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen3T = fcn_addQRcodeToStimulus(test_encode, screen3);
        %imshow(screen3T);
        
        fcn_WriteGIF(screen1T, screen2T, type2imgT, screen3T, exptime(cfc,:), namegif,cf(cfc),keyframetype, repeat);
        counter = counter + 1;
    end
    
    %%%% subcategory: bbox w mask
    for cfc = 1: length(cf)
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        
        % encode a new QR code and embed into gif file
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(1)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
        %imshow(screen1T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(2)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
        %imshow(screen2T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(3)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        type2imgT = fcn_addQRcodeToStimulus(test_encode, type2img);
        %imshow(type2imgT);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        PmaskT = fcn_addQRcodeToStimulus(test_encode, Pmask);
        %imshow(PmaskT);
        
        fcn_WriteGIF(screen1T, screen2T, type2imgT, PmaskT, exptime(cfc,:), namegif,cf(cfc),keyframetype, repeat);
        counter = counter + 1;
    end
    
    %%%% subcategory: full context wo mask
    for cfc = 1: length(cf)
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        
        % encode a new QR code and embed into gif file
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(1)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
        %imshow(screen1T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(2)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
        %imshow(screen2T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(3)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        type8imgT = fcn_addQRcodeToStimulus(test_encode, type8img);
        %imshow(type8imgT);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen3T = fcn_addQRcodeToStimulus(test_encode, screen3);
        %imshow(screen3T);
        
        fcn_WriteGIF(screen1T, screen2T, type8imgT, screen3T, exptime(cfc,:), namegif,cf(cfc),keyframetype, repeat);
        counter = counter + 1;
    end
    
    %%%% subcategory: full context w mask
    for cfc = 1: length(cf)
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        
        % encode a new QR code and embed into gif file
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(1)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
        %imshow(screen1T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(2)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
        %imshow(screen2T);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(3)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        type8imgT = fcn_addQRcodeToStimulus(test_encode, type8img);
        %imshow(type8imgT);
        
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        PmaskT = fcn_addQRcodeToStimulus(test_encode, Pmask);
        %imshow(PmaskT);
        
        fcn_WriteGIF(screen1T, screen2T, type8imgT, PmaskT, exptime(cfc,:), namegif,cf(cfc),keyframetype, repeat);
        counter = counter + 1;
    end   
    
    display(['writing gif complete']);
end
