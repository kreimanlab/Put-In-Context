clear all; close all; clc;

expnamelist = {'expA','expC','expD','expE','expH'};
selectedimg = [95 174;...
    22 39;...
    11 20;...
    16 23;...
    3 90];
t= 9;
PredTStep = 9;
NumExmples = 2;

for e = 1:length(expnamelist)
    expname = expnamelist{e};
    
    load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

    load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
    nms = extractfield(ImageStatsFiltered,'classname');
    nms = unique(nms);


    for i = selectedimg(e,:)
        
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
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '_calpha1/' loadname]);
        load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '/' loadname]);
        Cstimuliname = [loadname(1:end-4) '.jpg'];
        
        if strcmp(expname, 'expD')
            Ostimuliname = ['keyframe_expD/trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_' num2str(vec_type) '_crimg.jpg'];
        else
            Ostimuliname = ['keyframe_expA/trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen1_crimg.jpg'];
        end

        imgsize = 400;
        Cstimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' Cstimuliname]);
        Ostimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/' Ostimuliname]);
        
        Cattentionmap = reshape(alphas_context(t,:), [sqrt(size(alphas_context,2)), sqrt(size(alphas_context,2))]);
        Oattentionmap = reshape(alphas_obj(t,:), [sqrt(size(alphas_obj,2)), sqrt(size(alphas_obj,2))]);
        
        
        attentionmap = Cattentionmap';
        attentionmap = mat2gray(attentionmap);
        attentionmap = imresize(attentionmap, [imgsize imgsize]);
        hsize = [20 20];
        sigma = 5;
        H = fspecial('gaussian',hsize,sigma);
        attentionmap = imfilter(attentionmap,H,'replicate');
        attentionmap = mat2gray(attentionmap);
        %imshow(attentionmap);
        Cheat = heatmap_overlay(Cstimuli,attentionmap);
        %subplot(3,3,t);
        %imshow(heat);
        %title(['step =' num2str(t)]);
        
        attentionmap = Oattentionmap';
        attentionmap = mat2gray(attentionmap);
        attentionmap = imresize(attentionmap, [imgsize imgsize]);
        hsize = [20 20];
        sigma = 5;
        H = fspecial('gaussian',hsize,sigma);
        attentionmap = imfilter(attentionmap,H,'replicate');
        attentionmap = mat2gray(attentionmap);
        %imshow(attentionmap);
        Oheat = heatmap_overlay(Ostimuli,attentionmap);
        %subplot(3,3,t);
        %imshow(heat);
        %title(['step =' num2str(t)]);
        
        rsize = 400;
        Cstimuli = imresize(Cstimuli,[rsize rsize]);
        Cheat = imresize(Cheat,[rsize rsize]);
        Ostimuli = imresize(Ostimuli,[rsize rsize]);
        Oheat = imresize(Oheat,[rsize rsize]);
        
        display([expname '; labels: ' nms{vec_label} '; type: ' num2str(vec_type) '; bin:' num2str(vec_bin)]);
        imwrite(Cstimuli,['/home/mengmi/Desktop/qua/cstimuli_' expname '_' num2str(i) '.jpg']);
        imwrite(Ostimuli,['/home/mengmi/Desktop/qua/ostimuli_' expname '_' num2str(i)  '.jpg']);
        imwrite(Oheat,['/home/mengmi/Desktop/qua/Oheat_' expname '_' num2str(i)  '.jpg']);
        imwrite(Cheat,['/home/mengmi/Desktop/qua/Cheat_' expname '_' num2str(i)  '.jpg']);        

    end
end






















