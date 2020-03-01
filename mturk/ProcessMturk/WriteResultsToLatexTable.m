clear all; close all; clc;

%combine expA and expH together
expname = 'expA';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_expA = subjplot_mean;

expname = 'expH';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_expG = subjplot_mean;

expname = 'expA';
modelname = 'clicknetS'; %'clicknetS' 'deeplab';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelplot_mean_expA = subjplot_mean;

expname = 'expH';
modelname = 'clicknetS'; %'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelplot_mean_expG = subjplot_mean;
modelplot_mean_expG(:,3) = modelplot_mean_expA(:,8);
modelplot_mean_expG(:,4) = modelplot_mean_expA(:,2);

subjplot_mean = [subjplot_mean_expA subjplot_mean_expG; modelplot_mean_expA modelplot_mean_expG ];
subjplot_mean = subjplot_mean(:,1:12);

matrix = subjplot_mean*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]','[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
rowLabels = legendstring(1:size(matrix,1));
columnLabels = {'Contour','Bbox','CO=2','CO=4','CO=8','CO=16','CO=128','FullContext','Congruent','Incongruent','FC','BBox'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-3.1f');

%expB
expname = 'expB';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_exp = subjplot_mean;

expname = 'expB';
modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelplot_mean_exp = subjplot_mean;

subjplot_mean = [subjplot_mean_exp; modelplot_mean_exp];

matrix = subjplot_mean*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
rowLabels = legendstring(1:size(matrix,1));
% columnLabels = {'\shortstack{Bbox-WoM \\ 50 ms}','\shortstack{Bbox-WoM \\ 100 ms}','\shortstack{Bbox-WoM \\ 200 ms}',...
%     '\shortstack{Bbox-WM \\ 50 ms}','\shortstack{Bbox-WM \\ 100 ms}','\shortstack{Bbox-WM \\ 200 ms}',...
%     '\shortstack{FC-WoM \\ 50 ms}','\shortstack{FC-WoM \\ 100 ms}','\shortstack{FC-WoM \\ 200 ms}',...
%     '\shortstack{FC-WM \\ 50 ms}','\shortstack{FC-WM \\ 100 ms}','\shortstack{FC-WM \\ 200 ms}'};
columnLabels = {'50 ms','100 ms','200 ms',...
    '50 ms','100 ms','200 ms',...
    '50 ms','100 ms','200 ms',...
    '50 ms','100 ms','200 ms'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-3.1f');

%expG
expname = 'expG';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_exp = subjplot_mean;

expname = 'expG';
modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelplot_mean_exp = subjplot_mean;

subjplot_mean = [subjplot_mean_exp(:,1:12); modelplot_mean_exp(:,1:12)];

matrix = subjplot_mean*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
rowLabels = legendstring(1:size(matrix,1));
columnLabels = {'\shortstack{C-25 ms \\ O-50 ms}','\shortstack{C-50 ms \\ O-50 ms}','\shortstack{C-100 ms \\ O-50 ms}','\shortstack{C-200 ms \\ O-50 ms}',...
    '\shortstack{C-25 ms \\ O-100 ms}','\shortstack{C-50 ms \\ O-100 ms}','\shortstack{C-100 ms \\ O-100 ms}','\shortstack{C-200 ms \\ O-100 ms}',...
    '\shortstack{C-25 ms \\ O-200 ms}','\shortstack{C-50 ms \\ O-200 ms}','\shortstack{C-100 ms \\ O-200 ms}','\shortstack{C-200 ms \\ O-200 ms}'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-3.1f');


%% expA alone (all models)
expname = 'expA';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_plot = subjplot_mean;

modellist = {'clicknetS','deeplab', 'yolo3','vggcrimg','four-channel','clicknetA','clicknet','two-stream'};
VisualBinNum = 4;
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
legendstring = legendstring(1:VisualBinNum);
rowLabels = legendstring;

for modelselect = 1:length(modellist)
    modelname =modellist{modelselect};    
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean_plot = [subjplot_mean_plot; subjplot_mean];
    rowLabels = [rowLabels legendstring];
end

matrix = subjplot_mean_plot*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'alignment', 'c', 'format', '%-3.1f');

%% expC alone (all models)
expname = 'expC';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_plot = subjplot_mean;

modellist = {'clicknetS','deeplab', 'yolo3','vggcrimg','four-channel','clicknetA','clicknet','two-stream'};
VisualBinNum = 3;
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
legendstring = legendstring(1:VisualBinNum);
rowLabels = legendstring;

for modelselect = 1:length(modellist)
    modelname =modellist{modelselect};    
    load(['Mat/stats_expA_' modelname '.mat']);
    subjplot_meanA = subjplot_mean(1:VisualBinNum,:);
    
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean(:,1) = subjplot_meanA(:,2);
    subjplot_mean(:,2) = subjplot_meanA(:,8);
    
    subjplot_mean_plot = [subjplot_mean_plot; subjplot_mean];
    rowLabels = [rowLabels legendstring];
end

matrix = subjplot_mean_plot*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'alignment', 'c', 'format', '%-3.1f');

%% expD alone (all models)
expname = 'expD';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_plot = subjplot_mean;

modellist = {'clicknetS','deeplab', 'yolo3','vggcrimg','four-channel','clicknetA','clicknet','two-stream'};
VisualBinNum = 3;
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
legendstring = legendstring(1:VisualBinNum);
rowLabels = legendstring;

for modelselect = 1:length(modellist)
    modelname =modellist{modelselect};    
    load(['Mat/stats_expA_' modelname '.mat']);
    subjplot_meanA = subjplot_mean(1:VisualBinNum,:);
    
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean(:,1) = subjplot_meanA(:,2);
    subjplot_mean(:,2) = subjplot_meanA(:,8);
    
    subjplot_mean_plot = [subjplot_mean_plot; subjplot_mean];
    rowLabels = [rowLabels legendstring];
end

matrix = subjplot_mean_plot*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'alignment', 'c', 'format', '%-3.1f');


%% expE alone (all models)
expname = 'expE';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_plot = subjplot_mean;

modellist = {'clicknetS','deeplab', 'yolo3','vggcrimg','four-channel','clicknetA','clicknet','two-stream'};
VisualBinNum = 3;
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
legendstring = legendstring(1:VisualBinNum);
rowLabels = legendstring;

for modelselect = 1:length(modellist)
    modelname =modellist{modelselect};    
    load(['Mat/stats_expA_' modelname '.mat']);
    subjplot_meanA = subjplot_mean(1:VisualBinNum,:);
    
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean(:,6) = subjplot_meanA(:,2);
    subjplot_mean(:,5) = subjplot_meanA(:,8);
    
    subjplot_mean_plot = [subjplot_mean_plot; subjplot_mean];
    rowLabels = [rowLabels legendstring];
end

matrix = subjplot_mean_plot*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'alignment', 'c', 'format', '%-3.1f');

