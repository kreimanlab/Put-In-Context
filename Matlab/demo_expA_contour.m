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
% rmdir([keyframetype], 's');
% rmdir([keyframetype '_gif'], 's');
mkdir([keyframetype]);
mkdir([keyframetype '_gif']);


for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    %if node.bin == 1 || node.bin == 2 || node.bin == 3; continue; end
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
    
    imwrite(binscreen,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarycontour.jpg']);
    
    
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



