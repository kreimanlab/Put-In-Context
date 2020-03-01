clear all; close all; clc;

load(['ImageStatsHuman_val_50_filtered.mat']);
NumBin = 4;
NumCate = 71;
NumImg = max(max(AccumulateFiltered));

DatasetStats = cell(NumBin,NumCate,NumImg);

for b = 1:NumBin
    for c = 1:NumCate
        NumImgCount = AccumulateFiltered(c,b);
        for i = 1:NumImgCount
            imglist = dir(['Stimulus/keyframe_expE/trial_' num2str(b) '_' num2str(c) '_' num2str(i) '_screen2_imgtype_*.jpg']);
            typechoice = [];
%             
%             if length(imglist) == 0
%                 error('me');
%             end
            
            for fi = 1:length(imglist)                
                typechoice = [typechoice str2num(imglist(fi).name(end-4))];
            end
            DatasetStats{b,c,i} = typechoice;
        end
    end
end
[rowIdcs, colIdcs] = find(AccumulateFiltered(:,1)~=0);
CateChoiceList = rowIdcs;
save(['DatasetStats_expE.mat'],'DatasetStats','CateChoiceList','AccumulateFiltered');
display(['saved datasetstats.mat']);

[binL,cateL,imgL,typeL] = fcn_getPresentationInListExpE(DatasetStats, CateChoiceList,AccumulateFiltered);
Mat = [binL cateL imgL typeL];
