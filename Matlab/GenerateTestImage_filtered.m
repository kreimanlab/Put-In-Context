clear all; close all; clc;
%% Generate Images and segmented binary mask

load(['ImageStatsHuman_val_50_filtered.mat']); %load information of selected images and their object instances
ImageStats = ImageStatsFiltered;
Accumulate = AccumulateFiltered;

%% print some basic stats
cateclassnamelist = extractfield(ImageStats,'classname');
catenames = unique(cateclassnamelist);
fprintf('MSCOCO selected categories: ');
fprintf('%s, ',catenames{:}); fprintf('\n');
display(['Total number of selected categories: ' num2str(length(catenames))]);

%% print cate distribution
cateclasslist = extractfield(ImageStats,'classlabel');
figure;
hist(cateclasslist,[1:max(cateclasslist)]);
xlabel('category name');
ylabel('number of instances per category');
title('over all four bins');

%print sub category distribution based on bins
figure;
binlist = extractfield(ImageStats,'bin');

for b = 1:4
    cateclasslistsub = cateclasslist(find(binlist == b));
    subplot(1,length(unique(binlist)),b);
    hist(cateclasslistsub,[1:max(cateclasslistsub)]);
    xlabel('category name');
    ylabel('number of instances per category');
    title(['object instances distribution for bin =' num2str(b)]);
end

FileDir = '/media/mengmi/DATA/Datasets/MSCOCO/';
dataType='val2014';

%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
annType=annTypes{1}; % specify dataType/annType
annFile=sprintf([FileDir 'annotations/%s_%s.json'],annType,dataType);
coco=CocoApi(annFile);

for j = 1:length(ImageStats)
    display(['image num: ' num2str(j)]);
    node = ImageStats(j);
    
    img = coco.loadImgs(node.imgID);
    I = imread(sprintf([FileDir '%s/%s'],dataType,img.file_name));
        
    %%%%%%%%%%%%%%%%%%%%% get all instances color map
    S={node.instance.segmentation};
        
    % fill in polygon based on category
    binarymask = zeros([size(I,1) size(I,2) 3]);
    %boundingbox = zeros([size(I,1) size(I,2) 3]);
    for c1 = 1:length(S)
        for c2 = 1:length(S{c1})  
            if ~iscell(S{c1})
                continue;
            end
            polygon = int32(S{c1}{c2});                 
            binarymask = insertShape(binarymask,'FilledPolygon',polygon,'Color', [1 1 1],'Opacity',1);
            boundingbox = insertShape(I,'Rectangle',node.instance.bbox,'Color', 'r', 'LineWidth',2);
            rec = node.instance.bbox;
            %circle = [rec(1)+rec(3)/2 rec(2)+rec(4)/2 sqrt(rec(3)^2+rec(4)^2)+10];
            %boundingbox = insertShape(boundingbox,'Circle',circle,'Color', 'r', 'LineWidth',10);
            lengthline = 50;
            line1 = [rec(1) rec(2) rec(1)-lengthline rec(2)-lengthline];
            line2 = [rec(1) rec(2)+rec(4) rec(1)-lengthline rec(2)+rec(4)+lengthline];
            line3 = [rec(1)+rec(3) rec(2) rec(1)+rec(3)+lengthline rec(2)-lengthline];
            line4 = [rec(1)+rec(3) rec(2)+rec(4) rec(1)+rec(3)+lengthline rec(2)+rec(4)+lengthline];
            
            boundingbox = insertShape(boundingbox,'Line',line1,'Color', 'r', 'LineWidth',10);
            boundingbox = insertShape(boundingbox,'Line',line2,'Color', 'r', 'LineWidth',10);
            boundingbox = insertShape(boundingbox,'Line',line3,'Color', 'r', 'LineWidth',10);
            boundingbox = insertShape(boundingbox,'Line',line4,'Color', 'r', 'LineWidth',10);
            
        end
    end
    
%     subplot(1,3,1);imshow(I);
%     subplot(1,3,2);imshow(binarymask);
%     subplot(1,3,3);imshow(boundingbox);
%     %pause(0.5);
%     pause;
    
    imwrite(I,['Stimulus/img/img_' num2str(node.bin) '_' num2str(node.classlabel) '_' num2str(node.objIDinCate) '.jpg']);
    imwrite(binarymask,['Stimulus/binMask/bin_'  num2str(node.bin) '_' num2str(node.classlabel) '_' num2str(node.objIDinCate) '.jpg']);
    %imwrite(boundingbox,['/home/mengmi/Desktop/NewSelected2/vis/bin' num2str(node.bin) '/vis_' num2str(j) '_' node.classname '.jpg']);
    %pause;
end