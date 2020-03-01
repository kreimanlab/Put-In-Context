clear all; close all; clc;

startcolor = [0.8706    0.9216    0.9804];
overcolor = [0.3922    0.4745    0.6353];
bboxcolor = [1 1 1];
fccolor = [0 0 0];
edgecommon = [ 0 0 0];
edgegroupcolor = [1 1 0; 0 1 0; 1 0 1]; %yellow; green, cyan
modelselect = 1; %'clicknetS',
modellist = {'mturk','clicknetA','two-stream', 'clicknet', 'four-channel',...
    'vggcrimg', 'deeplab', 'yolo3','clicknet_noalphaloss','clicknet_noalphaloss_lstm',...
    'foveanet_feedforward','foveanet','foveanetConvLSTM'};
Textstrlist = {'Human','VGG16+Attention','Two-stream VGG16','VGG16+Attention+LSTM',...
    'VGG16+BinaryMask','VGG16','DeepLab','YOLO3',...
    'CATNet','CATNetA','FOVEANET','FOVEANET-600-Atten','convLSTM'};

modelname = modellist{modelselect}; %clicknet_noalphaloss, mturk
Textstr2 = Textstrlist{modelselect}; %Human CATNet

%'clicknetA, traditional clicknet without lstm moduel; just feed-forward
%'two-stream', eric and kevin model
%'clicknet', clicknet without two-stream
%'four-channel', concatenation of binary mask and rgb input image
%'vggcrimg', 'deeplab', 'yolo3',
%'clicknetS', two-stream clicknet
%'clicknet_noalphaloss': clicknetS without alphaloss
% 
%% exp A1: object size
expname = 'expA';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[2 8]);
subjplot_std = subjplot_std(:,[2 8]);

load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 8]);
subjplot_std = subjplot_std(:,[2 8]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expA1; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp A2: object size
expname = 'expA';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[2 1 3 4 5 6 7 8]);
expname = 'expA';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 1 3 4 5 6 7 8]);
subjplot_std = subjplot_std(:,[2 1 3 4 5 6 7 8]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expA2; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp B1: context resolution 
expname = 'expC';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[2 3:end 1]);

expname = 'expC';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 3:end 1]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expB1; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp B2: object resolution 
expname = 'expD';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[2 3:end 1]);

expname = 'expD';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 3:end 1]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expB2; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp B3: texture only
expname = 'expE';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[6 4 5]);

expname = 'expE';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[6 4 5]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expB3; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp B4: jigsaw
expname = 'expE';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[5 1:3 6]);

expname = 'expE';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[5 1:3 6]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expB4; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);

%% exp B5: congruent
expname = 'expH';
load(['Mat/stats_' expname '_mturk.mat']);
Hsubjplot_mean = subjplot_mean(:,[3 1:2 4]);

expname = 'expH';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[3 1:2 4]);

subjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(Hsubjplot_mean)) = [];
Hsubjplot_mean(isnan(subjplot_mean)) = [];
subjplot_mean(isnan(subjplot_mean)) = [];

R = corr(Hsubjplot_mean(:),subjplot_mean(:));
display([Textstr2 ': expB5; R =' num2str(R) '; mean =' num2str(nanmean(subjplot_mean(:)))]);
