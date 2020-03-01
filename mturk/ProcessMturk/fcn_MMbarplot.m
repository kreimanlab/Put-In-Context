function [] = fcn_MMbarplot(subjplot_mean, subjplot_std, barcolor,  XtickLabelName, FigPos, TextPos, TextStr, LegName, FigName, LegPos, edgecolor)
%FCN_MMBARPLOT Summary of this function goes here
%   Detailed explanation goes here

% bar plot for mturk
hb = figure('units','pixels');
hold on;
mturk_mean = subjplot_mean; %all elements in a row belong to the same group; size(A, 1) is the number of groups
mturk_std = subjplot_std;

ngroups = size(mturk_mean, 1);
nbars = size(mturk_mean, 2);
H = bar(mturk_mean);
for b = 1:nbars
    set(H(b),'FaceColor',barcolor(b,:));
    set(H(b),'EdgeColor',edgecolor(b,:));
    set(H(b),'LineWidth',2);
end

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, mturk_mean(:,i), mturk_std(:,i), 'k.');
end
%errorbar(xaxis,ones(1,length(xaxis))*1/80,zeros(1,length(xaxis)),'k--','LineWidth',2);
xlim([0.5 ngroups+0.5]);
ylim([0 1]);
hold off
%legend(LegName,'Location','Northwest','FontSize', 12);

legend(LegName,'Location','Northwest','Position',LegPos,'FontSize', 12);
text(gca,TextPos(1), TextPos(2),TextStr,'FontSize',14,'FontWeight','Bold');

%xlabel('Context Object Ratio','FontSize',12);
xticks([1:ngroups]);
set(gca,'YTick',[0:0.2:1]);
set(gca, 'TickDir', 'out')
%set(gca,'XTickLength',[0 0]);
%set(gca,'XTick',[]);
set(gca,'XTickLabel',char(XtickLabelName),'FontSize',15);
ylabel('Top-1 Accuracy','FontSize', 15);
%title('expA What (mturk)','FontSize', 12);
legend('boxoff'); 


ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

set(hb,'Position',FigPos);
% printpostfix = '.eps';
% printmode = '-depsc'; %-depsc
printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['/home/mengmi/Desktop/cvprFigs/' FigName printpostfix],printmode,printoption);


end

