clear all; close all; clc;

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
NumImg = length(ImageStatsFiltered);
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');

load(['/home/mengmi/Projects/Proj_context2/Matlab/results_expB/result_expB_inlab_acrossImage.mat']);
inlabResult_mean = subjplot_mean;
inlabResult_std = subjplot_std;

load(['Mat/mturk_expB_compiled.mat']);
TotalNumImg = 10;
%NumTurker = length(find(extractfield(mturkData,'numhits')==TotalNumImg));
NumVisualBin = 1;
NumTypes = 12;
subjplot_meanT = nan(NumVisualBin,NumTypes,NumImg);
subjplot_stdT = nan(NumVisualBin,NumTypes,NumImg);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];
totalobjL = [];
totalcateL = [];

for i = 1:length(mturkData)
    ans = mturkData(i).answer;
    
    if length(ans) <TotalNumImg
        continue;
    end
    
    if ~isfield(ans,'correct')
        continue;
    end
    
    typeL = extractfield(ans,'type');
    correctL = extractfield(ans,'correct');
    objL = extractfield(ans,'obj');
    %display(nanmean(correctL));
    binL = extractfield(ans,'bin');
    cateL = extractfield(ans,'cate');
    
    %nanmean(correctL)
    if nanmean(correctL)<0
        display(['bad: ' num2str(i) '; mean: ' num2str(nanmean(correctL))]);
        continue;
    end
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
    totalobjL = [totalobjL objL];
    totalcateL = [totalcateL cateL];
end

for b = 1: NumVisualBin
    for type = 1:NumTypes
        for img = 1:NumImg
            a = totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL));
            if length(a)>0
                length(a)
            end
            subjplot_meanT(b,type,img) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL)));
            subjplot_stdT(b,type,img) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b & classList(img) == totalcateL & objList(img) == totalobjL & binList(img) == totalbinL))));
        end
    end

end

subjplot_mean = nan(NumVisualBin,NumTypes);
subjplot_std = nan(NumVisualBin,NumTypes);
for b = 1: NumVisualBin
    for type = 1:NumTypes
        
        D = squeeze(subjplot_meanT(b,type,:));
        length(find(~isnan(D)))
        subjplot_mean(b,type) = nanmean(D);
        subjplot_std(b,type) = nanstd(D)/sqrt(length(~isnan(D)));
        
        
    end

end

% bar plot for mturk
xaxis = [1:NumTypes]; 
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
title('expB (mturk)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expB_mturk' printpostfix],printmode,printoption);



%% bar plot for in lab
hb = figure;
hold on;
mturk_mean = inlabResult_mean';
mturk_std = inlabResult_std';

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
legend({''},...
    'Location','Southeast','FontSize', 8);

xlabel('Conditions (FC -> full context; WoM -> without mask; WM -> with mask; 50,100,200 in milli-secs)','FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',str2mat('Bbox_WoM_50','Bbox_WoM_100','Bbox_WoM_200',...
    'Bbox_WM_50','Bbox_WM_100','Bbox_WM_200',...
    'FC_WoM_50','FC_WoM_100','FC_WoM_200',...
    'FC_WM_50','FC_WM_100','FC_WM_200'));
ylabel('recog accuracy','FontSize', 12);
title('expB (in-lab)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expB_inLab' printpostfix],printmode,printoption);

%% bar plot for in lab and mturk comparsion
hb = figure;
hold on;

A_mean=[subjplot_mean(1,:); inlabResult_mean(1,:)];
A_std=[subjplot_std(1,:); inlabResult_std(1,:)];
mturk_mean = A_mean';
mturk_std = A_std';

ngroups = size(mturk_mean, 1);
nbars = size(mturk_mean, 2);
bar_h= bar(mturk_mean);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), '.');
end
errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2);
xlim([0 12.5]);
ylim([0 0.7]);
hold off
legend({'mturk','in-lab'},...
    'Location','Southeast','FontSize', 8);

xlabel('Conditions (FC -> full context; WoM -> without mask; WM -> with mask; 50,100,200 in milli-secs)','FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',str2mat('Bbox_WoM_50','Bbox_WoM_100','Bbox_WoM_200',...
    'Bbox_WM_50','Bbox_WM_100','Bbox_WM_200',...
    'FC_WoM_50','FC_WoM_100','FC_WoM_200',...
    'FC_WM_50','FC_WM_100','FC_WM_200'));
ylabel('recog accuracy','FontSize', 12);
title('expB (mturk vs in-lab)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
%print(hb,['Figures/fig_expA_what_combined' printpostfix],printmode,printoption);



