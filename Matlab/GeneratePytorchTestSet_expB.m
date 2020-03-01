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
MatAll = [binList; classList; objList]';

%find those with porscilla masks
MatAllExist = [];
for i = 1:size(MatAll, 1)
    porscillapath = ['Stimulus/keyframe_expB/trial_' num2str(MatAll(i,1)) '_' num2str(MatAll(i,2)) '_' num2str(MatAll(i,3)) '_PortillaMask.jpg'];
    %pmask = imread(porscillapath);
    if exist(porscillapath, 'file') == 2
        vec = [MatAll(i,1) MatAll(i,2) MatAll(i,3)];
        MatAllExist = [MatAllExist; vec];
    end
end
seq = randperm(size(MatAllExist,1),size(MatAllExist,1));
seq = seq(1:500);
MatAllExist = MatAllExist(seq,:);

expname = 'expB';

oriimgfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_oriimg.txt'];
binimgtextfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_binimg.txt'];
labeltextfile = ['/home/mengmi/Projects/Proj_context2/Datalist/test_' expname '_Color_label.txt'];
fileIDori = fopen(oriimgfile,'w');
fileIDbin = fopen(binimgtextfile,'w');
fileIDlabel = fopen(labeltextfile,'w');

TbinL = [];
TcateL = [];
TimgL = [];
TlabelL=[];    

for s = 1:size(MatAllExist,1)
    
    vec_cate = MatAllExist(s,2);
    vec_bin = MatAllExist(s,1);
    vec_obj = MatAllExist(s,3);
    
    indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
    classname = ImageStatsFiltered(indimg).classname;
    label = find(strcmp(nms,classname));
    
    oripath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen2_imgtype_2.jpg'];
    binpath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen1_binarybdbox.jpg'];


    fprintf(fileIDori,'%s\n',oripath);
    fprintf(fileIDbin,'%s\n',binpath);
    fprintf(fileIDlabel,'%d\n',label);
    
    oripath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen2_imgtype_8.jpg'];
    binpath = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_obj) '_screen1_binarybdbox.jpg'];


    fprintf(fileIDori,'%s\n',oripath);
    fprintf(fileIDbin,'%s\n',binpath);
    fprintf(fileIDlabel,'%d\n',label);
    
    TbinL = [TbinL vec_bin vec_bin];
    TcateL = [TcateL vec_cate vec_cate];
    TimgL = [TimgL vec_obj vec_obj];
    TlabelL = [TlabelL label label];
    
end

fclose(fileIDori);
fclose(fileIDbin);
fclose(fileIDlabel);


Test.TbinL = TbinL;
Test.TcateL = TcateL;
Test.TimgL = TimgL;
Test.TlabelL = TlabelL;

save(['ModelTestLabels/Test_' expname '.mat'],'Test');
