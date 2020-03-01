clear all; close all; clc;

%generate 440 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 10;

for s = 1:NumSet
    
    keyframetype = ['expA_what_classlabel/classlabel_' num2str(s) '.txt'];       
    
    %vec =[i binL(i) cateL(i) imgL(i) typeL(i)];
    %infor = [infor; vec];
    
    keyframetypeRead = ['../mturk/Mturk/StimulusBackUp/expA_what/mturk_set' num2str(s)];
    load([keyframetypeRead '/infor.mat'],'infor');
    
    fileID = fopen(keyframetype,'w');
    fprintf(fileID,'%d\n',infor(:,3));

    fclose(fileID);
end

load('ImageStatsHuman_val_50_filtered_classinfor.mat');

CN = cell(1,max(classnameIndex)+1);
CN(classnameIndex) = classnameList;

fileID = fopen('classnameList.txt','w');
fprintf(fileID,'"%s",',CN{:});
fclose(fileID);

%classnameIndex = sort(classnameIndex);
fileID = fopen('classlabelIndexList.txt','w');
fprintf(fileID,'%d,',classnameIndex);
fclose(fileID);
