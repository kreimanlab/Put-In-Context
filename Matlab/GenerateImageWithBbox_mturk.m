clear all; close all; clc;

%% experiemnt parameters here %%%%%%%%%%%%%%
load(['ImageStatsHuman_val_50_filtered.mat']);

%imgorilist = dir(['/home/mengmi/Desktop/NewSelected2/img/img_*.jpg']);
NumImg = length(ImageStatsFiltered);
infor = [];
boundingboxWidth = 3;
radiuscircle = 200;

for imgnum = 1: NumImg %the current image id
    node = ImageStatsFiltered(imgnum);
    %if node.bin == 1 || node.bin == 2 || node.bin == 3; continue; end
    imgorifullname = ['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen2_imgtype_8.jpg'];
    img = imread(imgorifullname);
    
    binarymask = ['Stimulus/keyframe_expA/trial_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_screen1_binarybdbox.jpg'];
    binarymask = imread(binarymask);
    binarymask = mat2gray(binarymask);
    
    [row, col] = find(binarymask==1);
    leftx = min(col);lefty = min(row);rightx = max(col);righty = max(row);
    ctrx = floor((leftx + rightx)/2);ctry = floor((lefty + righty)/2);
    oh = rightx - leftx;
    ow = righty - lefty;
    img = insertShape(img,'Rectangle',[leftx lefty rightx-leftx righty-lefty],'LineWidth',boundingboxWidth,'Color','red');
    img = insertShape(img,'Circle',[leftx+(rightx-leftx)/2 lefty+(righty-lefty)/2 radiuscircle],'LineWidth',boundingboxWidth,'Color','red');
            
    
    vec =[imgnum node.bin node.classlabel node.objIDinCate 8];
    infor = [infor; vec];
    
    imgorifullname = ['/home/mengmi/Projects/Proj_context2/mturk/Mturk/StimulusBackUp/expA_GTlabel/trial_' num2str(imgnum) '.jpg'];
    imwrite(img,imgorifullname);
       
    display(['#' num2str(imgnum) ': writing gif complete']);
end
save('/home/mengmi/Projects/Proj_context2/mturk/Mturk/StimulusBackUp/expA_GTlabel/infor.mat','infor');