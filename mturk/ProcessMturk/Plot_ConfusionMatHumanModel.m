clear all; close all; clc;

%expnamelist = {'expA','expB','expC','expD','expE','expG','expH'};
expnamelist = {'expA','expC','expD','expE','expH'};
%modelname = 'foveanet_feedforward' ; %'clicknet_noalphaloss';
modelname = 'foveanet' ; %'clicknet_noalphaloss';

Hvec_cate = [];
Hvec_obj = [];
Hvec_bin = [];
HGPtest = [];
HtrueClassLabel = [];
TotalCate = 55;

Mvec_cate = [];
Mvec_obj = [];
Mvec_bin = [];
MGPtest = [];
MtrueClassLabel = [];
TotalCate = 55;

for E = 1:length(expnamelist)
    expname = expnamelist{E};
   
    %% human processing
    if strcmp(expname,'expA')
        load(['Mat/mturk_' expname '_what_compiled.mat']);
    else
        load(['Mat/mturk_' expname '_compiled.mat']);
    end

    

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

            Hvec_cate = [Hvec_cate vec_cate];
            Hvec_obj = [Hvec_obj vec_obj];
            Hvec_bin = [Hvec_bin vec_bin];
            HtrueClassLabel = [HtrueClassLabel label];
            HGPtest = [HGPtest mturkData(j).answer(i).predLabel];
        end
    end

    %% model pre-processing

    load(['Mat/' modelname '_' expname '_confusion.mat']);
    

    for i = 1:length(mturkData.answer)
        vec_cate = mturkData.answer(i).cate;
        vec_obj = mturkData.answer(i).obj;
        vec_bin = mturkData.answer(i).bin;
        indimg = find(classList == vec_cate & objList == vec_obj & binList == vec_bin);
        classname = ImageStatsFiltered(indimg).classname;
        label = find(strcmp(nms,classname));

        Mvec_cate = [Mvec_cate vec_cate];
        Mvec_obj = [Mvec_obj vec_obj];
        Mvec_bin = [Mvec_bin vec_bin];
        MtrueClassLabel = [MtrueClassLabel label];
        MGPtest = [MGPtest mturkData.answer(i).predLabel];
    end

end

%% process confusion matrix
ConfusionMat = zeros(TotalCate, TotalCate);
for c= 1:length(ImageStatsFiltered)
    node = ImageStatsFiltered(c);
    
    HSelectedMat = HGPtest(find(Hvec_cate == node.classlabel & Hvec_obj == node.objIDinCate & Hvec_bin == node.bin));
    HSelectedMat = HSelectedMat(:);
    
    MSelectedMat = MGPtest(find(Mvec_cate == node.classlabel & Mvec_obj == node.objIDinCate & Mvec_bin == node.bin));
    MSelectedMat = MSelectedMat(:);
    
    for i = 1:length(HSelectedMat)
        
        if HSelectedMat(i) == 56
            continue;
        end
        
        for j = 1:length(MSelectedMat)
            ConfusionMat(HSelectedMat(i),MSelectedMat(j)) = ConfusionMat(HSelectedMat(i),MSelectedMat(j)) + 1;
        end
    end
end

for c = 1:TotalCate
    %normalize
    sumr = sum(ConfusionMat(c,:));
    ConfusionMat(c,:) = ConfusionMat(c,:)/sumr;
end

confmat = ConfusionMat; % sample data
% plotting
%plotConfMat(confmat, LabelList);

hb = figure;
numlabelsX = length(LabelList);
numlabelsY = length(LabelList);

LabelListX = [nms];

imagesc(confmat);
colormap(jet);
caxis([0 1]);
xlabel('Model','FontSize',16','FontWeight','Bold');
ylabel('Humans','FontSize',16','FontWeight','Bold');
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
print(hb,['/home/mengmi/Desktop/cvprFigs/Confusionmat_human_' modelname '_total.png'],printmode,printoption);