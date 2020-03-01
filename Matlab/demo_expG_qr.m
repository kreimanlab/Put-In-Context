clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

% QR configure
qrsize = 97;
addpath('qr_code');
javaaddpath('jar/core-3.3.0.jar');
javaaddpath('jar/javase-3.3.0.jar');
expType = 'expG';

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
ScreenWidth = 1024;
ScreenHeight = 1280; 
exptime_bbox = 1000; %in millisecs
exptime_fixation = 500; %in millisecs
exptime_context = [25, 50, 100, 200]; %in millisecs
exptime_obj = [25, 50, 100]; %in millisecs
exptime_blank = 25; %in millisecs

cf = 25; %this is the greatest common factor of experiment time

boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expG'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype '_qr_gif']);

for imgnum = 1001: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    
    if node.bin == 4; continue; end
    
    %only process visual bin 1, 2, 3 images; to save time
%     if node.bin == 4 || node.bin == 1
%         continue; 
%     end
    
    
    %bbox
    type2img = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_2.jpg']);
    %full context
    type8img = imread(['Stimulus/keyframe_expG/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_hollow.jpg']);
    %screen2 with bbox location and fixation cross
    screen2 = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1.jpg']);
    %fixation cross in the center
    screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
    %purely gray background
    screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    counter = 1; %keep track of gif types
    
    for t1 = 1:length(exptime_context)
        for t2 = 1: length(exptime_obj)
            
            message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(1)];    
            test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
            screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
            
            message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(2)];    
            test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
            screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
            
            %imshow(screen1T);
            message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(3)];    
            test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
            type8imgT = fcn_addQRcodeToStimulus(test_encode, type8img);
            %imshow(type8imgT);

            message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
            test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
            type2imgT = fcn_addQRcodeToStimulus(test_encode, type2img);
            %imshow(type2imgT);

            message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(5)];    
            test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
            screen3T = fcn_addQRcodeToStimulus(test_encode, screen3);
            %imshow(screen3T);
            
            exptime = [exptime_fixation exptime_bbox exptime_context(t1) exptime_obj(t2)  exptime_blank];
            namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
            fcn_WriteGIF_expG(screen1T, screen2T, type8imgT, type2imgT, screen3T, exptime, namegif,cf,[keyframetype '_qr'], repeat);
            counter = counter + 1;
    
        end
    end
    
    display(['writing gif complete']);
end