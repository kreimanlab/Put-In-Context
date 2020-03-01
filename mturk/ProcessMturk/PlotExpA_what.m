clear all; close all; clc;

load(['/home/mengmi/Projects/Proj_context2/Matlab/results_expAwhat/result_expA_what_inlab.mat']);
inlabResult_mean = subjplot_mean;
inlabResult_std = subjplot_std;

load(['Mat/mturk_expA_what_compiled.mat']);
TotalNumImg = 10;
%NumTurker = length(find(extractfield(mturkData,'numhits')==TotalNumImg));
NumVisualBin = 4;
NumTypes = 8;
subjplot_mean = nan(NumVisualBin,NumTypes);
subjplot_std = nan(NumVisualBin,NumTypes);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

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
    %display(nanmean(correctL));
    binL = extractfield(ans,'bin');
    %nanmean(correctL)
    if nanmean(correctL)<0.5
        display(['bad: ' num2str(i) '; mean: ' num2str(nanmean(correctL))]);
        continue;
    end
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

for b = 1: NumVisualBin
    for type = 1:NumTypes
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));

    end

end


markerlist = {'b--','m--','g--','r--'};
xaxis = [0.01 0.5 2 4 8 16 128 200];
hb=figure;
hold on;
for b = 1:NumVisualBin
    M = subjplot_mean(b,:);
    S = subjplot_std(b,:);
    errorbar(xaxis, M, S, markerlist{b},'LineWidth',2);
end

markerlist = {'b','m','g','r'};
xaxis = [0.01 0.5 2 4 8 16 128 200];
for b = 1:NumVisualBin
    M = inlabResult_mean(b,:);
    S = inlabResult_std(b,:);  
    errorbar(xaxis, M, S, markerlist{b},'LineWidth',2);
end

legend({'Visual angle [0.5 1], mturk','Visual angle [1.75 2.25], mturk',...
    'Visual angle [3.5 4.5], mturk','Visual angle [7 9], mturk', ...
    'Visual angle [0.5 1], in-lab','Visual angle [1.75 2.25], in-lab',...
    'Visual angle [3.5 4.5], in-lab','Visual angle [7 9], in-lab'},'Location','Southeast','FontSize', 12);

xlabel('CO ratio','FontSize',22);
ylabel('recog accuracy','FontSize', 12);
xlim([-5 202]);
ylim([0 1.1]);

% bar plot for mturk
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
xlim([0 8.9]);
ylim([0 1.05]);
hold off
legend({'Visual angle [0.5 1], mturk','Visual angle [1.75 2.25], mturk',...
    'Visual angle [3.5 4.5], mturk','Visual angle [7 9], mturk'},...
    'Location','Southeast','FontSize', 8);

xlabel('CO ratio','FontSize',12);
set(gca,'XTickLabel',str2mat('0','contour','bbox','CO=2','CO=4','CO=8','CO=16','CO=128','full'));
ylabel('recog accuracy','FontSize', 12);
title('expA What (mturk)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expA_what_mturk' printpostfix],printmode,printoption);



%bar plot for in lab
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
xlim([0 8.9]);
ylim([0 1.05]);
hold off
legend({'Visual angle [0.5 1], InLab','Visual angle [1.75 2.25], InLab',...
    'Visual angle [3.5 4.5], InLab','Visual angle [7 9], InLab'},...
    'Location','Southeast','FontSize', 8);

xlabel('CO ratio','FontSize',12);
set(gca,'XTickLabel',str2mat('0','contour','bbox','CO=2','CO=4','CO=8','CO=16','CO=128','full'));
ylabel('recog accuracy','FontSize', 12);
title('expA What (in-lab)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expA_what_inLab' printpostfix],printmode,printoption);

%bar plot for in lab and mturk comparsion
hb = figure;
hold on;

A_mean=[subjplot_mean(1,:); inlabResult_mean(1,:); subjplot_mean(2,:); inlabResult_mean(2,:); subjplot_mean(3,:); inlabResult_mean(3,:); subjplot_mean(4,:); inlabResult_mean(4,:)];
A_std=[subjplot_std(1,:); inlabResult_std(1,:); subjplot_std(2,:); inlabResult_std(2,:); subjplot_std(3,:); inlabResult_std(3,:); subjplot_std(4,:); inlabResult_std(4,:)];
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
xlim([0 8.9]);
ylim([0 1.05]);
hold off
legend({'Visual angle [0.5 1], mturk','Visual angle [0.5 1], InLab','Visual angle [1.75 2.25], mturk',...
    'Visual angle [1.75 2.25], InLab','Visual angle [3.5 4.5], mturk',...
    'Visual angle [3.5 4.5], InLab','Visual angle [7 9], mturk','Visual angle [7 9], InLab'},...
    'Location','Southeast','FontSize', 8);

xlabel('CO ratio','FontSize',12);
set(gca,'XTickLabel',str2mat('0','contour','bbox','CO=2','CO=4','CO=8','CO=16','CO=128','full'));
ylabel('recog accuracy','FontSize', 12);
title('expA What (in-lab vs mturk)','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
%print(hb,['Figures/fig_expA_what_combined' printpostfix],printmode,printoption);



