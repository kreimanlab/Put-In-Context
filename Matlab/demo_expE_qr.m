clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
ScreenWidth = 1024;
ScreenHeight = 1280;
exptime = [500 1000 200 100]; %in millisecs
cf = 100; %this is the greatest common factor of experiment time
boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expE'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% QR configure
qrsize = 97;
addpath('qr_code');
javaaddpath('jar/core-3.3.0.jar');
javaaddpath('jar/javase-3.3.0.jar');
expType = 'expE';

%mkdir([keyframetype]);
mkdir([keyframetype '_qr_gif']);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    
    if node.bin == 4; continue; end
    display(['processing image: ' num2str(imgnum)]);
    imgorifullnamelist = ['Stimulus/keyframe_expE/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_*.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    
    imgtypelist = dir(imgorifullnamelist);

    for haveimg = 1:length(imgtypelist)
        type = imgtypelist(haveimg).name(end-4);
        type = str2num(type);
        
        imgorifullname = ['Stimulus/keyframe_expE/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(type) '.jpg'];

        %% Image read in; pre-processing
        img_complete = imread(imgorifullname);        

        screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
        %imshow(screen1);

        screen2 = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1.jpg']);
        
        %% Write GIF
        repeat = 0; %play only once for 0 and Inf for infinite looping
        screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
          
        % encode a new QR code and embed into gif file
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '_type_' num2str(1)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen1T = fcn_addQRcodeToStimulus(test_encode, screen1);
        %imshow(screen1T);
        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '_type_' num2str(2)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen2T = fcn_addQRcodeToStimulus(test_encode, screen2);
        %imshow(screen2T);

        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '_type_' num2str(3)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        img_completeT = fcn_addQRcodeToStimulus(test_encode, img_complete);
        %imshow(img_completeT);

        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen3T = fcn_addQRcodeToStimulus(test_encode, screen3);
        %imshow(screen3T);
        
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '.gif'];
        fcn_WriteGIF(screen1T, screen2T, img_completeT, screen3T, exptime, namegif,cf,[keyframetype '_qr'], repeat);
        
    end   
    
    display(['writing gif complete']);
end




