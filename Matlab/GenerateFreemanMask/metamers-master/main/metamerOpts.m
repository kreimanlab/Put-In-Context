function opts = metamerOpts(oim,varargin)

%
%-----------------------------------------
% opts = metamerOpts(varagin)
%
% generates a structure of parameters for 
% metamer analysis and synthesis 
% (see metamerAnalysis.m and metamerSynthesis.m)
%
% oim: original image to be used in analysis
% 
% opts: structure containing options
%
% examples:
%
% metamerOpts(oim,'windowType=square','nSquares=[2,2]')
% uses a 2x2 array of square windowing functions
%
% metamerOpts(oim,'windowType=radial','scale=0.75','aspect=1')
% uses radial window functions with 
% size / eccentricity of 0.75
% and a circumferential aspect ratio of 1
%
% metamerOpts('Nsc=3','Nor=3')
% uses only 3 scales and 2 orientations for V1 filters
%
% options:
% printing - output an image after each step (0 or 1)
% verbose - tell you what's going on at each step (0 or 1)
% debugging - show parameter convergence (0 or 1)
% Na - number of positions in V1 stage
% Nsc - number of scales in V1 stage
% Nor - number of orientations in V1 stage
% randState - random seed state (empty to use clock)
% nIters - synthesis iterations
% windowType - window functions (radial or square)
%
% freeman, 3/8/13
%-----------------------------------------

eval(evalargs(varargin))

% defaults
if ieNotDefined('printing'); printing = 1; end
if ieNotDefined('verbose'); verbose = 1; end
if ieNotDefined('debugging'); debugging = 0; end

if ieNotDefined('Na'); Na = 7; end
if ieNotDefined('Nsc'); Nsc = 4; end
if ieNotDefined('Nor'); Nor = 4; end

if ieNotDefined('outputPath'); outputPath = pwd; end
if ieNotDefined('nIters'); nIters = 50; end

if ieNotDefined('windowType'); windowType = 'radial'; end
if ieNotDefined('aspect'); aspect = 2; end
if ieNotDefined('scale'); scale = 0.5; end
if ieNotDefined('overlap'); overlap = 0.5; end
if ieNotDefined('centerRadPerc'); centerRadPerc = 0.025; end
if ieNotDefined('origin'); origin = []; end

opts.outputPath = outputPath;
opts.nIters = nIters;
opts.printing = printing;
opts.debugging = debugging;
opts.verbose = verbose;

opts.szx = size(oim,2);
opts.szy = size(oim,1);

opts.Nsc = Nsc;
opts.Nor = Nor;
opts.maxNa = Na;

if opts.Nsc < 3 || opts.Nsc > 5
  error('(metamerOpts) only 3,4, or 5 scales supported');
end

[pyr0,pind0] = buildSCFpyr(oim(:,:,1),opts.Nsc,opts.Nor-1);

% check to make sure all bands are even
if (any(vector(mod(pind0,2))))
  error('(metamerOpts) model will fail because some bands have odd dimensions');
end

if opts.verbose; fprintf('(metamerOpts) %g scales\n',opts.Nsc); end
if opts.verbose; fprintf('(metamerOpts) %g orientaitons\n',opts.Nor); end
if opts.verbose; fprintf('(metamerOpts) %gx%g neighborhood\n',opts.maxNa,opts.maxNa); end

opts.windows.windowType = windowType;
opts.windows.overlap = overlap;
switch opts.windows.windowType
case 'radial'
  opts.windows.scale = scale;
  opts.windows.aspect = aspect;
  opts.windows.centerRadPerc = centerRadPerc;
  opts.windows.origin = origin;
  if isempty(opts.windows.origin)
    opts.windows.origin = [(opts.szx+1)/2 (opts.szy+1)/2];
  end
  opts.saveFile = sprintf('%gx%g_s%g_a%g_o%g',opts.szx,opts.szy,opts.windows.scale,opts.windows.aspect,opts.windows.overlap);
case 'square'
  opts.windows.nSquares = nSquares;
  opts.saveFile = sprintf('%gx%g_s%gx%g_o%g',opts.szx,opts.szy,opts.windows.nSquares(1),opts.windows.nSquares(2),opts.windows.overlap);
otherwise
  error('(metamerOpts) invalid window function setting');
end

if opts.verbose; fprintf('(metamerOpts) %s windows\n',opts.windows.windowType); end



