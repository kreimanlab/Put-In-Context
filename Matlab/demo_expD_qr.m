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

blurlist = [4 8 16 24 32];

boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expD'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype '_qr_gif']);
%mkdir([keyframetype]);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    
    %only process visual bin 1, 2, 3 images; to save time
    %if node.bin == 1 || node.bin == 2 || node.bin == 3
        %continue; 
    %end
    
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
    
    %% %% subcategory: bbox wo mask 
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
        
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1T, screen2T, type2imgT, screen3T, exptime, namegif,cf,[keyframetype '_qr'], repeat);
    counter = counter + 1;
    
    %% %% subcategory: full context
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
        
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1T, screen2T, type8imgT, screen3T, exptime, namegif,cf,[keyframetype '_qr'], repeat);
    counter = counter + 1;
    
    
    %% subcategory: full context with diff blurry
    type8img = double(type8img);
    
    %blurry sigma (standard deviation)
    for blur = blurlist
        blurtype8 = double(imgaussfilt(type8img, blur));
        
        for channel = 1:3
            %ensure bbox is still clear
            blurtype8(:,:,channel) = blurtype8(:,:,channel).*imgbin+ type8img(:,:,channel).*(1-imgbin);
        end
    
        blurtype8 = uint8(blurtype8);        
        blurtype8 = insertShape(blurtype8 ,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
    
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
        blurtype8T = fcn_addQRcodeToStimulus(test_encode, blurtype8);
        %imshow(type8imgT);

        message = [expType '_trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_type_' num2str(4)];    
        test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
        screen3T = fcn_addQRcodeToStimulus(test_encode, screen3);
        %imshow(screen3T);
        
        %imwrite(blurtype8,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '_blur.jpg']);
        
        %imshow(blurtype8);pause;
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        fcn_WriteGIF(screen1T, screen2T, blurtype8T, screen3T, exptime, namegif,cf,[keyframetype '_qr'], repeat);
        counter = counter + 1;
    end
    
    display(['writing gif complete']);
end