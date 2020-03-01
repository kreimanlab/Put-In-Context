clear all; close all; clc;

load('ImageStatsHuman_val_50_filtered.mat');
%subjidlist = {'subject02-ct','subject03-ab','subject04-sg'};
%subjidlist = {'subject01-mz','subject02-ct','subject03-jc'};
subjidlist = {'subj02-ed','subj03-ji','subj04-hw','subj05-mi'};
markerlist = {'b','m','g','r'};
TotalTrialNum = 110;
NumType = 12;
NumBins = 4;
subjplot_mean = nan(NumBins,NumType);
subjplot_std = nan(NumBins,NumType);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

hb=figure;
hold on;
for s = 1:length(subjidlist)
    typelist = [];
    binlist = [];
    for t = 1:TotalTrialNum
        load(['audio_files_expB/' subjidlist{s} '/audio/trial_audio_' num2str(t) '.mat']);
        bin = myaudio.MM_selectedbin;
        cate = myaudio.MM_selectedcate;
        imgid = myaudio.MM_selectedobjid;
        type = myaudio.MM_selectedtype;
        typelist = [typelist type];
        binlist = [binlist bin];
    end
    
    %load correctness from human judgements
    %load(['results/result_' subjidlist{s} '.mat']);
    
    %load correctness from gt labels collected from mturk
    load(['results_expB/result_' subjidlist{s} '_mturk_cmp.mat']);
    totalcorrectL = [totalcorrectL result];
    totaltypeL = [totaltypeL typelist];
    totalbinL = [totalbinL binlist];
end

for b = 1: NumBins
    for type = 1:NumType
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));
    end
end
%end
save(['results_expB/result_expB_inlab.mat'],'subjplot_mean','subjplot_std');

% bar plot for mturk
xaxis = [1:NumType]; 
hb = figure;
hold on;
mturk_mean = subjplot_mean';
mturk_std = subjplot_std';

ngroups = size(mturk_mean, 1);
nbars = size(mturk_mean, 2);
bar(mturk_mean);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), '.');
end
errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2);
xlim([0 12.5]);
ylim([0 0.6]);
hold off

xlabel('Conditions (FC -> full context; WoM -> without mask; WM -> with mask; 50,100,200 in milli-secs)','FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',str2mat('Bbox_WoM_50','Bbox_WoM_100','Bbox_WoM_200',...
    'Bbox_WM_50','Bbox_WM_100','Bbox_WM_200',...
    'FC_WoM_50','FC_WoM_100','FC_WoM_200',...
    'FC_WM_50','FC_WM_100','FC_WM_200'));
ylabel('recog accuracy','FontSize', 12);
title('expB (in-lab)','FontSize', 12);












