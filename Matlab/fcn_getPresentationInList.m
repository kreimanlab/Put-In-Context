function [binL,cateL,imgL,typeL] = fcn_getPresentationInList(DatasetStats,CateChoiceList,AccumulateFiltered)
%FCN_GETPRESENTATIONINLIST Summary of this function goes here
%   Detailed explanation goes here
%load(['DatasetStats.mat']);
TotalTrials = length(CateChoiceList)*2*4;

display(['There are total ' num2str(TotalTrials) ' trials']);
binL = repmat([1:4],2,length(CateChoiceList));
binL = binL(:);
cateL = repmat(CateChoiceList,1,8)';
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
    choice = randperm(length(typeseq),1);
    typeL =[typeL typeseq(choice)];
    
    %randomly choose one type for second image
    typeseq = DatasetStats{binL(2*i),cateL(2*i),permseq(2)};
    choice = randperm(length(typeseq),1);
    typeL =[typeL typeseq(choice)];
    
end

trialseq = randperm(TotalTrials);
binL = binL(trialseq);
cateL = cateL(trialseq);
imgL = imgL(trialseq);
typeL = typeL(trialseq);

end
