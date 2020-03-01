clear all; close all hidden; clc;

% Exp D 
% 
% 
% 
% Blur background
% 
% Effect of sigma = [ 1, 2, 4, 8, 16, 32]
% 
% Effect of object size = [ 1 2 4]
% 
% 
% 
% Main questions in Exp D:
% 
% 	Effect of blurring
% 
% 	
% 
% Option 1: Two-way anova with object size and blur sigma as the main variables
% 
% 
% 
% Option 2 (focusing on the effect of blurring)
% 
% For each object size = [ 1 2 4, analyzed separately]
% 
% 	one-way anova for effect of sigma
% reporting format for anova in text: F(x, y) = X, p = Y

expname = 'expD';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:3];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

COratio = [3:7];%exclude first two conditions
coratiostr={'Bbox', 'FC', 'Sigma 2', 'Sigma 4','Sigma 8 ','Sigma 16','Sigma 32'}; 

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

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','ObjBlur'});

% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,2};
    BBOX = subjStats{v,1};
    
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

%add full context and bbox into modelStats
modelname = 'clicknetS';
load(['Mat/stats_expA_' modelname '.mat']);

modelStats = {};
for v = VisBin
    modelStats{v,2}= subjStats{v,8};
    modelStats{v,1}= subjStats{v,2};    
end

modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
for v = VisBin
    for c = COratio
        modelStats{v,c}= subjStats{v,c};        
    end
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

p = anovan(correct,{GP1 GP2},'model',2,'varnames',{'VisualBin','ContextBlur'});

% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,2};
    BBOX = subjStats{v,1};
    
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


















