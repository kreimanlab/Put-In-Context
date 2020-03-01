clear all; close all; clc;

%generate 110 trials 10 times for 10 mturkers
%Run only ONCE 
NumSet = 2000; %330*12/10;
load('ImageStatsHuman_val_50_filtered.mat');

for s = 1:NumSet
    
    [binL,cateL,imgL,typeL] = fcn_getPresentationInListExpB(AccumulateFiltered);
    
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

    Mat = [binL; cateL; imgL; typeL];
    Mat = Mat(:);
    %Mat = Mat';
    keyframetype = ['expB_qr_classlabel/mturkSet_' num2str(s) '.txt'];
    fileID = fopen(keyframetype,'w');
    fprintf(fileID,'%d\n',Mat);
    
end


