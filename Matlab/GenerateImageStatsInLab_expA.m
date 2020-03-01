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
            imglist = dir(['Stimulus/keyframe_expA/trial_' num2str(b) '_' num2str(c) '_' num2str(i) '_screen2_imgtype_*.jpg']);
            if length(imglist) == 8
                typechoice = [1:8];
            elseif length(imglist) == 7
                typechoice = [1:6 8];
            elseif length(imglist) == 6
                typechoice = [1:5 8];
            elseif length(imglist) == 5
                typechoice = [1:4 8];
            elseif length(imglist) == 4
                typechoice = [1:3 8];
            else
                typechoice = [1:2 8];
            end
            DatasetStats{b,c,i} = typechoice;
        end
    end
end
[rowIdcs, colIdcs] = find(AccumulateFiltered(:,1)~=0);
CateChoiceList = rowIdcs;
save(['DatasetStats.mat'],'DatasetStats','CateChoiceList','AccumulateFiltered');
display(['saved datasetstats.mat']);

[binL,cateL,imgL,typeL] = fcn_getPresentationInList(DatasetStats, CateChoiceList,AccumulateFiltered);

