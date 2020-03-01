clear all; close all; clc;

load('ImageStatsHuman_val_50_filtered.mat');

NumImg = length(ImageStatsFiltered);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

%subjidlist = {'subject02-ct','subject03-ab','subject04-sg'};
%subjidlist = {'subject01-mz','subject02-ct','subject03-jc'};
subjidlist = {'subject04-ay','subject05-in','subject06-bg','subject08-ap','subject09-az'};
markerlist = {'b','m','g','r'};
TotalTrialNum = 440;
NumType = 8;
NumBins = 4;
subjplot_meanT = nan(NumBins,NumType,NumImg);
subjplot_stdT = nan(NumBins,NumType,NumImg);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];
totalobjL = [];
totalcateL = [];

hb=figure;
hold on;
for s = 1:length(subjidlist)
    typelist = [];
    binlist = [];
    objlist = [];
    catelist = [];
    
    for t = 1:TotalTrialNum
        load(['audio/' subjidlist{s} '/trial_audio_' num2str(t) '.mat']);
        bin = myaudio.MM_selectedbin;
        cate = myaudio.MM_selectedcate;
        imgid = myaudio.MM_selectedobjid;
        type = myaudio.MM_selectedtype;
        typelist = [typelist type];
        binlist = [binlist bin];
        objlist = [objlist imgid];
        catelist = [catelist cate];
        
    end
    
    %load correctness from human judgements
    %load(['results/result_' subjidlist{s} '.mat']);
    
    %load correctness from gt labels collected from mturk
    load(['results/result_' subjidlist{s} '_mturk_cmp.mat']);
    totalcorrectL = [totalcorrectL result];
    totaltypeL = [totaltypeL typelist];
    totalbinL = [totalbinL binlist];
    totalobjL = [totalobjL objlist];
    totalcateL = [totalcateL catelist];
end

for b = 1: NumBins
    for type = 1:NumType
        for img = 1:NumImg
           
            subjplot_meanT(b,type,img) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL)));
            subjplot_stdT(b,type,img) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL))));
        end
    end

end

subjplot_mean = nan(NumBins,NumType);
subjplot_std = nan(NumBins,NumType);
for b = 1: NumBins
    for type = 1:NumType
        
        D = squeeze(subjplot_meanT(b,type,:));
        subjplot_mean(b,type) = nanmean(D);
        subjplot_std(b,type) = nanstd(D)/sqrt(length(~isnan(D)));
        
        
    end

end


for b = 1: NumBins
    for type = 1:NumType
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));
    end
end
%end
save(['results/result_expA_what_inlab_acrossImage.mat'],'subjplot_mean','subjplot_std');

%xaxis = [0 1 3 25 81 289 900];
xaxis = [0.01 0.5 2 4 8 16 128 200];
%xaxis = log(xaxis);
for b = 1:NumBins
    M = subjplot_mean(b,:);   
    S = subjplot_std(b,:);
    errorbar(xaxis, M,S,markerlist{b},'LineWidth',2);
end

legend('Visual angle [0.5 1]','Visual angle [1.75 2.25]','Visual angle [3.5 4.5]','Visual angle [7 9]','Location','Southeast');
xlabel('Ratio (Width of outer bounding box vs width of Object');
ylabel('recog accuracy');
%xlim([-5 5.5]); %for log xaxis
xlim([-1 201]);
ylim([0 1.1]);








