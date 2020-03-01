clear all; close all hidden; clc;

% Exp H
% 
% Congruent and incongruent background
% 
% 
% 
% For each visual size separately: [1 2 4]
% 
% 	for context = congruent or incongruent separately : 
% 
% 		Ranksum. Comparison with full context condition
% 
% 		Ranksum. Comparison with bounding box condition.
% 
% 	
% 
% 	Also, separate analysis
% 
% 		Ranksum. Compare congruent versus incongruent.


expname = 'expH';
modelname = 'mturk' ; %'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:4];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

COratio = [1:2];%exclude first two conditions
coratiostr={'Congruent','Incongruent','FullContext','Boundbox'}; 


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

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','Congruent'});


% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,3};
    BBOX = subjStats{v,4};
    
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        [p,h,stats] = ranksum(FC, Dbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; FullContext: p-val=' num2str(p) '; n1=' num2str(length(FC)) '; n2='  num2str(length(Dbar)) ]);
        
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
    modelStats{v,3}= subjStats{v,8};
    modelStats{v,4}= subjStats{v,2};    
end

subjStats = modelStats;

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

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','Congruent'});



% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,3};
    BBOX = subjStats{v,4};
    
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

for v = [1:4]
    for c = COratio
        Dbar = subjStats{v,c};
        Dbar(isnan(Dbar)) = [];
        
        Mbar = modelStats{v,c};
        Mbar(isnan(Mbar)) = [];
        
        [p,h,stats] = ranksum(Dbar, Mbar,'tail','both');
        display([visbinstr{v} '; ' coratiostr{c} '; Human vs Model: p-val=' num2str(p) '; n1=' num2str(length(Dbar)) '; n2='  num2str(length(Mbar)) ]);
        
        
    end
    
end