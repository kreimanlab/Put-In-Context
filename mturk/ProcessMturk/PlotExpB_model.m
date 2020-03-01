clear all; close all; clc;

posx = 5.8; %horizontal; bigger, right
posy = 0.97; %vertical; smaller, down
textstring = 'Exp(B) Model';

expname = 'expB';
TypeSplitTime = [1 4 7 10; 2 5 8 11; 3 6 9 12]; %same timing per row
TypeSplitDuration = [50 100 200];
TypeSplitDurationLegend={'50ms', '100ms', '200ms'};


barcolor = [1     1     1;...
    0.8314    0.8157    0.7843;...
    0.5020    0.5020    0.5020;...
    0     0     0];


ColorLineList = [1     0     0;...
    0.2039    0.5804    0.7294;...
    0.7490    0.7490         0;...
    0.3922    0.4745    0.6353;...
    0.9255    0.4392    0.0863;...
    0.3490    0.2000    0.3294;...
    1.0000    0.6000    0.7843;...
    0.4667    0.6745    0.1882]; %red; blue;  

modelname = 'foveanet'; %'clicknet_noalphaloss_lstm','clicknet_noalphaloss_lstm','two-stream' 'clicknet' 'clickneta' 'four-channel',,'clicknet_noalphaloss'
load(['Mat/' modelname '_' expname '.mat']);

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
subjStats = cell(NumVisualBin,NumTypes);

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

for i = 1:length(mturkData)
    ans = mturkData(i).answer;
        
    typeL = extractfield(ans,'type');
    correctL = extractfield(ans,'correct');
    %display(nanmean(correctL));
    binL = extractfield(ans,'bin');
        
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

NUMTRIALS = 0;
for b = 1: NumVisualBin
    for type = 1:NumTypes
        a = length(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        NUMTRIALS = NUMTRIALS + a;
        subjStats{b,type} = totalcorrectL(find(totaltypeL == type & totalbinL==b));
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
H = bar(mturk_mean);
for b = 1:NumVisualBin
    set(H(b),'FaceColor',barcolor(b,:));
end
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), 'k.','HandleVisibility','off');
end
errorbar(xaxis,ones(1,length(xaxis))*1/55,zeros(1,length(xaxis)),'k--','LineWidth',2,'HandleVisibility','off');
xlim([0.5 12.5]);
ylim([0 1]);
hold off
%legend(legendstring,...
  %  'Location','Northwest','FontSize', 8);

%xlabel(xlabelstring,'FontSize',12);
set(gca,'XTick',(xaxis));
set(gca,'TickLength',[0 0]);
set(gca,'XTickLabel',xticklabelstring);
ylabel('Top-1 Accuracy','FontSize', 12);
%title( [expname ' (mturk overall); number of trials on average: ' num2str(NUMTRIALS)],'FontSize', 12);
text(posx, posy,textstring,'FontSize',14,'FontWeight','Bold');

set(hb,'Position',[136         499        1699         256]);
printpostfix = '.eps';
printmode = '-depsc'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_' expname '_' modelname  printpostfix],printmode,printoption);

save(['Mat/stats_' expname '_' modelname '.mat'],'subjplot_mean','subjplot_std','subjStats');

