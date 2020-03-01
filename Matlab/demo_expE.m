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

mkdir([keyframetype]);
mkdir([keyframetype '_gif']);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
        
    display(['mode:jigsaw; processing image: ' num2str(imgnum)]);
    if node.bin == 4; continue; end
    
    imgorifullnamelist = ['Stimulus/img_jigsaw/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_*.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    
    imgtypelist = dir(imgorifullnamelist);

    for haveimg = 1:length(imgtypelist)
        type = imgtypelist(haveimg).name(end-4);
        type = str2num(type);
        
        imgorifullname = ['Stimulus/img_jigsaw/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '.jpg'];

        %% Image read in; pre-processing
        img = imread(imgorifullname);
        if length(size(img))~=3
            img = cat(3, img, img, img);
        end
        % convert to grayscale
        imggray = rgb2gray(img);

        % convert to binary image
        bin = imread(imgbinfullname);
        bin = imresize(bin,size(imggray));
        bin = im2bw(bin,0.5);
        %imshow(bin);

        % rescale to fit screen size; maintain aspect ratio
        RGB = imresize(img, [ScreenWidth NaN]);
        RGBbin = imresize(bin, [ScreenWidth NaN]);
        if size(RGB,2) > ScreenHeight
            RGB = imresize(img, [NaN ScreenHeight]);
            RGBbin = imresize(bin, [NaN ScreenHeight]);
        end
        img = RGB;
        bin = im2bw(RGBbin);
        [iw ih] = size(RGBbin);

        % paste them in center of screen
        screen = ones(ScreenWidth, ScreenHeight,3)*128;
        binscreen = ones(ScreenWidth, ScreenHeight,3)*0;
        if iw == ScreenWidth
            ileftx = floor(ScreenHeight/2) - floor(ih/2)+1; irightx = floor(ScreenHeight/2) - floor(ih/2)+size(img,2); ilefty = 1; irighty = ScreenWidth;
            screen(:,ileftx: irightx,:) = img;
            binscreen(:,ileftx: irightx,1) = bin;
            binscreen(:,ileftx: irightx,2) = bin;
            binscreen(:,ileftx: irightx,3) = bin;

        else
            ileftx = 1; irightx = ScreenHeight; ilefty = floor(ScreenWidth/2) - floor(iw/2)+1; irighty = floor(ScreenWidth/2) - floor(iw/2) + size(img,1);
            screen(ilefty:irighty,:,:) = img;
            binscreen(ilefty:irighty,:,1) = bin;
            binscreen(ilefty:irighty,:,2) = bin;
            binscreen(ilefty:irighty,:,3) = bin;
        end
   
        % extract bounding box; x is horinzontal axis; y is vertical axis; (0,0) is
        % at top left corner of the image
        [row, col] = find(binscreen(:,:,1)==1);
        leftx = min(col);lefty = min(row);rightx = max(col);righty = max(row);
        ctrx = floor((leftx + rightx)/2);ctry = floor((lefty + righty)/2);
        oh = rightx - leftx;
        ow = righty - lefty; 
        
        img_complete = screen; %ratio = 1
        img_complete = uint8(img_complete);
        img_complete = insertShape(img_complete,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
        %img_complete = rgb2gray(img_complete);

        screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
        %imshow(screen1);

        screen2 = fcn_DrawCross(ScreenWidth, ScreenHeight, ctrx, ctry);
        screen2 = uint8(screen2);
        screen2 = insertShape(screen2,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',2,'Color','black');
        
        %% Write GIF
        repeat = 0; %play only once for 0 and Inf for infinite looping
        screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(type) '.gif'];
        fcn_WriteGIF(screen1, screen2, img_complete, screen3, exptime, namegif,cf,keyframetype, repeat);
        imwrite(img_complete,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(type) '.jpg']);
    
    end   
    
    display(['writing gif complete']);
end

%% process metamer mask
for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    %if node.bin == 1 || node.bin == 2 || node.bin == 3; continue; end
    imgorifullname = ['Stimulus/keyframe_expB/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_PortillaMask.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    if exist(imgorifullname, 'file') ~= 2 || exist(imgbinfullname, 'file') ~= 2
        warning(['either binary or original image missing']);
        continue;
    end
    
    display(['mode:matamer; processing image: ' num2str(imgnum)]);
    
    %% Image read in; pre-processing
    img = imread(imgorifullname);
    if length(size(img))~=3
        img = cat(3, img, img, img);
    end
    % convert to grayscale
    imggray = rgb2gray(img);

    % convert to binary image
    bin = imread(imgbinfullname);
    bin = imresize(bin,size(imggray));
    bin = im2bw(bin,0.5);
    %imshow(bin);

    % rescale to fit screen size; maintain aspect ratio
    RGB = imresize(img, [ScreenWidth NaN]);
    RGBbin = imresize(bin, [ScreenWidth NaN]);
    if size(RGB,2) > ScreenHeight
        RGB = imresize(img, [NaN ScreenHeight]);
        RGBbin = imresize(bin, [NaN ScreenHeight]);
    end
    img = RGB;
    bin = im2bw(RGBbin);
    [iw ih] = size(RGBbin);

    % paste them in center of screen
    screen = ones(ScreenWidth, ScreenHeight,3)*128;
    binscreen = ones(ScreenWidth, ScreenHeight,3)*0;
    if iw == ScreenWidth
        ileftx = floor(ScreenHeight/2) - floor(ih/2)+1; irightx = floor(ScreenHeight/2) - floor(ih/2)+size(img,2); ilefty = 1; irighty = ScreenWidth;
        screen(:,ileftx: irightx,:) = img;
        binscreen(:,ileftx: irightx,1) = bin;
        binscreen(:,ileftx: irightx,2) = bin;
        binscreen(:,ileftx: irightx,3) = bin;
        
    else
        ileftx = 1; irightx = ScreenHeight; ilefty = floor(ScreenWidth/2) - floor(iw/2)+1; irighty = floor(ScreenWidth/2) - floor(iw/2) + size(img,1);
        screen(ilefty:irighty,:,:) = img;
        binscreen(ilefty:irighty,:,1) = bin;
        binscreen(ilefty:irighty,:,2) = bin;
        binscreen(ilefty:irighty,:,3) = bin;
    end
%     imshow(uint8(screen));
%     imshow(binscreen);
%     imwrite(binscreen,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarycontour.jpg']);
    
    
    % extract bounding box; x is horinzontal axis; y is vertical axis; (0,0) is
    % at top left corner of the image
    [row, col] = find(binscreen(:,:,1)==1);
    leftx = min(col);lefty = min(row);rightx = max(col);righty = max(row);
    ctrx = floor((leftx + rightx)/2);ctry = floor((lefty + righty)/2);
    oh = rightx - leftx;
    ow = righty - lefty; 
    % temp = zeros(ScreenWidth, ScreenHeight);
    % temp(lefty:righty,leftx:rightx) = 1;
    % imshow(mat2gray(temp));

    %% Prepare sets of images
    img_complete = imread(['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_8.jpg']);
    screen(find(binscreen == 1)) = img_complete(find(binscreen == 1));
      
    img_complete = screen; %ratio = 1
    img_complete = uint8(img_complete);
    img_complete = insertShape(img_complete,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
    %img_complete = rgb2gray(img_complete);

    screen1 = fcn_DrawCross(ScreenWidth, ScreenHeight, ScreenHeight/2, ScreenWidth/2);
    %imshow(screen1);

    screen2 = fcn_DrawCross(ScreenWidth, ScreenHeight, ctrx, ctry);
    screen2 = uint8(screen2);
    screen2 = insertShape(screen2,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',2,'Color','black');
    %screen2 = rgb2gray(screen2);
    %imwrite(screen2,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1.jpg']);
    %imwrite(imgbin_boundbox,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarybdbox.jpg']);
    %imshow(screen2);

    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
    counter = 4;
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1, screen2, img_complete, screen3, exptime, namegif,cf,keyframetype, repeat);
    imwrite(img_complete,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(counter) '.jpg']);
    
    %for claire to visualize
%     namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(7) '_' '.gif'];
%     fcn_WriteGIF(screen1, screen2, img_complete, screen3, exptime, namegif,cf,keyframetype, repeat);
%     imwrite(img_complete,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(7) '_' node.classname '.jpg']);
    
%     recordkeep(imgnum,counter) = imgnum;
%     truerecord(imgnum,counter) = imgnum;
    
    display(['writing gif complete']);
end


