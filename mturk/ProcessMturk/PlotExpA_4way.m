clear all; close all; clc;

load(['Mat/mturk_expA_4way_compiled.mat']);
TotalNumImg = 100;
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
    
    typeL = extractfield(ans,'type');
    correctL = extractfield(ans,'correct');
    %display(nanmean(correctL));
    binL = extractfield(ans,'bin');
    
%     if nanmean(correctL)<0.6
%         continue;
%     end
    
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

hb=figure;
hold on;
markerlist = {'b','m','g','r'};
xaxis = [0.01 0.5 2 4 8 16 128 200];
for b = 1:NumVisualBin
    M = subjplot_mean(b,:);
    S = subjplot_std(b,:);  
    errorbar(xaxis, M, S, markerlist{b},'LineWidth',2);
end
errorbar(xaxis,ones(1,length(xaxis))*1/4,zeros(1,length(xaxis)),'k--','LineWidth',2);
legend({'Visual angle [0.5 1], mturk','Visual angle [1.75 2.25], mturk',...
    'Visual angle [3.5 4.5], mturk','Visual angle [7 9], mturk','chance'},...
    'Location','Southeast','FontSize', 12);

xlabel('CO ratio','FontSize',12);
ylabel('recog accuracy','FontSize', 12);
title('expA 4 way');
xlim([-5 202]);
ylim([0 1.1]);


hb = figure;
hold on;
subjplot_mean = subjplot_mean';
subjplot_std = subjplot_std';

ngroups = size(subjplot_mean, 1);
nbars = size(subjplot_mean, 2);
bar(subjplot_mean);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, subjplot_mean(:,i), subjplot_std(:,i), '.');
end
errorbar(xaxis,ones(1,length(xaxis))*1/4,zeros(1,length(xaxis)),'k--','LineWidth',2);
xlim([0 8.9]);
ylim([0 1.05]);
hold off
legend({'Visual angle [0.5 1], mturk','Visual angle [1.75 2.25], mturk',...
    'Visual angle [3.5 4.5], mturk','Visual angle [7 9], mturk'},...
    'Location','Southeast','FontSize', 12);

xlabel('CO ratio','FontSize',12);
set(gca,'XTickLabel',str2mat('0','contour','bbox','CO=2','CO=4','CO=8','CO=16','CO=128','full'));
ylabel('recog accuracy','FontSize', 12);
title('expA 4 way','FontSize', 12);

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expA_4way' printpostfix],printmode,printoption);

