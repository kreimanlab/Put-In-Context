clear all; close all; clc;

%generate 440 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 10;
load('DatasetStats.mat');
%total = [];

for s = 1:NumSet
    
    keyframetype = ['../mturk/Mturk/expA/static/data/mturk_set' num2str(s)];
    %rmdir([keyframetype ], 's');    
    mkdir([keyframetype]);

    [binL,cateL,imgL,typeL] = fcn_getPresentationInList(DatasetStats,CateChoiceList,AccumulateFiltered);
    vec = [];
    infor = [];
    
    for i = 1:length(binL)
       
        display(['set#' num2str(s) ' #' num2str(i) ': writing gif complete']);
        
        vec =[i binL(i) cateL(i) imgL(i) typeL(i)];
        infor = [infor; vec];
        
        source = ['Stimulus/keyframe_expA_gif/gif_' num2str(binL(i)) '_' num2str(cateL(i))  '_' num2str(imgL(i)) '_' num2str(typeL(i)) '.gif'];
        dest = [keyframetype '/trial_' num2str(i) '.gif'];
        %status = copyfile(source, dest);
        
        if status == 0
            error(['Failed to copy GIF file: ' source ' to ' dest]);
        end
            
    end
    %save([keyframetype '/infor.mat'],'infor');
    %total = [total infor];
end

       