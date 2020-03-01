clear all; close all; clc;

expnamelist = {'expA','expB','expC','expD','expE','expG','expH'};
R = {};

for e = 1:length(expnamelist)
    expname = expnamelist{e};
    
    if strcmp(expname, 'expA')
        load(['Mat/mturk_' expname '_what.mat']);
    else
        load(['Mat/mturk_' expname '.mat']);
    end
    
    for i = 1:length(mturkData)
        ans = mturkData(i).answer; 
        if length(ans)<1
            continue;
        end
        responseList = extractfield(ans,'response');  
        responseList = lower(responseList);
        R = [R responseList];
    end
end

R = lower(R);
R = strrep(R,' ','');
R = unique(R);

filePh = fopen('/home/mengmi/Projects/Proj_context2/pytorch/wordProcess/humanlabel.txt','w');
fprintf(filePh,'%s\n',R{:});
fclose(filePh);

HumanLabel = R;
save('Mat/humanlabel.mat','HumanLabel');

load('/home/mengmi/Projects/Proj_context2/Matlab/ImageStatsHuman_val_50_filtered.mat');
nms = extractfield(ImageStatsFiltered,'classname');
nms = unique(nms);
% filePh = fopen('/home/mengmi/Projects/Proj_context2/pytorch/wordProcess/gtlabel.txt','w');
% fprintf(filePh,'%s\n',nms{:});
% fclose(filePh);
