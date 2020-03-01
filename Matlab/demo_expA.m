clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
ScreenWidth = 1024;
ScreenHeight = 1280;
ratio = [2 4 8 16 128]; %context-object ratio (use bbox as object area for easy calculation); 
exptime = [500 1000 200 100]; %in millisecs
cf = 100; %this is the greatest common factor of experiment time
boundingboxWidth = 3;
keyframetype = 'Stimulus/keyframe_expA'; %change this to keyframe_expB, etc

%clean and create two folders for the type of expeirment
%rmdir([keyframetype], 's');
%rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype]);
mkdir([keyframetype '_gif']);

recordkeep = nan(NumImg, 6);
truerecord = nan(NumImg, 6);

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    %if node.bin == 1 || node.bin == 2 || node.bin == 3; continue; end
    imgorifullname = ['Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    imgbinfullname = ['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg'];
    if exist(imgorifullname, 'file') ~= 2 || exist(imgbinfullname, 'file') ~= 2
        warning(['either binary or original image missing']);
        continue;
    end
    if node.bin~=3 || node.classlabel~= 60 || node.objIDinCate~=26
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
    imwrite(binscreen,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarycontour.jpg']);
    
    
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
    img_silhouette = ones(ScreenWidth, ScreenHeight,3)*128;
    img_silhouette(find(binscreen == 1)) = screen(find(binscreen == 1));
    
    img_silhouette = uint8(img_silhouette);
    img_silhouette = insertShape(img_silhouette,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
    %img_silhouette = rgb2gray(img_silhouette);
%     imshow((img_silhouette));

    img_boundbox = ones(ScreenWidth, ScreenHeight,3)*128;
    img_boundbox(lefty:righty,leftx:rightx,:) = screen(lefty:righty,leftx:rightx,:);
    img_boundbox= uint8(img_boundbox);
    img_boundbox = insertShape(img_boundbox,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
    %img_boundbox = rgb2gray(img_boundbox);

    imgbin_boundbox = ones(ScreenWidth, ScreenHeight)*0;
    imgbin_boundbox(lefty:righty,leftx:rightx) = 1;
    imgbin_boundbox= mat2gray(imgbin_boundbox);
%     imshow(uint8(img_boundbox));

    img_ratio = cell(length(ratio),1);
    for r = 1: length(ratio)
        blank =  ones(ScreenWidth, ScreenHeight,3)*128;
        ratioy = floor( sqrt(ratio(r)+1) * ow);
        ratiox = floor( sqrt(ratio(r)+1) * oh);

        if (ratioy > iw) && (ratiox > ih)
            blank = {};
            img_ratio{r} = blank;
            continue;
        else
            lx = floor(ctrx - ratiox/2);rx = floor(ctrx + ratiox/2);
            ly = floor(ctry - ratioy/2);ry = floor(ctry + ratioy/2);

            if lx<ileftx; rx = rx + ileftx - lx; lx = ileftx; end
            if ly<ilefty; ry = ry + ilefty - ly; ly = ilefty; end
            if rx>irightx; lx = lx - (rx- irightx); rx = irightx; end
            if ry>irighty; ly = ly - (ry - irighty); ry = irighty; end
            if lx<1; lx = 1; end
            if ly<1; ly = 1; end
            if rx<1; rx = 1; end
            if ry<1; ry = 1; end

            blank(ly:ry,lx:rx,:) = screen(ly:ry,lx:rx,:);            
            
            blank = uint8(blank);
            blank = insertShape(blank,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','white');
            %blank = rgb2gray(blank);
        %     imshow(uint8(blank));
        %     pause(1);

            img_ratio{r} = blank;
         end


    end

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
    imwrite(screen2,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1.jpg']);
    imwrite(imgbin_boundbox,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarybdbox.jpg']);
    %imshow(screen2);

    %% Write GIF
    repeat = 0; %play only once for 0 and Inf for infinite looping
    screen3 = uint8(256/2*ones(ScreenWidth, ScreenHeight,3));
    
    counter = 1;
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1, screen2, img_silhouette, screen3, exptime, namegif,cf,keyframetype, repeat);
    imwrite(img_silhouette,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(counter) '.jpg']);
    recordkeep(imgnum,counter) = imgnum;
    truerecord(imgnum,counter) = imgnum;
    
    counter = counter+1;
    namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
    fcn_WriteGIF(screen1, screen2, img_boundbox, screen3, exptime, namegif,cf,keyframetype, repeat);
    imwrite(img_boundbox,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(counter) '.jpg']);
    recordkeep(imgnum,counter) = imgnum;
    truerecord(imgnum,counter) = imgnum;
    
    for r = 1: length(img_ratio)
        counter = counter+1;
        if isempty(img_ratio{r})
            warning(['experiment 1: ratio:' num2str(ratio(r)) 'escaped due to unmet size requirement']);            
            continue;
        end
        namegif = ['gif_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_' num2str(counter) '.gif'];
        fcn_WriteGIF(screen1, screen2, img_ratio{r}, screen3, exptime, namegif,cf,keyframetype, repeat);
        imwrite(img_ratio{r},[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_' num2str(counter) '.jpg']);
        recordkeep(imgnum,counter) = imgnum;
        truerecord(imgnum,counter) = imgnum;
    end

    counter = counter+1;
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

% for i = 1: NumImg
%     for j = 1:6
%         if isnan(truerecord(i,j))
%             havevec = truerecord(:,j);
%             selectedhave = find(~isnan(havevec));
%             selectedhave = selectedhave(randperm(length(selectedhave),1));
%             recordkeep(i,j) = selectedhave;
%             
%             fakename = [keyframetype '_gif/' 'gif_' num2str(i) '_' num2str(j) '.gif'];
%             truename = [keyframetype '_gif/' 'gif_' num2str(selectedhave) '_' num2str(j) '.gif'];
%             copyfile(truename, fakename);
%         end
%     end
% end

%save(['dummyrecord_expA.mat'],'recordkeep','truerecord');



