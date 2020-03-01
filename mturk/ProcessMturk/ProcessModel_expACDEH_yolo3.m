clear all; close all; clc;

expnamelist = {'expA','expC','expD','expE','expH'};%'expA','expC','expD','expE','expH'
for e = 1:length(expnamelist)
    expname = expnamelist{e};

    load(['/home/mengmi/Projects/Proj_context2/mturk/ProcessMturk/Mat/Classlabel_yolo3.mat']); %validclass
    load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);
    load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
    nms = extractfield(ImageStatsFiltered,'classname');
    nms = unique(nms);

    mturkData = [];
    answer = [];  
    imgsize = 416;

    for i = 1:1000

        display(i);

        vec_bin = Test.TbinL(i);
        vec_cate = Test.TcateL(i);
        vec_img = Test.TimgL(i);
        vec_type = Test.TtypeL(i);
        vec_label = Test.TlabelL(i);

        %process the class labels in region of interest using majority voting

        if strcmp(expname, 'expA')
            loadname = ['trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat' ];
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

        if exist(['/home/mengmi/Desktop/PyTorch-YOLOv3/results_' expname '/' loadname], 'file') == 2 
            load(['/home/mengmi/Desktop/PyTorch-YOLOv3/results_' expname '/' loadname]);
        else
            ans = struct();    
            ans.response = 'NA'; %pytorch index starting from 0
            ans.trial = i;    
            ans.bin = vec_bin;
            ans.cate = vec_cate;
            ans.obj = vec_img;
            ans.type = vec_type;
            ans.correct = 0;

            answer = [answer ans];
        end


        gray = zeros(imgsize,imgsize);
        detections = ceil(detections);
        detections1 = detections(:,1:4);
        detections1(detections1<1) = 1;
        detections1(detections1>imgsize) = imgsize;

        for i = 1:size(detections,1)
            gray(detections1(i,2):detections1(i,4),detections1(i,1):detections1(i,3)) = detections(i,7)+1;
        end
        problabel = gray;
    % subplot(1,2,1);
    % imshow(mat2gray(gray))
    % subplot(1,2,2);
    % imshow(I)

    %     probs = double(probs);
    %     probs = probs(validclass,:,:);
    %     [a problabel] = max(probs,[],1);
    %     problabel = squeeze(problabel);
        bin = imread(['/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/keyframe_expA/trial_' num2str(vec_bin) '_' num2str(vec_cate) '_' num2str(vec_img) '_screen1_binarybdbox.jpg']);
        alpha = bin;
        alpha = imresize(alpha,size(problabel));
        alpha = double(im2bw(alpha));
        interest = problabel.*alpha;
        interest = interest(:);
        interest(interest == 0) = [];
        uv = unique(interest);    
        n  = histc(interest,uv);
        [temp maxind] = max(n);
        GPtest = uv(maxind);
        GPtest = mappingClass(GPtest); 

        if isempty(GPtest) | isnan(GPtest) 
            ans = struct();    
            ans.response = 'NA'; %pytorch index starting from 0
            ans.trial = i;    
            ans.bin = vec_bin;
            ans.cate = vec_cate;
            ans.obj = vec_img;
            ans.type = vec_type;
            ans.correct = 0;

            answer = [answer ans];
        else
            ans = struct();    
            ans.response = nms{GPtest}; %pytorch index starting from 0
            ans.trial = i;    
            ans.bin = vec_bin;
            ans.cate = vec_cate;
            ans.obj = vec_img;
            ans.type = vec_type;
            ans.correct = double(vec_label == GPtest);

            answer = [answer ans];
        end
    end

    subj.workerid = 'yolo3';
    subj.assignmentid = 'yolo3';
    subj.numhits = length(answer);
    subj.answer = answer;
    subj.videorecord = 0;
    mturkData = [mturkData subj];

    save(['Mat/yolo3_' expname '.mat'],'mturkData');
end
