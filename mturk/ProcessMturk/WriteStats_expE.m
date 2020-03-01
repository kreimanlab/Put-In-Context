clear all; close all hidden; clc;

% Exp E
% 
% 
% 
% For each visual size [ 1 2 4]:
% 
% 	Compare performance versus the full context condition (ranksum test)
% 
% 	Compare performance versus the bounding box condition (ranksum test)
% 
% reporting format in text for ranksum: ranksum, U = 10.5, n1 = n2 = 8, P < 0.05 two-tailed


expname = 'expE';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:3];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

COratio = [1:4];%exclude first two conditions
coratiostr={'Jigsaw2x2','Jigsaw 4x4','Jigsaw 8x8','PorscillaBG','FullContext','BBox'}; 

% 2-way anova; study effect of jigsaw size
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

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','jigsaw'});

% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,5};
    BBOX = subjStats{v,6};
    
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        [p,h,stats] = ranksum(FC, Dbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; FC: p-val=' num2str(p) '; n1=' num2str(length(FC)) '; n2='  num2str(length(Dbar)) ]);
        
        [p,h,stats] = ranksum(BBOX, Dbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; BBOX: p-val=' num2str(p) '; n1=' num2str(length(BBOX)) '; n2='  num2str(length(Dbar)) ]);
        
    end
    
end

%% model
modelname = 'clicknet_noalphaloss';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelStats = subjStats;

%add full context and bbox into modelStats
modelname = 'clicknet_noalphaloss';
load(['Mat/stats_expA_' modelname '.mat']);
for v = VisBin
    modelStats{v,5}= subjStats{v,8};
    modelStats{v,6}= subjStats{v,2};    
end

subjStats = modelStats;

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

% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,5};
    BBOX = subjStats{v,6};
    
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        [p,h,stats] = ranksum(FC, Dbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; FullContext: p-val=' num2str(p) '; n1=' num2str(length(FC)) '; n2='  num2str(length(Dbar)) ]);
        
        [p,h,stats] = ranksum(BBOX, Dbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; BBOX: p-val=' num2str(p) '; n1=' num2str(length(BBOX)) '; n2='  num2str(length(Dbar)) ]);
        
    end
    
end

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

