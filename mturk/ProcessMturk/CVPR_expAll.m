clear all; close all; clc;

startcolor = [0.8706    0.9216    0.9804];
overcolor = [0.3922    0.4745    0.6353];
bboxcolor = [1 1 1];
fccolor = [0 0 0];
edgecommon = [ 0 0 0];
edgegroupcolor = [1 1 0; 0 1 0; 1 0 1]; %yellow; green, cyan
modelselect = 13; %'clicknetS',
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
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 8]);
subjplot_std = subjplot_std(:,[2 8]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [bboxcolor; barcolor; fccolor];
FigPos = [592         376       400         599];
LegPos = [0.36 0.76 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp A1 ' Textstr2];
FigName = ['expA1_' modelname];
LegName = {'Minimal Context','Full Context'};
XtickLabelName = {'Size 1','Size 2','Size 4','Size 8'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp A2: object size
expname = 'expA';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 1 3 4 5 6 7 8]);
subjplot_std = subjplot_std(:,[2 1 3 4 5 6 7 8]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [bboxcolor; barcolor; fccolor];
FigPos = [592         376        1600         599];
LegPos = [0.14 0.68 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp A2 ' Textstr2];
FigName = ['expA2_' modelname];
LegName = {'Minimal Context','CO=0','CO=2','CO=4','CO=8','CO=16','CO=128','Full Context'};
XtickLabelName = {'Size 1','Size 2','Size 4','Size 8'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp B1: context resolution 
expname = 'expC';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 3:end 1]);
subjplot_std = subjplot_std(:,[2 3:end 1]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [fccolor; barcolor; bboxcolor];
FigPos = [592         376       1000         599];
LegPos = [0.18 0.70 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp B1 ' Textstr2];
FigName = ['expB1_' modelname];
LegName = {'Full Context','Sigma=2','Sigma=4','Sigma=8','Sigma=16','Sigma=32','Minimal Context'};
XtickLabelName ={'Size 1','Size 2','Size 4'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp B2: object resolution 
expname = 'expD';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[2 3:end 1]);
subjplot_std = subjplot_std(:,[2 3:end 1]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [fccolor; barcolor; bboxcolor ];
FigPos = [592         376       1000         599];
LegPos = [0.18 0.70 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp B2 ' Textstr2];
FigName = ['expB2_' modelname];
LegName = {'Full Context','Sigma=2','Sigma=4','Sigma=8','Sigma=16','Sigma=32','Minimal Context'};
XtickLabelName ={'Size 1','Size 2','Size 4'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp B3: texture only
expname = 'expE';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[6 4 5]);
subjplot_std = subjplot_std(:,[6 4 5]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [bboxcolor; barcolor; fccolor];
FigPos = [592         376       500         599];
LegPos = [0.28 0.73 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp B3 ' Textstr2];
FigName = ['expB3_' modelname];
LegName = {'Minimal Context','Portilla Mask','Full Context'};
XtickLabelName ={'Size 1','Size 2','Size 4'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp B4: jigsaw
expname = 'expE';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[5 1:3 6]);
subjplot_std = subjplot_std(:,[5 1:3 6]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [fccolor; barcolor; bboxcolor];
FigPos = [592         376       800         599];
LegPos = [0.20 0.73 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp B4 ' Textstr2];
FigName = ['expB4_' modelname];
LegName = {'Full Context','Jigsaw2x2','Jigsaw4x4','Jigsaw8x8','Minimal Context'};
XtickLabelName ={'Size 1','Size 2','Size 4'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

%% exp B5: congruent
expname = 'expH';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean = subjplot_mean(:,[3 1:2 4]);
subjplot_std = subjplot_std(:,[3 1:2 4]);
NumConds = size(subjplot_mean,2)-2;
barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
barcolor = [fccolor; barcolor; bboxcolor];
FigPos = [592         376       800         599];
LegPos = [0.20 0.73 0.1 0.1];
TextPos = [0.57 0.97];
TextStr = ['Exp B5 ' Textstr2];
FigName = ['expB5_' modelname];
LegName = {'Full Context','Congruent','Incongruent','Minimal Context'};
XtickLabelName ={'Size 1','Size 2','Size 4','Size 8'};
edgecolor = repmat(edgecommon, NumConds+2, 1); 
fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor);

if strcmp(modelname, 'clicknet_noalphaloss') || strcmp(modelname, 'mturk') || strcmp(modelname, 'clicknet_noalphaloss_lstm') || strcmp(modelname, 'foveanet')
    
    %% exp C1: stimulus exposure time
    expname = 'expB';
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean = subjplot_mean(:,[1:3 7:9]);
    subjplot_std = subjplot_std(:,[1:3 7:9]);
    NumConds = size(subjplot_mean,2);
    barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
    FigPos = [592         376       800         599];
    LegPos = [0.22 0.73 0.1 0.1];
    TextPos = [0.57 0.97];
    TextStr = ['Exp C1 ' Textstr2];
    FigName = ['expC1_' modelname];
    LegName = {'Bbox-50ms','Bbox-100ms','Bbox-200ms','FullContext-50ms','FullContext-100ms','FullContext-200ms'};
    XtickLabelName ={'Size 1','Size 2','Size 4','Size 8'};
    edgecolor = repmat(edgecommon, NumConds, 1); 
    fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos,edgecolor);

    %% exp C2: backward mask effect
    expname = 'expB';
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean = subjplot_mean(:,[1:3 7:9 4:6 10:12]);
    subjplot_std = subjplot_std(:,[1:3 7:9  4:6 10:12]);
    NumConds = size(subjplot_mean,2);
    barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
    FigPos = [592         376       1294         599];
    LegPos = [0.20 0.63 0.1 0.1];
    TextPos = [0.57 0.97];
    TextStr = ['Exp C2 ' Textstr2];
    FigName = ['expC2_' modelname];
    LegName = {'Bbox-50ms-WoMask','Bbox-100ms-WoMask','Bbox-200ms-WoMask','FullContext-50ms-WoMask','FullContext-100ms-WoMask','FullContext-200ms-WoMask',...
        'Bbox-50ms-WMask','Bbox-100ms-WMask','Bbox-200ms-WMask','FullContext-50ms-WMask','FullContext-100ms-WMask','FullContext-200ms-WMask'};
    XtickLabelName ={'Size 1','Size 2','Size 4','Size 8'};
    edgecolor = repmat(edgecommon, NumConds, 1); 
    fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos,edgecolor);

    %% exp C3: Assynchronous
    expname = 'expG';
    load(['Mat/stats_' expname '_' modelname '.mat']);
    %subjplot_mean = subjplot_mean(:,[14  1:12 13]);
    %subjplot_std = subjplot_std(:,[14  1:12 13]);
    subjplot_mean = subjplot_mean(:,[14  1 4 7 10 2 5 8 11 3 6 9 12 13]);
    subjplot_std = subjplot_std(:,[14  1 4 7 10 2 5 8 11 3 6 9 12 13]);
    NumConds = 4; %size(subjplot_mean,2)-2;
    barcolor = [linspace(startcolor(1),overcolor(1),NumConds)', linspace(startcolor(2),overcolor(2),NumConds)', linspace(startcolor(3),overcolor(3),NumConds)'];
    barcolor = [bboxcolor; barcolor; barcolor; barcolor; fccolor];
    edgecolor = [edgecommon; edgegroupcolor(1,:); edgegroupcolor(1,:); edgegroupcolor(1,:); edgegroupcolor(1,:); ...
        edgegroupcolor(2,:); edgegroupcolor(2,:); edgegroupcolor(2,:); edgegroupcolor(2,:); ...
        edgegroupcolor(3,:); edgegroupcolor(3,:); edgegroupcolor(3,:); edgegroupcolor(3,:); edgecommon];
    FigPos = [592         376       1294         599];
    LegPos = [0.16 0.59 0.1 0.1];
    TextPos = [0.57 0.97];
    TextStr = ['Exp C3 ' Textstr2];
    FigName = ['expC3_' modelname];
    LegName = {'Minimal Context','C-25-O-50','C-50-O-50','C-100-O-50','C-200-O-50',...
        'C-25-O-100','C-50-O-100','C-100-O-100','C-200-O-100',...
        'C-25-O-200','C-50-O-200','C-100-O-200','C-200-O-200','Full Context'};
    XtickLabelName ={'Size 1','Size 2','Size 4','Size 8'};

    fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos,edgecolor);

end