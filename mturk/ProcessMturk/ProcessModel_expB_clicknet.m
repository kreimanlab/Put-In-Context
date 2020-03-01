clear all; close all; clc;

expname = 'expB';

load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

mturkData = [];
answer = [];  

TSPlist = [10 12 16 10 12 16];%[3 5 9 3 5 9];
typelist = [4 5 6 10 11 12];

% get those with porscilla mask
counter = 0;
for i = 1:2:length(Test.TbinL)
    i
    vec_bin = Test.TbinL(i);
    vec_cate = Test.TcateL(i);
    vec_img = Test.TimgL(i);
    vec_label = Test.TlabelL(i);

    for t = 1:length(typelist)
        counter = counter + 1;
        if t>3
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_8_' num2str(typelist(t)) '.mat'];
        else
            loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_2_' num2str(typelist(t)) '.mat'];
        end
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '/' loadname]);
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_lstm/results_' expname '/' loadname]);
        load(['/home/mengmi/Projects/Proj_context2/pytorch/fovea_grid/results_' expname '/' loadname]);
        
        PredTStep  = TSPlist(t);
        ans = struct();    
        ans.response = nms{predicted_seq(PredTStep)+1}; %pytorch index starting from 0
        ans.trial = counter;    
        ans.bin = vec_bin;
        ans.cate = vec_cate;
        ans.obj = vec_img;
        ans.type = typelist(t);
        ans.correct = double(vec_label == predicted_seq(PredTStep)+1);

        answer = [answer ans];
    end
end

% let's get other types where we can obtain from expA
load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_expA.mat']);
TSPlist = [2 4 8];
type2list = [1 2 3];
type8list = [7 8 9];

for i = 1:length(Test.TbinL)
        i
        vec_bin = Test.TbinL(i);
        vec_cate = Test.TcateL(i);
        vec_img = Test.TimgL(i);
        vec_type = Test.TtypeL(i);
        vec_label = Test.TlabelL(i);
        
        if vec_type ~= 2 && vec_type~=8
            continue;
        end

        if vec_type == 2
            for t = 1:length(TSPlist)
                counter = counter + 1;
                loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat'];
                PredTStep  = TSPlist(t);
                %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_expA/' loadname]);
                %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_lstm/results_expA/' loadname]);
                load(['/home/mengmi/Projects/Proj_context2/pytorch/fovea_grid/results_expA/' loadname]);
        
                ans = struct();    
                ans.response = nms{predicted_seq(PredTStep)+1}; %pytorch index starting from 0
                ans.trial = counter;    
                ans.bin = vec_bin;
                ans.cate = vec_cate;
                ans.obj = vec_img;
                ans.type = type2list(t);
                ans.correct = double(vec_label == predicted_seq(PredTStep)+1); 
                
                answer = [answer ans];
            end
        elseif vec_type == 8
            for t = 1:length(TSPlist)
                counter = counter + 1;
                loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_'  num2str(vec_type) '.mat'];
                PredTStep  = TSPlist(t);
                
                %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_lstm/results_expA/' loadname]);
                load(['/home/mengmi/Projects/Proj_context2/pytorch/fovea_grid/results_expA/' loadname]);
        
                %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_expA/' loadname]);
                ans = struct();    
                ans.response = nms{predicted_seq(PredTStep)+1}; %pytorch index starting from 0
                ans.trial = counter;    
                ans.bin = vec_bin;
                ans.cate = vec_cate;
                ans.obj = vec_img;
                ans.type = type8list(t);
                ans.correct = double(vec_label == predicted_seq(PredTStep)+1);
                
                answer = [answer ans];
            end
        end
end
subj.workerid = 'model';
subj.assignmentid = 'model';
subj.numhits = length(answer);
subj.answer = answer;
subj.videorecord = 0;
mturkData = [mturkData subj];

%save(['Mat/clicknet_noalphaloss_lstm_expB.mat'],'mturkData');
save(['Mat/foveanet_expB.mat'],'mturkData');
    
