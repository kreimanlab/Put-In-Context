%% 4-PANEL TEXTURE DEMO (will take <1min per iteration)
%
% This version of the model computes parameters within nine windows that
% tile the image. It is NOT the same as the model used in the paper,
% but runs substantially faster, so is a good way to make sure 
% that the code is working. The resulting synthetic image should reproduce the
% texture of the original within coarse square tiles.

% load original image
oim = double(imread('../example-im-512x512.png'));
% oim = imread('/home/mengmi/Projects/Proj_context2/Matlab/Stimulus/img/img_1_1_1.jpg');
% oim = imresize(oim, [512 512]);
% oim = rgb2gray(oim);
% oim = double(oim);

% set options
opts = metamerOpts(oim,'windowType=square','nSquares=[3 1]');

% make windows
m = mkImMasks(opts);

% plot windows
plotWindows(m,opts);

% do metamer analysis on original (measure statistics)
params = metamerAnalysis(oim,m,opts);

% do metamer synthesis (generate new image matched for statistics)
res = metamerSynthesis(params,size(oim),m,opts);


%% METAMER DEMO (will take a few min per iteration)
%
% This version uses windows that tile the image in
% polar angle and log eccentricity, with parameters 
% used to generate metamers in Freeman & Simoncelli

% load original image
oim = double(imread('example-im-512x512.png'));

% set options
opts = metamerOpts(oim,'windowType=radial','scale=0.5','aspect=2');

% make windows
m = mkImMasks(opts);

% plot windows
plotWindows(m,opts);

% do metamer analysis on original (measure statistics)
params = metamerAnalysis(oim,m,opts);

% do metamer synthesis (generate new image matched for statistics)
res = metamerSynthesis(params,size(oim),m,opts);
