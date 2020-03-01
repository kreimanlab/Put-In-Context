clear all; close all; clc;

barcolor = [1     1     1; ...
    0.8314    0.8157    0.7843;...
    0.5020    0.5020    0.5020;...
    0     0     0];
    
%generate 110 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 10; %330*12/10;
load('DatasetStats.mat');
load('ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

expname = 'expA';

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
    
    [binL,cateL,imgL,typeL] = fcn_getPresentationInList(DatasetStats,CateChoiceList,AccumulateFiltered);
    labelL = [];
    
    for j = 1:length(binL)
        vec_cate = cateL(j);
        vec_bin = binL(j);
        vec_obj = imgL(j);
        vec_type = typeL(j);
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
        classname = ImageStatsFiltered(indimg).classname;
        label = find(strcmp(nms,classname));
        labelL = [labelL label];
        
        oripath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen2_imgtype_' num2str(vec_type) '.jpg'];
        binpath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen1_binarybdbox.jpg'];
        
        
        fprintf(fileIDori,'%s\n',oripath);
        fprintf(fileIDbin,'%s\n',binpath);
        fprintf(fileIDlabel,'%d\n',label);
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

