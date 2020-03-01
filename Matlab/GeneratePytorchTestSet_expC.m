clear all; close all; clc;

%generate 110 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 10; %330*12/10;
%load('DatasetStats.mat');
load('ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

expname = 'expC';

oriimgfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_oriimg.txt'];
binimgtextfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_binimg.txt'];
labeltextfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_label.txt'];
fileIDori = fopen(oriimgfile,'w');
fileIDbin = fopen(binimgtextfile,'w');
fileIDlabel = fopen(labeltextfile,'w');

TbinL = [];
TcateL = [];
TimgL = [];
TtypeL = [];
TlabelL=[];
    
for s = 1:NumSet
    
    [binL,cateL,imgL,typeL] = fcn_getPresentationInListExpC(AccumulateFiltered);
    labelL = [];
    
    for j = 1:length(binL)
        vec_cate = cateL(j);
        vec_bin = binL(j);
        vec_obj = imgL(j);
        vec_type = typeL(j);
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
        classname = ImageStatsFiltered(indimg).classname;
        label = find(strcmp(nms,classname));
        
        
        if vec_type>=3
            oripath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_' num2str(vec_type) '_blur.jpg'];
            binpath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen1_binarybdbox.jpg'];
            labelL = [labelL label];
        
            fprintf(fileIDori,'%s\n',oripath);
            fprintf(fileIDbin,'%s\n',binpath);
            fprintf(fileIDlabel,'%d\n',label);
        end
        
    end
    
    binL(find(typeL<3)) = [];
    cateL(find(typeL<3)) = [];
    imgL(find(typeL<3)) = [];
    typeL(find(typeL<3)) = [];
    
    if length(binL) ~= length(labelL)
        error(['not equal']);
    end
    
    binL = reshape(binL, [1, length(binL)]);
    cateL = reshape(cateL, [1, length(cateL)]);
    imgL = reshape(imgL, [1, length(imgL)]);
    typeL = reshape(typeL, [1, length(typeL)]);
    labelL = reshape(labelL, [1, length(labelL)]);
    
    TbinL = [TbinL binL];
    TcateL = [TcateL cateL];
    TimgL = [TimgL imgL];
    TtypeL = [TtypeL typeL];
    TlabelL = [TlabelL labelL];
    
end

fclose(fileIDori);
fclose(fileIDbin);
fclose(fileIDlabel);


Test.TbinL = TbinL;
Test.TcateL = TcateL;
Test.TimgL = TimgL;
Test.TtypeL = TtypeL;
Test.TlabelL = TlabelL;

save(['ModelTestLabels/Test_' expname '.mat'],'Test');

display(['pytorch: write text files; completed']);