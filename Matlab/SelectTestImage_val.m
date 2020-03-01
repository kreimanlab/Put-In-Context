clear all; clc; close all;

%% Mengmi

PixToVA = 156/5; %pixels per visual angle in degrees
ObjSizeBin = [0.5 1 1.75 2.25 3.5 4.5 7 9]*PixToVA; 
ObjSizeBin = ObjSizeBin.^2; %threshold object size in pixels
NumBin = 4;

%TotalCate = 40; %total number of categories
%CategoryInstanceLimit = 5; %number of examples per category
BinInstanceLimit = 50; %2 object instances per category per visual degree bin
%ObjCateInstanceLimit = 2; %1000 trials in total; 4 visual angle bins

ScreenWidth = 1024;
ScreenHeight = 1280;

%Accumulate = zeros(TotalCate, length(ObjSizeBin)-1);
FileDir = '/media/mengmi/TOSHIBA EXT/CategoryVisualSearch/Dataset/MSCOCO/';
dataType='val2014';

%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
annType=annTypes{1}; % specify dataType/annType
annFile=sprintf([FileDir 'annotations/%s_%s.json'],annType,dataType);
coco=CocoApi(annFile);

%% display COCO categories and supercategories
if( ~strcmp(annType,'captions') )
  cats = coco.loadCats(coco.getCatIds());
    
  %lets remove 40 categories
%   IndexToRemove = [4 8 6 10 11,...
%        12 13 14 17 18,...
%        20 21 23 25 29,...
%        31 33 34 35 36,...
%        39 41 44 45 47,...
%        50 53 55 56 58,...
%        59 62 64 66 70,...
%        71 72 76 78 79 ];

  IndexToRemove = [1 16 22 58 60 69 70 73 79];
   
  cats(IndexToRemove) = [];
  nms={cats.name}; fprintf('COCO categories: ');
  fprintf('%s, ',nms{:}); fprintf('\n');
  
end

NumCategories=  length(cats);
Accumulate = zeros(NumCategories, NumBin);

cateIDmatch = extractfield(cats,'id');
%imgIds = coco.getImgIds();
ImageStats = [];
usedimglist = [];
%catcount = 0;
for categ = 1: length(nms)
    
    %display(['prev cate instance: ' num2str(catcount)]);
    
    catIds = coco.getCatIds('catNms',{nms{categ}});
    imgIds = coco.getImgIds('catIds',catIds);
    %catcount = 0;

    for j = 1:length(imgIds)
        display(['category: ' nms{categ} '; image: ' num2str(j) ]);
        
        if length(ImageStats) == 10
            display('haha');
        end
        
        %check whether this image has been used before        
        if length(find(usedimglist == imgIds(j))) >0
            continue;
        end
        
        if sum(Accumulate(categ,:))== BinInstanceLimit*NumBin
            break;
        end

        img = coco.loadImgs(imgIds(j));
        I = imread(sprintf([FileDir '%s/%s'],dataType,img.file_name));
        imgheight = img.height; %480; vertical
        imgwidth = img.width; %640; horizontal

        RGB = imresize(I, [ScreenWidth NaN]);
        if size(RGB,2) > ScreenHeight
            RGB = imresize(I, [NaN ScreenHeight]);
        end
        I_Screen = RGB;
        imgscreenwidth = size(I_Screen,2);%640; horizontal
        imgscreenheight = size(I_Screen,1);%480; vertical

        %%%%%%%%%%%%%%%%%%%%% get all instances color map
        AllannIds = coco.getAnnIds('imgIds',imgIds(j),'catIds',catIds,'iscrowd',[]);    
        Allanns = coco.loadAnns(AllannIds);    

        for n = 1:length(Allanns)
            node = [];
            node.area = Allanns(n).bbox(3)*Allanns(n).bbox(4)/(imgheight*imgwidth)*(imgscreenwidth*imgscreenheight);
            %node.area = Allanns(n).area/(imgheight*imgwidth)*(imgscreenwidth*imgscreenheight);
            [nu cc] = find(cateIDmatch == Allanns(n).category_id);
    %         
    %         if isempty(cc)
    %             continue;
    %         end

            node.classlabel = cc;
            node.classname = nms{cc};

            flagb = 0;
            b = 0;
            for b = 1:NumBin
                if node.area < ObjSizeBin(2*b) && node.area >= ObjSizeBin(2*b-1) && Accumulate(categ,b)< BinInstanceLimit
                    flagb = 1;
                    break;
                end
            end
            if flagb == 0
                b = NumBin+1;
            end     

            if b>=1 && b<=NumBin && Accumulate(categ,b)< BinInstanceLimit

                node.area = Allanns(n).area/(imgheight*imgwidth)*(imgscreenwidth*imgscreenheight);
                node.imgID = imgIds(j);
                node.categID = catIds;
                node.instanceID = n;
                node.instance = Allanns(n);
                node.imghorizontal = imgwidth;
                node.imgvertical = imgheight;
                Accumulate(categ,b) = Accumulate(categ,b)+1;
                node.bndhorizontal = Allanns(n).bbox(3)/imgwidth*imgscreenwidth;
                node.bndvertical = Allanns(n).bbox(4)/imgheight*imgscreenheight;
                node.imgscreenhorizontal = imgscreenwidth;
                node.imgscreenvertical = imgscreenheight;
                node.bin = b;
                node.mode = 'val2014';
                ImageStats = [ImageStats  node];
                usedimglist = [usedimglist; imgIds(j)];
                %catcount = catcount + 1;
                
                break;
            end
        end

    end
end
    
save(['ImageStatsHuman_val_' num2str(BinInstanceLimit) '.mat'],'ImageStats','Accumulate');