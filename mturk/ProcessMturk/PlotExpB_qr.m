clear all; close all; clc;

expname = 'expB';
TypeSplitTime = [1 4 7 10; 2 5 8 11; 3 6 9 12]; %same timing per row
TypeSplitDuration = [50 100 200];
TypeSplitDurationLegend={'50ms', '100ms', '200ms'};

ColorLineList = [1     0     0;...
    0.2039    0.5804    0.7294;...
    0.7490    0.7490         0;...
    0.3922    0.4745    0.6353;...
    0.9255    0.4392    0.0863;...
    0.3490    0.2000    0.3294;...
    1.0000    0.6000    0.7843;...
    0.4667    0.6745    0.1882]; %red; blue;  

load(['Mat/mturk_' expname '_qr_compiled.mat']);
TotalNumImg = 10;
%NumTurker = length(find(extractfield(mturkData,'numhits')==TotalNumImg));
NumVisualBin = 3;
NumTypes = 12;

xlabelstring = 'Conditions (FC -> full context; WoM -> without mask; WM -> with mask; 50,100,200 in milli-secs)';
legendstring = {'Visual angle [0.5 1]','Visual angle [1.75 2.25]','Visual angle [3.5 4.5]','Visual angle [7 9]'};
xticklabelstring =str2mat('Bbox_WoM_50','Bbox_WoM_100','Bbox_WoM_200',...
    'Bbox_WM_50','Bbox_WM_100','Bbox_WM_200',...
    'FC_WoM_50','FC_WoM_100','FC_WoM_200',...
    'FC_WM_50','FC_WM_100','FC_WM_200');

%% overall performances
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
    if nanmean(correctL)<0
        display(['bad: ' num2str(i) '; mean: ' num2str(nanmean(correctL))]);
        continue;
    end
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

NUMTRIALS = 0;
for b = 1: NumVisualBin
    for type = 1:NumTypes
        a = length(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        NUMTRIALS = NUMTRIALS + a;
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));

    end

end
NUMTRIALS = ceil(NUMTRIALS/(NumVisualBin*NumTypes));

xaxis = [1:NumTypes]; 
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
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), '.','HandleVisibility','off');
end
errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2,'HandleVisibility','off');
xlim([0 12.5]);
ylim([0 0.6]);
hold off
legend(legendstring,...
    'Location','Northeast','FontSize', 8);

xlabel(xlabelstring,'FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',xticklabelstring);
ylabel('recog accuracy','FontSize', 12);
title( [expname ' (mturk overall); number of trials on average: ' num2str(NUMTRIALS)],'FontSize', 12);

set(hb,'Position',[303         737        1600         352]);
printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_' expname '_mturk_overall' printpostfix],printmode,printoption);


%% overall performances (without video records)
subjplot_mean = nan(NumVisualBin,NumTypes);
subjplot_std = nan(NumVisualBin,NumTypes);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

for i = 1:length(mturkData)
    ans = mturkData(i).answer;
    
    if length(ans) <TotalNumImg  || mturkData(i).videorecord == 1
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
    if nanmean(correctL)<0
        display(['bad: ' num2str(i) '; mean: ' num2str(nanmean(correctL))]);
        continue;
    end
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

NUMTRIALS = 0;
for b = 1: NumVisualBin
    for type = 1:NumTypes
        a = length(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        NUMTRIALS = NUMTRIALS + a;
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));

    end

end
NUMTRIALS = ceil(NUMTRIALS/(NumVisualBin*NumTypes));

xaxis = [1:NumTypes]; 
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
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), '.','HandleVisibility','off');
end
errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2,'HandleVisibility','off');
xlim([0 12.5]);
ylim([0 0.6]);
hold off
legend(legendstring,...
    'Location','Northeast','FontSize', 8);

xlabel(xlabelstring,'FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',xticklabelstring);
ylabel('recog accuracy','FontSize', 12);
title( [expname ' (mturk without video records); number of trials on average: ' num2str(NUMTRIALS)],'FontSize', 12);

set(hb,'Position',[303         737        1600         352]);
printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_' expname '_mturk_wovideo' printpostfix],printmode,printoption);

%% with videos performances
subjplot_mean = nan(NumVisualBin,NumTypes);
subjplot_std = nan(NumVisualBin,NumTypes);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

for i = 1:length(mturkData)
    ans = mturkData(i).answer;
    
    if length(ans) <TotalNumImg || mturkData(i).videorecord == 0
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
    if nanmean(correctL)<0
        display(['bad: ' num2str(i) '; mean: ' num2str(nanmean(correctL))]);
        continue;
    end
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

NUMTRIALS = 0;
for b = 1: NumVisualBin
    for type = 1:NumTypes
        a = length(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        NUMTRIALS = NUMTRIALS + a;
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));

    end

end
NUMTRIALS = ceil(NUMTRIALS/(NumVisualBin*NumTypes));

xaxis = [1:NumTypes]; 
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
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), '.','HandleVisibility','off');
end
errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2,'HandleVisibility','off');
xlim([0 12.5]);
ylim([0 0.6]);
hold off
legend(legendstring,...
    'Location','Northeast','FontSize', 8);

xlabel(xlabelstring,'FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'XTickLabel',xticklabelstring);
ylabel('recog accuracy','FontSize', 12);
title( [expname ' (mturk with video records); number of trials on average: ' num2str(NUMTRIALS)],'FontSize', 12);

set(hb,'Position',[303         737        1600         352]);
printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_' expname '_mturk_withvideo' printpostfix],printmode,printoption);

%% Timing Distribution
load(['../../Matlab/results_mturk_timing_mat/' expname '_timing.mat']);
trialtyperec = [];
timerec = [];

for T= 1:length(mturkTime)
    
    trialtyperec = [trialtyperec mturkTime(T).trialtyperec];
    timerec = [timerec mturkTime(T).timediff];
end
    
hb = figure;

for i = 1:length(TypeSplitDuration)
    tlistL = [];
    for j = 1:length(TypeSplitTime(i,:))
        tlistL = [tlistL timerec(find(trialtyperec == TypeSplitTime(i,j)))];
    
    end
    
    SupposedTime = TypeSplitDuration(i);
        
    binranges = [20:10:300];
    bincounts = histc(tlistL,binranges);
    linewidth = 3;
    plot(binranges, bincounts/sum(bincounts),'Color',ColorLineList(i,:),'LineStyle','-','LineWidth',linewidth);

    hold on;
    plot(ones(1,11)*SupposedTime, [0:0.1:1],'Color',ColorLineList(i,:),'LineStyle','--','HandleVisibility','off');
    
end
xlabel('Stimulus Presentation Time (ms)','FontSize', 11);
ylabel('Distribution','FontSize', 11);
title(['Timing ' expname '; Trial number on average: ' num2str(ceil(length(trialtyperec)/length(TypeSplitDuration)))],'FontSize', 11)
xlim([20 300]);
legend(TypeSplitDurationLegend,'Location','northeast','FontSize',10);
set(hb,'Position',[675   601   653   488]);
printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_' expname '_mturk_timing' printpostfix],printmode,printoption);


