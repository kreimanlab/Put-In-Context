clear all; close all; clc;

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);

%% read class labels from MSCOCO stuff
fid = fopen('/home/mengmi/Projects/Proj_context2/pytorch/deeplab/data/datasets/cocostuff/labels.txt');
CateTotal = 182;
mappingClass = nan(1,CateTotal); %valid: ind; invalid: 0
delimiter = '\t';
cocostuff = {};

tline = fgetl(fid);
C = strsplit(tline,delimiter);
cocostuff = [cocostuff C{2}];

while ischar(tline)
    tline = fgetl(fid);
    C = strsplit(tline,delimiter);
    cocostuff = [cocostuff C{2}];

    if length(cocostuff) == CateTotal
        break;
    end
end
fclose(fid);

%% Match nms vs cocostuff
for i = 1:length(cocostuff)
    
    flag = nan;
    for j = 1: length(nms)
        if strcmp(nms{j}, cocostuff{i})
            flag = j;
            break;
        end
    end
   
    mappingClass(i) = flag;
    
end
validclass = [1:CateTotal];
validclass(isnan(mappingClass)) = [];
save(['/home/mengmi/Projects/Proj_context2/mturk/ProcessMturk/Mat/Classlabel_deeplabel.mat'],'validclass','mappingClass');
