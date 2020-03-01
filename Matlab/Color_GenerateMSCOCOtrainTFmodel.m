clear all; close all; clc;

load('ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

FileDir = '/media/mengmi/DATA/Datasets/MSCOCO/';
% savefolder = 'train2014_OtherCategories';
dataType='train2014';
%savefolder = 'val2014_OtherCategories';
%dataType='val2014';

%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
annType=annTypes{1}; % specify dataType/annType
annFile=sprintf([FileDir 'annotations/%s_%s.json'],annType,dataType);
coco=CocoApi(annFile);

%% display COCO categories and supercategories
% if( ~strcmp(annType,'captions') )
%   cats = coco.loadCats(coco.getCatIds());
%   nms={cats.name}; fprintf('COCO categories: ');
%   fprintf('%s, ',nms{:}); fprintf('\n');
%   %nms=unique({cats.supercategory}); fprintf('COCO supercategories: ');
%   %fprintf('%s, ',nms{:}); fprintf('\n');
% end
CateLimit = 2000; %1000 sample images per category
%ObjInstanceNumLimit = 1;
%TotalCategory = 80;
%colorlist = [0.3: (1-0.5)/TotalCategory : 1];
%color: 0.1 is bounding box region; the 80 category corrospond with
%different color codes
%cateIDmatch = extractfield(cats,'id');
fixedSize = 600;

for i = 1:length(nms)
    display(['==================================']);
    display([nms{i}]);
    catIds = coco.getCatIds('catNms',{nms{i}});
    imgIds = coco.getImgIds('catIds',catIds)';
    display(length(imgIds));
    
    precatefolder = ['../Datasets/MSCOCO/trainColor_img/cate' sprintf( '%02d', i)];
    %rmdir(precatefolder);
    mkdir(precatefolder);
    
    precatefolder1 = ['../Datasets/MSCOCO/trainColor_crimg/cate' sprintf( '%02d', i)];
    %rmdir(precatefolder1);
    mkdir(precatefolder1);
    
    precatefolder2 = ['../Datasets/MSCOCO/trainColor_binimg/cate' sprintf( '%02d', i)];
    %rmdir(precatefolder1);
    mkdir(precatefolder2);
    
    precatefolder3 = ['../Datasets/MSCOCO/trainColor_oriimg/cate' sprintf( '%02d', i)];
    %rmdir(precatefolder);
    mkdir(precatefolder3);
    
    couterlimit = 0;
    
    for j = 1:length(imgIds)
        display(['cate: ' num2str(i) '; name: ' nms{i} '; num: ' num2str(j)]);
        
        if couterlimit>CateLimit
            break;
        end
        
        img = coco.loadImgs(imgIds(j));
        I = imread(sprintf([FileDir '%s/%s'],dataType,img.file_name));
        if length(size(I)) < 3
            I = cat(3, I,I,I);
        end
        
        %%%%%%%%%%%%%%%%%%%%% crop natural image %%%%%%%%%%%%%%%%%%%%% 
        %figure(1); imagesc(I); axis('image'); set(gca,'XTick',[],'YTick',[])
        annIds = coco.getAnnIds('imgIds',imgIds(j),'catIds',catIds,'iscrowd',[]);
        anns = coco.loadAnns(annIds); %coco.showAnns(anns);

        if(~isfield(anns,'segmentation'))
            continue;
        end
        S={anns.segmentation}; 
        
        polygon = int32(S{1}{1});
        

        %% cropped obj
        bbox = anns.bbox;
        bbox = [bbox(2) bbox(2) + bbox(4) bbox(1) bbox(1) + bbox(3)];
        bbox = int32(bbox);
        bbox(find(bbox<1)) = 1;

        cropobjmask = I(bbox(1):bbox(2), bbox(3):bbox(4),:);
        Iori = I;
        I(bbox(1):bbox(2), bbox(3):bbox(4),:) = 0; %for unknown region
        
        bin = zeros(size(I));
        bin(bbox(1):bbox(2), bbox(3):bbox(4),:) = 255;
        
        %cropcatemask = binarymask(bbox(1):bbox(2), bbox(3):bbox(4),:);
%         binarymask(bbox(1):bbox(2), bbox(3):bbox(4),:) = 0.1; %for unknown region
        
        %convert to one channel
%         cropcatemask = squeeze(cropcatemask(:,:,1));
%         binarymask = squeeze(binarymask(:,:,1));
        %resize to [fixedsize fixedsize]
        I = imresize(I,[fixedSize fixedSize]);
        Iori = imresize(Iori,[fixedSize fixedSize]);
        cropobjmask = imresize(cropobjmask,[fixedSize fixedSize]);
        bin = imresize(bin,[fixedSize fixedSize]);
        bin = im2bw(bin);
%         cropcatemask = imresize(cropcatemask,[fixedSize fixedSize]);
%         binarymask = imresize(binarymask,[fixedSize fixedSize]);      
        
        couterlimit = couterlimit+1;
        imwrite(I,[precatefolder '/img_' num2str(j) '.jpg']);
        imwrite(Iori,[precatefolder3 '/ori_' num2str(j) '.jpg']);
        imwrite(cropobjmask,[precatefolder1 '/crimg_' num2str(j) '.jpg']);
        imwrite(bin,[precatefolder2 '/bin_' num2str(j) '.jpg']);
%         imwrite(binarymask,[precatefolder '/categ_' num2str(j) '.jpg']);
%         imwrite(cropcatemask,[precatefolder '/crcateg_' num2str(j) '.jpg']);
        
%         close all;
%         subplot(2,2,1); imshow(I); subplot(2,2,2); imshow(cropobjmask);
%         subplot(2,2,3); imshow(binarymask); subplot(2,2,4); imshow(cropcatemask);
%         pause;
        
    end
    
end















































