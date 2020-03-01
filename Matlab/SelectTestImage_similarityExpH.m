clear all; close all; clc;

load(['ImageStatsHuman_val_50_filtered.mat']);
NumImg = length(ImageStatsFiltered);

%% load MSCOCO val set
FileDir = '/media/mengmi/DATA/Datasets/MSCOCO/';
dataType='val2014';

%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
annType=annTypes{1}; % specify dataType/annType
annFile=sprintf([FileDir 'annotations/%s_%s.json'],annType,dataType);
coco=CocoApi(annFile);

AllImgIds = coco.getImgIds();
SImgIDList = extractfield(ImageStatsFiltered,'imgID');
AllImgIds = setxor(AllImgIds,SImgIDList);

FirstTEN = 5; %only store the first ten for each image
similarity = [];

for imgnum = 1: NumImg %the current image id
    
    display(['processing image #' num2str(imgnum)]);
    
    node = ImageStatsFiltered(imgnum);
    %img = coco.loadImgs(node.imgID);
    %I = imread(sprintf([FileDir '%s/%s'],dataType,img.file_name));
    AllannIds = coco.getAnnIds('imgIds',node.imgID);    
    Allanns = coco.loadAnns(AllannIds);
    Sobjids = extractfield(Allanns,'category_id');
    
    listImgIds = [];
    listCommonNum = [];
    
    for al = 1:length(AllImgIds)
        if ismember(AllImgIds(al), SImgIDList) 
            continue;
        end
        AllannIds = coco.getAnnIds('imgIds',AllImgIds(al));    
        Allanns = coco.loadAnns(AllannIds);
        
        if length(Allanns) == 0
            continue;
        end
        
        Cobjids = extractfield(Allanns,'category_id');
        prevnum = length(Cobjids);
       
        %find common intersects; including repetitions
        for s = 1:length(Sobjids)
            [D C] = find(Cobjids == Sobjids(s));
            if ~isempty(D)                
                Cobjids(C(1)) = [];
            end
        end
        nownum = length(Cobjids);
        
        CommonNum = prevnum - nownum;
        listImgIds =[ listImgIds AllImgIds(al)];
        listCommonNum =[listCommonNum CommonNum];
        
    end
    copylistImgIds = listImgIds;
    
    % sort and remove the selected images
    [D I] = sort(listCommonNum,'descend');
    copylistImgIds = copylistImgIds(I);
    D = D(1:FirstTEN);
    copylistImgIds = copylistImgIds(1:FirstTEN);
    AllImgIds = setxor(AllImgIds,copylistImgIds);
    
    ss.similarity=copylistImgIds;
    ss.similarityObjNums = D;
    
    % dissimilar
    copylistImgIds = listImgIds;
    [D I] = sort(listCommonNum);
    copylistImgIds = copylistImgIds(I);
    D = D(1:FirstTEN);
    copylistImgIds = copylistImgIds(1:FirstTEN);
    AllImgIds = setxor(AllImgIds,copylistImgIds);
    
    ss.dissimilarity=copylistImgIds;
    ss.dissimilarityObjNums = D;
    
    similarity = [similarity ss];
    
    %copy those selected images and generate in the folder for fc
    %extraction using vgg16
    for s = 1:length(ss.similarity)
        img = coco.loadImgs(ss.similarity(s));
        imgname = sprintf([FileDir '%s/%s'],dataType,img.file_name);
        I = imread(imgname);
        imwrite(I,['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name]);
    end
    
    for s = 1:length(ss.dissimilarity)
        img = coco.loadImgs(ss.dissimilarity(s));
        imgname = sprintf([FileDir '%s/%s'],dataType,img.file_name);
        I = imread(imgname);
        imwrite(I,['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name]);
    end
    
end
save('similarity_expH.mat','similarity');