function [binL,cateL,imgL,typeL] = fcn_getPresentationInListExpE(DatasetStats,CateChoiceList,AccumulateFiltered)
%FCN_GETPRESENTATIONINLIST Summary of this function goes here
%   Detailed explanation goes here
%load(['DatasetStats.mat']);

NumVisualBins = 3;
TotalTrials = length(CateChoiceList)*2*NumVisualBins;

display(['There are total ' num2str(TotalTrials) ' trials']);
binL = repmat([1:NumVisualBins],2,length(CateChoiceList));
binL = binL(:);
cateL = repmat(CateChoiceList,1,2*NumVisualBins)';
cateL = cateL(:);
imgL = [];
typeL = [];


for i = 1:length(binL)/2
    
    %randomly choose two images
    permseq = AccumulateFiltered( cateL(2*i), binL(2*i)); 
    permseq = randperm(permseq,2);          
    imgL = [imgL permseq];
    
    %randomly choose one type for first image
    typeseq = DatasetStats{binL(2*i),cateL(2*i),permseq(1)};
    typeseq = [typeseq 5 6]; %full context condition
    if length(typeseq) > 3       
        
        if randperm(10,1) <= 6 %60% chance of choose jigsaw
            choice = randperm(length(typeseq)-3,1);
        else
            choice = 3+randperm(length(typeseq)-3,1); %40% chance of choosing among portilla or full context or bbox
        end
    else
        choice = randperm(length(typeseq),1);
    end
    typeL =[typeL typeseq(choice)];
    
    %randomly choose one type for second image
    typeseq = DatasetStats{binL(2*i),cateL(2*i),permseq(2)};
    typeseq = [typeseq 5 6]; %full context condition
    if length(typeseq) > 3       
        
        if randperm(10,1) <= 6 %60% chance of choose jigsaw
            choice = randperm(length(typeseq)-3,1);
        else
            choice = 3+randperm(length(typeseq)-3,1); %40% chance of choosing among portilla or full context or bbox
        end
    else
        choice = randperm(length(typeseq),1);
    end
    typeL =[typeL typeseq(choice)];
    
end

trialseq = randperm(TotalTrials);
binL = binL(trialseq);
cateL = cateL(trialseq);
imgL = imgL(trialseq);
typeL = typeL(trialseq);

binL = reshape(binL, [TotalTrials 1]);
cateL = reshape(cateL, [TotalTrials 1]);
imgL = reshape(imgL, [TotalTrials 1]);
typeL = reshape(typeL, [TotalTrials 1]);

end
