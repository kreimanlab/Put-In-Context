function doitColor(debugging,scale,aspect,imFile,append,origin,seedFile)

randn('state',sum(100*clock));

stimPath = '/e/2.2/p1/freeman/Documents/EeroLab/textures/stimuli/';
oim = double(((imread(fullfile(stimPath,imFile)))));

% for 256, scale of 2, aspect of 0.25, overlap of 0.01, and rad deg of 0.5
% gives me a good "full circle" mask

if exist('seedFile','var')
    if strcmp(seedFile,'blend')
        mask = zeros(size(oim,1));
        mask(:,1:round(size(oim,1)/2)) = 1;
        for iClr = 1:3
            noise(:,:,iClr)  = mean(vector(oim(:,:,iClr))) + sqrt(var(vector(oim(:,:,iClr))))*randn(size(oim(:,:,iClr)));
        end
        im0 = pyrBlend(oim,noise,mask,4);

    else
        fprintf('using seed image %s\n',seedFile);
        im0 = double(((imread(fullfile(seedPath,seedFile)))));
        %imBlur = blurDn(oim,4);
        %im0 = circshift(imresize(imBlur,size(oim)),[-6 -6]);
        %im0 = im0 + randn(size(oim))*std(oim(:));
    end
end


params.analysis.szx = size(oim,1);
params.analysis.szy = size(oim, 2);
params.analysis.Nsc = 4;
params.analysis.Nor = 4;
params.analysis.maxNa = 7;


params.analysis.scale = scale;
params.analysis.aspect = aspect;
params.analysis.overlap = 0.5;
params.analysis.centerRadDeg = 0.25;
params.analysis.centerRadPerc = 0.025;
params.origin = origin;
% params.origin = [];

params.analysis.nSquares = [1 1];

params.analysis.VD = 30;
params.analysis.pixPerCm = 33.6;
params.analysis.screenSzCm = 30;
params.analysis.plotting = debugging;
params.analysis.printing = 1;

if params.analysis.plotting
  imagesc(uint8(oim)); axis image off; drawnow;
end

params.analysis,

params.outputpath = strcat('/share/erda/Labs/lcvdata/freeman/texOutput/',imFile(1:6),'_',append);

% no phase actually just means phase cousins only (no parents)
% noPhaseCorP means no phase adjustments at all

% color76 uses phase, but that's causing convergence issues with multiple
% squares, happens for BW too with the stripe image, for either 2x2 or 3x3
% testnophase is 2x2 without adjusting phase

% rugphase is a single square with phase correlation, i want to compare to the
% same thing without any phase adjustment, that'll be rugnophase

% 18 is correcting variance of HPR

% the only recent changes are the correction for negative eigenvalues in
% adjustCorr2s and the fact that we're now doing the parent cross
% correlations in texColorSynthMask2, compare 41 and 38, also 36 and 39

% 46 and 45 are the same except that i adjust low band cross correlations
% in 46, both are skipping the real parent correlations

% 48 and 49 are the same except that i adjust low band cross correlations
% in 49, both are skipping the real parent correlations


% anlz 2 and synth 4 work fine!

% v. 5 tries to do the parent real corr separately for each color, then the
% cross corr across color bands

% 4/14, i made a chance to wmodcorr2 to use the updated image when computed the autocorr gradient, 
% 65 will test this, let's see what happens!



mkdir(params.outputpath);

imwrite(uint8(oim),fullfile(params.outputpath,strcat('oim',sprintf('_%gx%g.jpg',params.analysis.szx,params.analysis.szy))));

params.savefile = sprintf('%gx%g_%g_%g_%g_%g_%g_%g',params.analysis.szx,params.analysis.szy,params.analysis.Nsc,params.analysis.Nor,params.analysis.maxNa,params.analysis.scale,params.analysis.aspect,params.analysis.overlap);
params.printfile = fullfile(params.outputpath,strcat(params.savefile,'.ps'));

params.printfile,


[m rMask] = mkImMasks(size(oim),params);

%[m rMask] = mkSqMasks(size(oim),params);

[params, m, rMask] = texColorAnlzMask6(oim,params,m,rMask);

res = texColorSynthMask7(params,m,rMask,[size(oim,1) size(oim,2)],oim,50,debugging,0.5,0,[1 1 1 1]);


%[m rMask] = mkImMasks([512 512],params);
%for nclr = 1:3,
%   oim2(:,:,nclr) = real(expand(oim(:,:,nclr), 2));
%end
%res = texColorSynthMask6(params,m,rMask,[512 512],oim2,50,debugging,rate,0,[1 1 1 1]);

exit





