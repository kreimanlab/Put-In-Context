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


%% pre-filter images to be rgb 3 channels for vgg16
% imglist = dir(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/*.jpg']);
% for i = 1:length(imglist)
%     i
%     img = imread(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/' imglist(i).name]);
%     if length(size(img))~=3
%         img = cat(3, img, img, img);
%         imwrite(img,['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/' imglist(i).name]);
%     end
% end
% pause;

%% load similarity matrix
load('similarity_expH.mat');
if length(similarity)~= NumImg
    error('sth wrong');
end

%% start computing euclidean dist and picking the most similar image
for i = 1:NumImg
    display(['processing img: ' num2str(i)]);
    node = ImageStatsFiltered(i);
    
    imgorifullname = ['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ];
    It = imread(imgorifullname);
    load([imgorifullname(1:end-4) '.mat']);
    pst = double(ps);
    %     img = imread(imgorifullname);    
%     
%     if length(size(img))~=3
%         img = cat(3, img, img, img);
%         imwrite(img,['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/img/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '.jpg' ]);
%     end
    
    
    %find the most similar image based on fc7 difference in vgg16
    ss = similarity(i);
    maximgid = 0;
    maxeucliddist = Inf;
    
    for s = 1:length(ss.similarity)
        simgid = ss.similarity(s);
        img = coco.loadImgs(simgid);
        I = imread(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name]);
        load(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name(1:end-4) '.mat']);
        psc = double(ps);
        edist = norm(psc-pst,2);
        
        if edist < maxeucliddist
            maximgid = simgid;
            maxeucliddist = edist;
            Isim = I;
        end
    end
    
    %find the most dissimilar image based on fc7 difference in vgg16
    
    maximgid = 0;
    maxeucliddist =0;
    
    for s = 1:length(ss.dissimilarity)
        simgid = ss.dissimilarity(s);
        img = coco.loadImgs(simgid);
        I = imread(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name]);
        load(['/media/mengmi/DATA/Projects/Proj_Context2/Datasets/testimg_valset/'  img.file_name(1:end-4) '.mat']);
        psc = double(ps);
        edist = norm(psc-pst,2);
        
        if edist > maxeucliddist
            maximgid = simgid;
            maxeucliddist = edist;
            Idis = I;
        end
    end
    size0 = size(It);
    size0 = size0(1:2);
    Isim = imresize(Isim, size0);
    Idis = imresize(Idis, size0);
    
    imwrite(Isim,['Stimulus/img_similarity/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_sim.jpg' ]);
    imwrite(Idis,['Stimulus/img_similarity/img_' num2str(node.bin) '_' num2str(node.classlabel)  '_' num2str(node.objIDinCate) '_dis.jpg' ]);
    
end