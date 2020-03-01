clear all; close all; clc;
%targetmodel = 'clicknet_noalphaloss';
targetmodel = 'mturk';
modellist = {'foveanet'}; %'foveanet_feedforward','clicknetA','two-stream', 'clicknet', 'four-channel', 'vggcrimg', 'deeplab', 'yolo3'};
printpostfix = '.png';

for c = 1: length(modellist)
    cmpmodel = modellist{c};
    
    %% exp A1: fc vs bbox
    %modelname = cmpmodel;
    TFigName = ['expA1_' targetmodel];
    CFigName = ['expA1_' cmpmodel];
    numrow = 1; numcol = 2;
    Figname = ['cmp_expA1_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
        
    %% exp A2: object size
    TFigName = ['expA2_' targetmodel];
    CFigName = ['expA2_' cmpmodel];
    numrow = 2; numcol = 1;
    Figname = ['cmp_expA2_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
    %% exp B1: context resolution 
    TFigName = ['expB1_' targetmodel];
    CFigName = ['expB1_' cmpmodel];
    numrow = 2; numcol = 1;
    Figname = ['cmp_expB1_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
    %% exp B2: object resolution 
    TFigName = ['expB2_' targetmodel];
    CFigName = ['expB2_' cmpmodel];
    numrow = 2; numcol = 1;
    Figname = ['cmp_expB2_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
    %% exp B3: texture only
    TFigName = ['expB3_' targetmodel];
    CFigName = ['expB3_' cmpmodel];
    numrow = 1; numcol = 2;
    Figname = ['cmp_expB3_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
    %% exp B4: jigsaw
    TFigName = ['expB4_' targetmodel];
    CFigName = ['expB4_' cmpmodel];
    numrow = 1; numcol = 2;
    Figname = ['cmp_expB4_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
    %% exp B5: congruent
    TFigName = ['expB5_' targetmodel];
    CFigName = ['expB5_' cmpmodel];
    numrow = 1; numcol = 2;
    Figname = ['cmp_expB5_' targetmodel '_' cmpmodel];
    fcn_MMcombinedplot(TFigName, CFigName, printpostfix, numrow, numcol,Figname);
    
end
