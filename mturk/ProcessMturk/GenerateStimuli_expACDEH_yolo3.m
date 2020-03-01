clear all; close all; clc;

expnamelist = {'expA','expC','expD','expE','expH'};

for e = 1:length(expnamelist)
    expname = expnamelist{e};
    
    load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

    load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
    nms = extractfield(ImageStatsFiltered,'classname');
    nms = unique(nms);

    mturkData = [];
    answer = [];  
    mkdir(['/home/mengmi/Desktop/PyTorch-YOLOv3/stimuli_' expname]);
    
    parfor i = 1:1000 %length(Test.TbinL)
        i
        vec_bin = Test.TbinL(i);
        vec_cate = Test.TcateL(i);
        vec_img = Test.TimgL(i);
        vec_type = Test.TtypeL(i);
        vec_label = Test.TlabelL(i);

        if strcmp(expname, 'expA')
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat'];
        elseif strcmp(expname, 'expC')
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_'  num2str(vec_type) '_blur.mat'];
        elseif strcmp(expname, 'expD')
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_'  num2str(vec_type) '_blur.mat'];
        elseif strcmp(expname, 'expE')
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat'];
        elseif strcmp(expname, 'expH')
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat'];
        else
            error(['the experiment name is incorrect']);
        end
        stimuliname = [loadname(1:end-4) '.jpg'];

        imgsize = 416;
        stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
        stimuli = imresize(stimuli, [imgsize imgsize]);
        imwrite(stimuli,['/home/mengmi/Desktop/PyTorch-YOLOv3/stimuli_' expname '/' stimuliname]);
    end
end