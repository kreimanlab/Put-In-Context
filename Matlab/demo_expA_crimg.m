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
%mkdir([keyframetype '_gif']);


for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    %if node.bin == 1 || node.bin == 2 || node.bin == 3; continue; end
    imgorifullname = [keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_8.jpg'];
    imgbinfullname = [keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarybdbox.jpg']
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
    
    [row, col] = find(bin(:,:)==1);
    leftx = min(col);lefty = min(row);rightx = max(col);righty = max(row);
    ctrx = floor((leftx + rightx)/2);ctry = floor((lefty + righty)/2);
    oh = rightx - leftx;
    ow = righty - lefty;

    crimg = img(lefty:righty,leftx:rightx,:);
    crimg= uint8(crimg);
    crimg = imresize(crimg,[400 400]);
    imshow(crimg);
    
    imwrite(crimg,[keyframetype '/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_crimg.jpg']);
    
    
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



