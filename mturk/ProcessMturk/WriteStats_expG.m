clear all; close all hidden; clc;

% Exp G
% 
% Duration of context presentation [25 50 100 200]
% 
% Duration of object presentation [50 100 200]
% 
% Visual size [ 1 2 4]
% 
% 
% 
% For each visual size [ 1 2 4 separately]:
% 
% 	For each context presentation duration [25 50 100 200 separtely]:
% 
% 		One-way ANOVA. Is there an effect of object presentation duration? 
% 
% 
% 
% 	For each object presentation duration: [50 100 200 separately]: 
% 
% 		One-way ANOVA. Is there an effect of context presentation duration? 
% 
% 
% 
% Separately
% 
% For each bar and for each visual size. Ranksum test comparison with full context synchronous condition
% 
% For each bar and for each visual size. Ranksum test comparison with bounding box condition

expname = 'expG';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:3];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

Ctime=[1:4]; %context time
ctimestr={'C-25ms','C-50ms','C-100ms','C-200ms'};

Otime = [1:3]; %object time
otimestr={'O-50ms','O-100ms','O-200ms'};

for v = VisBin
    
    
    for c = Ctime     
        
        GP2 = [];
        correct = [];
        for o=Otime
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            correct = [correct Dbar];
            GP2 = [GP2 ones(1,length(Dbar))*o];            
        end
        
        p = anova1(correct,GP2);
        %if p<0.05
            display([visbinstr{v} '; ' ctimestr{c} '; p-val= ' num2str(p)]);
        %end
    end
    
    for o=Otime       
        
        GP2 = [];
        correct = [];
        for c = Ctime    
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            correct = [correct Dbar];
            GP2 = [GP2 ones(1,length(Dbar))*c];            
        end
        
        p = anova1(correct,GP2);
        %if p<0.05
            display([visbinstr{v} '; ' otimestr{o} '; p-val= ' num2str(p)]);
       % end
    end
    
end



% ranksum with FC or bbox 
for v = VisBin
    
    FC = subjStats{v,13};
    BBOX = subjStats{v,14};
    
    for c = Ctime     
        
        for o=Otime
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            
            [p,h,stats] = ranksum(FC, Dbar,'tail','both');
            display([visbinstr{v} '; ' ctimestr{c} '; ' otimestr{o} '; FullContext: p-val=' num2str(p) '; n1=' num2str(length(FC)) '; n2='  num2str(length(Dbar)) ]);

            [p,h,stats] = ranksum(BBOX, Dbar,'tail','both');
            display([visbinstr{v} '; ' ctimestr{c} '; ' otimestr{o} '; BBOX: p-val=' num2str(p) '; n1=' num2str(length(BBOX)) '; n2='  num2str(length(Dbar)) ]);
                
        end        
    end    
    
end

%% model

expname = 'expG';
modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);

%add full context and bbox into modelStats
modelname = 'clicknetS';
load(['Mat/stats_expA_' modelname '.mat']);
for v = VisBin
    modelStats{v,13}= subjStats{v,8};
    modelStats{v,14}= subjStats{v,2};    
end


modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
for v = VisBin
    for c = [1:12]
        modelStats{v,c}= subjStats{v,c};        
    end
end
subjStats = modelStats;

for v = VisBin
    
    
    for c = Ctime     
        
        GP2 = [];
        correct = [];
        for o=Otime
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            correct = [correct Dbar];
            GP2 = [GP2 ones(1,length(Dbar))*o];            
        end
        
        p = anova1(correct,GP2);
        %if p<0.05
            display([visbinstr{v} '; ' ctimestr{c} '; p-val= ' num2str(p)]);
        %end
    end
    
    for o=Otime       
        
        GP2 = [];
        correct = [];
        for c = Ctime    
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            correct = [correct Dbar];
            GP2 = [GP2 ones(1,length(Dbar))*c];            
        end
        
        p = anova1(correct,GP2,'off');
        %if p<0.05
            display([visbinstr{v} '; ' otimestr{o} '; p-val= ' num2str(p)]);
       % end
    end
    
end

%% model vs humans
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

for v = VisBin
        
    for c = Ctime     
        
        for o=Otime
            Dbar = subjStats{v,3*(c-1)+o};
            Dbar(isnan(Dbar)) = [];
            
            Mbar = modelStats{v,3*(c-1)+o};
            Mbar(isnan(Mbar)) = [];

            [p,h,stats] = ranksum(Dbar, Mbar,'tail','both');
            display([visbinstr{v} '; ' ctimestr{c} '; ' otimestr{o} '; Human vs Model: p-val=' num2str(p) '; n1=' num2str(length(Dbar)) '; n2='  num2str(length(Mbar)) ]);
        
        
        end        
    end    
    
end
