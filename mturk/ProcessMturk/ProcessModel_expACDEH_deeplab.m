clear all; close all; clc;

expname = 'expH';
load(['/home/mengmi/Projects/Proj_context2/mturk/ProcessMturk/Mat/Classlabel_deeplab.mat']); %validclass
load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);
load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

mturkData = [];
answer = [];  

for i = 1:500
    
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
    load(['/home/mengmi/Projects/Proj_context2/pytorch/deeplab/results_' expname '/' loadname]);
    
    probs = double(probs);
    probs = probs(validclass,:,:);
    [a problabel] = max(probs,[],1);
    problabel = squeeze(problabel);
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
    GPtest = mappingClass(validclass(GPtest));    
    
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

subj.workerid = 'deeplab';
subj.assignmentid = 'deeplab';
subj.numhits = length(answer);
subj.answer = answer;
subj.videorecord = 0;
mturkData = [mturkData subj];

save(['Mat/deeplab_' expname '.mat'],'mturkData');
