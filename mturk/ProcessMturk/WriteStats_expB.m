clear all; close all hidden; clc;

% Exp B
% 
% 
% 
% With mask or without mask
% 
% Visual angle (1, 2, 4)
% 
% Amount of context (box or full)
% 
% Presentation time 
% 
% 
% 
% Quick comment 1: no need to compare effects of amount of context here (bbox versus full context), we will already conclude that from Exp A
% 
% Quick comment 2: no need to compare effects of object size here (1, 2 or 4 degrees), we will already conclude that from Exp A
% 
% Main questions in Exp B:
% 
% 	(1) Does the exposure time matter? 
% 
% 	(2) Does backward masking matter? 
% 
% 	(3) Interactions between exposure time and backward masking
% 
% 
% 
% (1) 
% 
% For amount of context. = [bbox OR full context, analyze separately]
% 
% 	For visual angle = [1 2 4, analyze separately] 
% 
% 		For backward mask = [ON or OFF, separatley]
% 
% 			one-way anova for effect of the 3 different exposure times
% 
% 
% 
% (2) 		
% 
% For amount of context. = [bbox OR full context, analyze separately]
% 
% 	For visual angle = [1 2 4, analyze separately] 
% 
% 		Merge all exposure times
% 
% 		ranksum test comparing backward mask on versus off
% 
% 
% 
% (3) For amount of context. = [bbox OR full context, analyze separately]
% 
% 	For visual angle = [1 2 4, analyze separately] 
% 
% 		two-way anova of backward mask and exposure time
% 
% 		Technically analysis (3) includes analysis (1) and (2). Can do (3) without doing (1) or (2). 

expname = 'expB';
modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

VisBin = [1:3];
visbinstr={'B1 [0.5 1]','B2 [1.75 2.25]','B3 [3.5 4.5]','B4 [7 9]'};

Amount=[1:2]; %BBOX VS FC
amountstr={'bbox','fc'};

Mask = [1:2]; %binary mask or not
maskstr={'WithMask','WOM'};

Time = [1:3]; %50, 100, 200 ms
timestr={'50ms', '100ms', '200ms'};


GP1 = [];
GP2 = [];
correct = [];

for a = Amount
    for v = VisBin
        
        %start 2-way anova
        for m=Mask
            counter = 0;

            for t = Time
                Dbar = subjStats{v,6*(a-1)+3*(m-1)+t};
                Dbar(isnan(Dbar)) = [];

                correct = [correct Dbar];
                counter = counter + length(Dbar);

                GP2 = [GP2 ones(1,length(Dbar))*t];
            end
            GP1 = [GP1 ones(1,counter)*m];
        end
        
        display([amountstr{a} ' vs ' visbinstr{v}]);
        p = anovan(correct,{GP1 GP2},'model',2,'varnames',{[amountstr{a} ' vs ' visbinstr{v} 'BinMask'],'ExpoTime'});
        
    end
end


%% model
expname = 'expB';
modelname = 'clicknetS';
load(['Mat/stats_' expname '_' modelname '.mat']);
modelStats = subjStats;

GP1 = [];
GP2 = [];
correct = [];

for a = Amount
    for v = VisBin
        
        %start 2-way anova
        for m=Mask
            counter = 0;

            for t = Time
                Dbar = subjStats{v,6*(a-1)+3*(m-1)+t};
                Dbar(isnan(Dbar)) = [];

                correct = [correct Dbar];
                counter = counter + length(Dbar);

                GP2 = [GP2 ones(1,length(Dbar))*t];
            end
            GP1 = [GP1 ones(1,counter)*m];
        end
        
        display([amountstr{a} ' vs ' visbinstr{v}]);
        p = anovan(correct,{GP1 GP2},'model',2,'varnames',{[amountstr{a} ' vs ' visbinstr{v} 'BinMask'],'ExpoTime'});
        
    end
end


%% model vs humans

modelname = 'mturk';
load(['Mat/stats_' expname '_' modelname '.mat']);

for a = Amount
    for v = VisBin
     
        for m=Mask
            
            for t = Time
                Dbar = subjStats{v,6*(a-1)+3*(m-1)+t};
                Dbar(isnan(Dbar)) = [];

                Mbar = modelStats{v,6*(a-1)+3*(m-1)+t};
                Mbar(isnan(Mbar)) = [];
                
                [p,h,stats] = ranksum(Dbar, Mbar,'tail','both');
                display([visbinstr{v} '; ' amountstr{a} '; ' maskstr{m} '; ' timestr{t} '; Human vs Model: p-val=' num2str(p) '; n1=' num2str(length(Dbar)) '; n2='  num2str(length(Mbar)) ]);
        
            end
            
        end
        
        
    end
end
























