clear all; close all; clc;

subjidlist = {'subject04-ay','subject05-in','subject06-bg','subject08-ap','subject09-az'};
TotalTrialNum = 440;
linewidth = 3;
hb=figure;
hold on;
Totaltimelist = [];
binranges = [0:0.5:10];
for s = 1:length(subjidlist)
    timelist = [];
    for t = 1:(TotalTrialNum-1)
        load(['audio/' subjidlist{s} '/trial_audio_' num2str(t) '.mat']);
        starttime = myaudio.MM_stimulusOnSetTime;
        load(['audio/' subjidlist{s} '/trial_audio_' num2str(t+1) '.mat']);
        endtime = myaudio.MM_stimulusOnSetTime;
        
        timelist = [timelist endtime-starttime];
    end
    timelist = timelist; %convert to secs
    
    bincounts = histc(timelist,binranges);
    plot(binranges, bincounts/sum(bincounts),'color',[0.75    0.75    0.75],'LineWidth',1.5);
    
    Totaltimelist = [Totaltimelist timelist];
end
bincounts = histc(Totaltimelist,binranges);
plot(binranges, bincounts/sum(bincounts),'k-','LineWidth',linewidth);
xlabel('Time (s)','FontSize', 11);
ylabel('Trial Duration Distribution','FontSize', 11);
title('In-lab','FontSize', 11)
xlim([3 12]);
legend({'Subj1', 'Subj2', 'Subj3', 'Subj4', 'Subj5','All'},'Location','northeast','FontSize',10);

