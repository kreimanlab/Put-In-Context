clear all; close all; clc;

%match humans to gt labels
load('Mat/humanlabel.mat','HumanLabel');
load(['/home/mengmi/Projects/Proj_context2/pytorch/wordProcess/matchID.mat']);

%load nms
load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

%load model
%expnamelist = {'expA','expB','expC','expD','expE','expG','expH'};
expnamelist = {'expA','expC','expD','expE','expH'};
%modelname = 'clicknet_noalphaloss';
%modelname = 'foveanet_feedforward';
modelname = 'foveanet';

for e = 1:length(expnamelist)
    expname = expnamelist{e};
    load(['Mat/' modelname '_' expname '.mat']);
    
    for a = 1:length(mturkData.answer)
        res = mturkData.answer(a).response;
        %res
        [temp ind] = find(strcmp(nms,res)); 
        mturkData.answer(a).predLabel = ind;
        %mturkData.answer(a).predLabel
    end  
    save(['Mat/' modelname '_' expname '_confusion.mat'],'mturkData');
end



