function [] = fcn_MMcombinedplot(targetmodel, cmpmodel, printpostfix, numrow, numcol, FigName)
%FCN_COMBINEDPLOT Summary of this function goes here
%   Detailed explanation goes here

%hb = figure;

%for i = 1: numrow*numcol
    hb = figure;
    Cimg = imread(['/home/mengmi/Desktop/cvprFigs/' cmpmodel printpostfix]);
    Timg = imread(['/home/mengmi/Desktop/cvprFigs/' targetmodel printpostfix]);
    
    ha = tight_subplot(numrow,numcol,[.01 .01],[.01 .01],[.01 .01])
    axes(ha(1)); imshow(Cimg);
    axes(ha(2)); imshow(Timg);
    
%     ax = gca;
%     outerpos = ax.OuterPosition;
%     ti = ax.TightInset; 
%     left = outerpos(1) + ti(1);
%     bottom = outerpos(2) + ti(2);
%     ax_width = outerpos(3) - ti(1) - ti(3);
%     ax_height = outerpos(4) - ti(2) - ti(4);
%     ax.Position = [left bottom ax_width ax_height];
    
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%     
%     subplot(numrow, numcol, 1);
%     imshow(Cimg);
%     subplot(numrow, numcol, 2);
%     imshow(Timg);
%end

    printpostfix = '.png';
    printmode = '-dpng'; %-depsc
    printoption = '-r200'; %'-fillpage'
    set(hb,'Units','Inches');
    pos = get(hb,'Position');
    set(hb,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    print(hb,['/home/mengmi/Desktop/cvprFigs/' FigName printpostfix],printmode,printoption);

