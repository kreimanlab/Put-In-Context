clear all; close all; clc;

mkdir(['/home/mengmi/Desktop/introcandidates/']);
expnamelist = {'expH'};
PredTStep = 9;
%18
for e = 1:length(expnamelist)
    expname = expnamelist{e};
    
    load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

    load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
    nms = extractfield(ImageStatsFiltered,'classname');
    nms = unique(nms);

    mturkData = [];
    answer = [];  

    for i = [2622 2625] %1:length(Test.TbinL)
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
        
        %recurrentVA_obj; recurrentVA_best
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '_calpha1/' loadname]);
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_best/results_' expname '/' loadname]);
        load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '/' loadname]);
        sc = softmax(score(PredTStep,:)');
        [ind ss] = sort(sc,'descend');
        ss = ss(1:5);
        ind = ind(1:5);
        ind
        stimuliname = [loadname(1:end-4) '.jpg'];

        ans = struct();    
        ans.response = nms{ss}; %pytorch index starting from 0
        ans.trial = i;    
        ans.bin = vec_bin;
        ans.cate = vec_cate;
        ans.obj = vec_img;
        ans.type = vec_type;
        ans.correct = double(vec_label == predicted_seq(PredTStep)+1);

        answer = [answer ans];
        
        if ans.correct==1 || vec_bin~=4 || vec_type~=2
            continue;
        end
        
        
        
        %% show alpha maps
        for t = 9:9
            imgsize = 400;
            stimuli = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_' expname '/' stimuliname]);
            ['Model: ' ans.response ' GT: ' nms{vec_label} '; conf: ' num2str(sc(predicted_seq(PredTStep)+1))]
            %stimuliT = insertText(stimuli, [1 1 ], ['Model: ' ans.response ' GT: ' nms{vec_label} '; conf: ' num2str(sc(predicted_seq(PredTStep)+1))],'FontSize',35);
%             imshow(stimuliT);
            nms{ss}
%             
%             pause;
            imwrite(stimuli,['/home/mengmi/Desktop/introcandidates/img_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_img) '_' num2str(i) '.jpg']);
            
            
%             flag = 1;
%             if flag == 1
%                 attentionmap = reshape(alphas_context(t,:), [sqrt(size(alphas_context,2)), sqrt(size(alphas_context,2))]);
%             else
%                 attentionmap = reshape(alphas_obj(t,:), [sqrt(size(alphas_obj,2)), sqrt(size(alphas_obj,2))]);
%             end
%             attentionmap = attentionmap';
%             attentionmap = mat2gray(attentionmap);
%             attentionmap = imresize(attentionmap, [imgsize imgsize]);
%             hsize = [20 20];
%             sigma = 5;
%             H = fspecial('gaussian',hsize,sigma);
%             attentionmap = imfilter(attentionmap,H,'replicate');
%             attentionmap = mat2gray(attentionmap);
%             imshow(attentionmap);
%             
%             heat = heatmap_overlay(stimuli,attentionmap);
%             subplot(1,2,1);
%             imshow(stimuli);  
%             title(['gt: ' nms{vec_label} '; conf: ' num2str(sc(predicted_seq(PredTStep)+1))]);
%             subplot(1,2,2);
%             imshow(heat);
%             title(['step =' num2str(vec_type) '; ' num2str(i) '; response:' ans.response]);
        end
%         drawnow;
%         pause;

        


    end
    
    
end