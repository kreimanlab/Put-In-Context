clear all; close all; clc;

load('Mat/mturk_expA_what.mat');

startingSubj = 31;
linewidth = 3;
hb=figure;
hold on;
Totaltimelist = [];
binranges = [0:0.5:15];

for s = startingSubj:length(mturkData)
    data = mturkData(s).answer;
    timelist = extractfield(data,'rt'); %convert to secs
    timelist = timelist/1000;
    bincounts = histc(timelist,binranges);
    plot(binranges, bincounts/sum(bincounts),'color',[0.75    0.75    0.75],'LineWidth',1.5);
    
    Totaltimelist = [Totaltimelist timelist];
end

bincounts = histc(Totaltimelist,binranges);
plot(binranges, bincounts/sum(bincounts),'k-','LineWidth',linewidth);
xlabel('Time (s)','FontSize', 11);
ylabel('Trial Duration Distribution','FontSize', 11);
title('Mturk','FontSize', 11)
xlim([0 15]);
ylim([0 0.6]);
