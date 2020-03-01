clear all; close all; clc;

expname = 'expG';

load(['/home/mengmi/Projects/Proj_context2/Matlab/ModelTestLabels/Test_' expname '.mat']);

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

mturkData = [];
answer = [];  


TSPlist = [3 5 9; 4 6 10; 6 8 12; 10 12 16];%[3 5 9 3 5 9];
truetype = [1 2 3; 4 5 6; 7 8 9; 10 11 12];
typelist = [1 2 3 4];

for i = 1:length(Test.TbinL)
    i
    vec_bin = Test.TbinL(i);
    vec_cate = Test.TcateL(i);
    vec_img = Test.TimgL(i);
    %vec_type = Test.TtypeL(i);
    vec_label = Test.TlabelL(i);

    for t =1:length(typelist)
        vec_type = typelist(t);

        loadname = ['trial_' num2str(vec_bin) '_'  num2str(vec_cate)  '_' num2str(vec_img) '_screen2_imgtype_8_'  num2str(vec_type) '.mat'];

        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_obj/results_' expname '/' loadname]);
        %load(['/home/mengmi/Projects/Proj_context2/pytorch/recurrentVA_lstm/results_' expname '/' loadname]);
        load(['/home/mengmi/Projects/Proj_context2/pytorch/fovea_grid/results_' expname '/' loadname]);
        
        for TSP = 1:3
            PredTStep = TSPlist(t,TSP); 
            ans = struct();    
            ans.response = nms{predicted_seq(PredTStep)+1}; %pytorch index starting from 0
            ans.trial = i;    
            ans.bin = vec_bin;
            ans.cate = vec_cate;
            ans.obj = vec_img;
            ans.type = truetype(t,TSP);
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

%save(['Mat/clicknet_noalphaloss_lstm_' expname '.mat'],'mturkData');
save(['Mat/foveanet_' expname '.mat'],'mturkData');
    