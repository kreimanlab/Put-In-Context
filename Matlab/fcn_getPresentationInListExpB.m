function [binL,cateL,imgL,typeL] = fcn_getPresentationInListExpB(AccumulateFiltered)

%clear all; close all; clc;

%load(['ImageStatsHuman_val_50_filtered.mat']);
[rowIdcs, colIdcs] = find(AccumulateFiltered(:,1)~=0);
CateChoiceList = rowIdcs;
binL = [];
cateL = [];
imgL = [];
typeL = [];

NumTypes= 12; 
NumBins = 3;

for i = 1:length(CateChoiceList)
    %2 objects per category
    
    for b = 1:NumBins
    
        %for each trial, bin is always 1
        binL = [binL b b];
        cateL = [cateL CateChoiceList(i) CateChoiceList(i)];
        objid = randperm(AccumulateFiltered(CateChoiceList(i),b),2);
        imgL = [imgL objid];
        typeL = [typeL randperm(NumTypes,1) randperm(NumTypes,1)];
    end
end

TotalTrials = 2*NumBins*length(CateChoiceList);
seq = randperm(TotalTrials);
binL = binL(seq);
cateL = cateL(seq);
imgL = imgL(seq);
typeL = typeL(seq);

%%for checking only
% for i = 1:TotalTrials
%     gifname = ['Stimulus/keyframe_expB_gif/gif_' num2str(binL(i)) '_' num2str(cateL(i))  '_' num2str(imgL(i)) '_' num2str(typeL(i)) '.gif' ];
%     
%     if exist(gifname, 'file') ~= 2 
%         error(['missing ' gifname]);
%         continue;
%     end
% end

end
