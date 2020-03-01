clear all; close all; clc;

%generate 110 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 600; %330*4/10;
load(['DatasetStats_expE.mat']);
mkdir('expE_qr_classlabel');

for s = 1:NumSet
    
    [binL,cateL,imgL,typeL] = fcn_getPresentationInListExpE(DatasetStats, CateChoiceList,AccumulateFiltered);
    
%     keyframetype = ['expB_classlabel/cateL_' num2str(s) '.txt'];    
%     fileID = fopen(keyframetype,'w');
%     fprintf(fileID,'%d\n',cateL);
%     
%     keyframetype = ['expB_classlabel/imgL_' num2str(s) '.txt'];    
%     fileID = fopen(keyframetype,'w');
%     fprintf(fileID,'%d\n',imgL);
%     
%     keyframetype = ['expB_classlabel/typeL_' num2str(s) '.txt'];    
%     fileID = fopen(keyframetype,'w');
%     fprintf(fileID,'%d\n',typeL);    

%     fclose(fileID);

    Mat = [binL cateL imgL typeL]';
    Mat = Mat(:);
    %Mat = Mat';
    keyframetype = ['expE_qr_classlabel/mturkSet_' num2str(s) '.txt'];
    fileID = fopen(keyframetype,'w');
    fprintf(fileID,'%d\n',Mat);
    
end