%% expH alone (all models)
expname = 'expH';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);
subjplot_mean_plot = subjplot_mean;

modellist = {'clicknetS','deeplab', 'yolo3','vggcrimg','four-channel','clicknetA','clicknet','two-stream'};
VisualBinNum = 4;
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[7 9]'};
legendstring = legendstring(1:VisualBinNum);
rowLabels = legendstring;

for modelselect = 1:length(modellist)
    modelname =modellist{modelselect};    
    load(['Mat/stats_expA_' modelname '.mat']);
    subjplot_meanA = subjplot_mean(1:VisualBinNum,:);
    
    load(['Mat/stats_' expname '_' modelname '.mat']);
    subjplot_mean(:,4) = subjplot_meanA(:,2);
    subjplot_mean(:,3) = subjplot_meanA(:,8);
    
    subjplot_mean_plot = [subjplot_mean_plot; subjplot_mean];
    rowLabels = [rowLabels legendstring];
end

matrix = subjplot_mean_plot*100;
filename = '/home/mengmi/Desktop/temp.tex';
legendstring = {'[0.5 1]','[1.75 2.25]','[3.5 4.5]','[0.5 1]','[1.75 2.25]','[3.5 4.5]'};
matrix2latex(matrix, filename, 'rowLabels', rowLabels, 'alignment', 'c', 'format', '%-3.1f');

