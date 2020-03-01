clear all; close all; clc;

modelnamelist = {'vggcrimg'; 'two-stream'; 'four-channel'};
modelfolderlist = {'vgg16_finetune_crimg'; 'kevin'; 'vgg16_finetune_img'};
modelSelect = 3;

modelname = modelnamelist{modelSelect}; %vggcrimg; two-stream; four-channel
modelfolder = modelfolderlist{modelSelect}; %vgg16_finetune_crimg; kevin; vgg16_finetune_img
expnamelist = {'expA','expC','expD','expE','expH'};
PredTStep = 1;

for e = 1:length(expnamelist)
    expname = expnamelist{e};
    
    load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

    load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
    nms = extractfield(ImageStatsFiltered,'classname');
    nms = unique(nms);

    mturkData = [];
    answer = [];  

    for i = 1:length(Test.TbinL)
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
        load(['/home/mengmi/Projects/Proj_context2/pytorch/' modelfolder '/results_' expname '/' loadname]);
        stimuliname = [loadname(1:end-4) '.jpg'];

        %% show alpha maps
    %     for t = 1:9
    %         imgsize = 400;
    %         stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
    %         attentionmap = reshape(alphas(t,:), [sqrt(size(alphas,2)), sqrt(size(alphas,2))]);
    %         attentionmap = attentionmap';
    %         attentionmap = mat2gray(attentionmap);
    %         attentionmap = imresize(attentionmap, [imgsize imgsize]);
    %         hsize = [20 20];
    %         sigma = 5;
    %         H = fspecial('gaussian',hsize,sigma);
    %         attentionmap = imfilter(attentionmap,H,'replicate');
    %         attentionmap = mat2gray(attentionmap);
    %         heat = heatmap_overlay(stimuli,attentionmap);
    %         subplot(3,3,t);
    %         imshow(heat);
    %         title(['step =' num2str(t)]);
    %     end
    %     drawnow;
    %     pause;

        ans = struct();    
        ans.response = nms{predicted_seq(PredTStep)+1}; %pytorch index starting from 0
        ans.trial = i;    
        ans.bin = vec_bin;
        ans.cate = vec_cate;
        ans.obj = vec_img;
        ans.type = vec_type;
        ans.correct = double(vec_label == predicted_seq(PredTStep)+1);

        answer = [answer ans];


    end
    subj.workerid = modelname;
    subj.assignmentid = modelname;
    subj.numhits = length(answer);
    subj.answer = answer;
    subj.videorecord = 0;
    mturkData = [mturkData subj];

    save(['Mat/' modelname '_' expname '.mat'],'mturkData');
    
end