clear all; close all; clc;


posx = 3.8; %horizontal; bigger, right
posy = 0.97; %vertical; smaller, down
textstring = 'Exp(A) Model';

modellist = {'clicknetA','two-stream', 'clicknet', 'four-channel', 'vggcrimg', 'deeplab', 'yolo3','clicknetS','clicknet_noalphaloss','clicknet_noalphaloss_lstm','foveanet_feedforward','foveanet','foveanetConvLSTM'};
modelselect = 13;
modelname =modellist{modelselect}; %'two-stream' 'clicknet' 'four-channel' 'vggcrimg' 'deeplab'
load(['Mat/' modelname '_expA.mat']);
NumVisualBin = 4;
NumTypes = 8;
subjplot_mean = nan(NumVisualBin,NumTypes);
subjplot_std = nan(NumVisualBin,NumTypes);
subjStats = cell(NumVisualBin,NumTypes);

barcolor = [1     1     1;...
    0.8314    0.8157    0.7843;...
    0.5020    0.5020    0.5020;...
    0     0     0];

totaltypeL = [];
totalcorrectL = [];
totalbinL = [];

for i = 1:length(mturkData)
    ans = mturkData(i).answer;    
    
    typeL = extractfield(ans,'type');
    correctL = extractfield(ans,'correct');    
    binL = extractfield(ans,'bin');    
    
    totaltypeL = [totaltypeL typeL];
    totalcorrectL = [totalcorrectL correctL];
    totalbinL = [totalbinL binL];    
end

for b = 1: NumVisualBin
    for type = 1:NumTypes
        subjStats{b,type} = totalcorrectL(find(totaltypeL == type & totalbinL==b));
        subjplot_mean(b,type) = nanmean(totalcorrectL(find(totaltypeL == type & totalbinL==b)));
        subjplot_std(b,type) = nanstd(totalcorrectL(find(totaltypeL == type & totalbinL==b)))/sqrt(length(totalcorrectL(find(totaltypeL == type & totalbinL==b))));

    end

end

% bar plot for model
hb = figure;
hold on;
mturk_mean = subjplot_mean';
mturk_std = subjplot_std';

ngroups = size(mturk_mean, 1);
nbars = size(mturk_mean, 2);
H = bar(mturk_mean);
for b = 1:NumVisualBin
    set(H(b),'FaceColor',barcolor(b,:));
end% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), 'k.');
end
xaxis = [1:NumTypes]; 
errorbar(xaxis,ones(1,length(xaxis))*1/55,zeros(1,length(xaxis)),'k--','LineWidth',2,'HandleVisibility','off');

xlim([0.5 8.5]);
ylim([0 1]);
hold off
%legend({'Visual angle [0.5 1], model','Visual angle [1.75 2.25], model',...
   % 'Visual angle [3.5 4.5], model','Visual angle [7 9], model'},...
   % 'Location','Northwest','FontSize', 8);

%xlabel('CO ratio','FontSize',12);
set(gca,'TickLength',[0 0]);
set(gca,'XTickLabel',str2mat('0','Contour','Bbox','CO=2','CO=4','CO=8','CO=16','CO=128','FullContext'));
ylabel('Top-1 Accuracy','FontSize', 12);
%title('expA What (model)','FontSize', 12);
text(posx, posy,textstring,'FontSize',14,'FontWeight','Bold');

set(hb,'Position',[1361         669        1378         420]);
printpostfix = '.eps';
printmode = '-depsc'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['Figures/fig_expA_' modelname printpostfix],printmode,printoption);

save(['Mat/stats_expA_' modelname '.mat'],'subjplot_mean','subjplot_std','subjStats');



