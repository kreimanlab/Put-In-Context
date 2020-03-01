clear all; close all; clc;

expnamelist = {'expA','expB','expC','expD','expE','expG','expH'};
expname = expnamelist{2};

if strcmp(expname,'expA')
    load(['Mat/mturk_' expname '_what_compiled.mat']);
else
    load(['Mat/mturk_' expname '_compiled.mat']);
end

GPtest = [];
trueClassLabel = [];
TotalCate = 55;

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
classList = extractfield(ImageStatsFiltered,'classlabel');
objList = extractfield(ImageStatsFiltered,'objIDinCate');
binList = extractfield(ImageStatsFiltered,'bin');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);
LabelList = nms;
    
for j = 1:length(mturkData)
    
    ans = mturkData(j).answer;
        
    if ~isfield(ans,'predLabel')
        continue;
    end
    
    for i = 1:length(mturkData(j).answer)
        vec_cate = mturkData(j).answer(i).cate;
        vec_obj = mturkData(j).answer(i).obj;
        vec_bin = mturkData(j).answer(i).bin;
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
        classname = ImageStatsFiltered(indimg).classname;
        label = find(strcmp(nms,classname));

        trueClassLabel = [trueClassLabel label];
        GPtest = [GPtest mturkData(j).answer(i).predLabel];
    end
end

% process confusion matrix
ConfusionMat = zeros(TotalCate, TotalCate+1);
for c= 1:TotalCate
    SelectedMat = GPtest(find(trueClassLabel==c));
    SelectedMat = SelectedMat(:);
    
    for i = 1:length(SelectedMat)
        ConfusionMat(c,SelectedMat(i)) = ConfusionMat(c,SelectedMat(i)) + 1;
    end
    
    %normalize
    sumr = sum(ConfusionMat(c,:));
    ConfusionMat(c,:) = ConfusionMat(c,:)/sumr;
end

confmat = ConfusionMat; % sample data
% plotting
%plotConfMat(confmat, LabelList);

hb = figure;
numlabelsX = length(LabelList)+1;
numlabelsY = length(LabelList);

LabelListX = [nms 'Other'];

imagesc(confmat);
colormap(jet);
caxis([0 1]);
xlabel('Predicted Labels','FontSize',16','FontWeight','Bold');
ylabel('Actual Labels','FontSize',16','FontWeight','Bold');
hc=colorbar();
set(hc,'YTick',[0:0.2:1]);

set(gca,'XTick',1:numlabelsX,...
    'XTickLabel',LabelListX,...
    'YTick',1:numlabelsY,...
    'YTickLabel',LabelList);

%xticklabel_rotate;
set(gca,'XTickLabelRotation',45)

printpostfix = '.png';
printmode = '-dpng'; %-depsc
printoption = '-r200'; %'-fillpage'

set(hb,'Position',[1361           7        1246        1082]);
set(hb,'Units','Inches');
pos = get(hb,'Position');
set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
print(hb,['/home/mengmi/Desktop/cvprFigs/Confusionmat_human_' expname '.png'],printmode,printoption);

% % read png image and print again
% I = imread(['/home/mengmi/Desktop/cvprFigs/ICLRconfusionmat_model.png']);
% imshow(I);
% 
% printpostfix = '.pdf';
% printmode = '-dpdf'; %-depsc
% printoption = '-r200'; %'-fillpage'
% 
% set(hb,'Position',[1361           7        1246        1082]);
% set(hb,'Units','Inches');
% pos = get(hb,'Position');
% set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
% print(hb,['/home/mengmi/Desktop/cvprFigs/ICLRconfusionmat_model' printpostfix],printmode,printoption);

