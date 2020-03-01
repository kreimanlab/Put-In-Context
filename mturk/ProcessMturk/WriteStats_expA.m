clear all; close all hidden; clc;

% Exp A
% 
% Object size 
% 
% CO ratio = [contour, box,, 2, 4, …, full]
% 
% 
% 
% Main questions in Exp A:
% 
% 	(1) Effect of object size
% 
% 	(2) Effect of CO ratio
% 
% 	(3) In-lab versus M-turk experiments
% 
% 
% 
% (1)+(2)
% 
% https://en.wikipedia.org/wiki/Two-way_analysis_of_variance
% 
% https://www.mathworks.com/help/stats/anova2.html
% 
% 
% 
% Two-way anova with object size and CO ratio as the main variables
% 
% 
% 
% (3) Compare mturk versus in lab for every condition using ranksum test

expname = 'expA';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:4];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

COratio = [1:8];
coratiostr={'Contour','Bbox','CO=2','CO=4','CO=8','CO=16','CO=128','FC'};

GP1 = [];
GP2 = [];
correct = [];

for v = VisBin
    counter = 0;
    
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        correct = [correct Dbar];
        counter = counter + length(Dbar);
        
        GP2 = [GP2 ones(1,length(Dbar))*c];
    end
    GP1 = [GP1 ones(1,counter)*v];
end

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','COratio'});

[p,h,stats] = ranksum(subjStats{4,8}, subjStats{4,1},'tail','both');
display(['Vsiual Bin 4 ; Contour; FullContext: p-val=' num2str(p) '; n1=' num2str(length(subjStats{4,8})) '; n2='  num2str(length(subjStats{4,1})) ]);
        

%% model
modelname = 'clicknet_noalphaloss';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelStats = subjStats;

GP1 = [];
GP2 = [];
correct = [];

for v = VisBin
    counter = 0;
    
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        correct = [correct Dbar];
        counter = counter + length(Dbar);
        
        GP2 = [GP2 ones(1,length(Dbar))*c];
    end
    GP1 = [GP1 ones(1,counter)*v];
end

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','COratio'});

%% model vs humans
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

for v = VisBin
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        Mbar = modelStats{v,c};
        Mbar(isnan(Mbar)) = [];
        
        [p,h,stats] = ranksum(Dbar, Mbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; Human vs Model: p-val=' num2str(p) '; n1=' num2str(length(Dbar)) '; n2='  num2str(length(Mbar)) ]);
        
        
    end
    
end




















