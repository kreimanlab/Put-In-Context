clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
imgorilist = dir(['Stimulus/tablechair/*.jpeg']);
NumImg = length(imgorilist);
ScreenWidth = 1024;
ScreenHeight = 1280;

% QR configure
qrsize = 97;
addpath('qr_code');
expType = 'tablechair';
javaaddpath('core-3.3.0.jar');
javaaddpath('javase-3.3.0.jar');

exptime = [500 200 100]; %in millisecs
cf = 100; %this is the greatest common factor of experiment time
keyframetype = 'Stimulus/keyframe_tablechair'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
% rmdir([keyframetype], 's');
% rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype]);
mkdir([keyframetype '_gif']);


for imgnum = 1: NumImg %the current image id
    
    imgorifullname = ['Stimulus/tablechair/' imgorilist(imgnum).name ];
    %imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
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
    % convert to grayscale
    imggray = rgb2gray(img);

    
    % rescale to fit screen size; maintain aspect ratio
    RGB = imresize(img, [ScreenWidth NaN]);
    
    if size(RGB,2) > ScreenHeight
        RGB = imresize(img, [NaN ScreenHeight]);
        
    end
    img = RGB;
    
    [iw ih ic] = size(RGB);

    % paste them in center of screen
    screen = ones(ScreenWidth, ScreenHeight,3)*128;
    
    if iw == ScreenWidth
        ileftx = floor(ScreenHeight/2) - floor(ih/2)+1; irightx = floor(ScreenHeight/2) - floor(ih/2)+size(img,2); ilefty = 1; irighty = ScreenWidth;
        screen(:,ileftx: irightx,:) = img;      
    else
        ileftx = 1; irightx = ScreenHeight; ilefty = floor(ScreenWidth/2) - floor(iw/2)+1; irighty = floor(ScreenWidth/2) - floor(iw/2) + size(img,1);
        screen(ilefty:irighty,:,:) = img;       
    end
%     imshow(uint8(screen));
%     imshow(binscreen);

    img_complete = screen; %ratio = 1
    img_complete = uint8(img_complete);
    
    % encode a new QR code and embed into gif file
    message = [expType '_trial_' num2str(imgnum) '_type_' num2str(2)];    
    test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
    img_complete = fcn_addQRcodeToStimulus(test_encode, img_complete);
    %imshow(img_complete);
    
    screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
    
    % encode a new QR code and embed into gif file
    message = [expType '_trial_' num2str(imgnum) '_type_' num2str(1)];    
    test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
    screen1 = fcn_addQRcodeToStimulus(test_encode, screen1);
    %imshow(screen1);
    %imshow(screen1);

    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
    % encode a new QR code and embed into gif file
    message = [expType '_trial_' num2str(imgnum) '_type_' num2str(3)];    
    test_encode = qrcode_gen(message,'CharacterSet','UTF-8','Version',20,'Size',qrsize); % Returns a matrix
    screen3 = fcn_addQRcodeToStimulus(test_encode, screen3);
    %imshow(screen3);
    
    counter = 1;
    namegif = ['gif_' num2str(imgnum) '.gif'];
    fcn_WriteGIF_chairtable(screen1, img_complete, screen3, exptime, namegif,cf,keyframetype, repeat);
    
    
    display(['writing gif complete']);
end
