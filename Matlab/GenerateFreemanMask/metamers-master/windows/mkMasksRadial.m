function [mask sz] = mkMasksRadial(imSize,windows,verbose)

%
%-----------------------------------------
% mask = mkMasksRadial(imSize,windows)
%
% generates a family of radial window functions
% that tile evenly in angle and log eccentricity
%
% imSize: size of image (2-vector)
% windows: structure containing window parameters
% (see initParams.m)
%
% masks: matrix of window functions
% sz: vector of window sizes
%
% freeman, 12/25/2008
%-----------------------------------------

% check arguments
if nargin < 1
	error('Need to specify size')
end

% grab window parameter values
origin = windows.origin;
scale = windows.scale;
aspect = windows.aspect;
overlap = [windows.overlap, windows.overlap];
centerRad = round(windows.centerRadPerc*(sqrt(prod(imSize))/2));

% create angle and distance matrices
thetaVals = mkAngle(imSize,0,origin)+pi; % define from 0 to 2pi
rVals = mkR(imSize,1,origin);
thetaVals(thetaVals==0) = 0.001;
rVals(rVals == 0) = 0.001;

% distance computaitons
centerRad = log2(centerRad);
tmp = 2*log2((scale+sqrt(scale^2+4))/2);
rTWidth = overlap(2)*tmp;
rWidth = (1-overlap(2))*tmp;
maxCirc = (sqrt(2)/2)*max(rVals(:));
rCenters =centerRad+rWidth+rTWidth:rWidth+rTWidth:(max(log2(rVals(:))))+rWidth+rTWidth;
nRs = length(rCenters);

% compute number of thetas given desired aspect ratio (requires rounding)
nThetas = round((aspect*2*pi)/(2^(tmp/2)-2^(-tmp/2)));
tmpWidth = (2*pi)/nThetas;

% compute circumferential transition width as a function of desired overlap
thetaTWidth = overlap(1)*tmpWidth;
thetaWidth = (2*pi)/nThetas - thetaTWidth;

% define angle centers and width
thetaCenters = (0:nThetas-1)*(thetaWidth+thetaTWidth)-thetaWidth/2;

%ratio =
%(2.^(rCenters+rWidth/2)-2.^(rCenters-rWidth/2))./((2*pi*2.^rCenters)/nThetas)s

imask = 1;
if verbose; T = textWaitbar('(mkMasksRadial) making windows'); end
for itheta=1:nThetas
	[xThetaWin yThetaWin] = mkWinFunc(thetaCenters(itheta),thetaWidth,thetaTWidth,[0 2*pi],1);
	thetaMask = interp1(xThetaWin,yThetaWin,thetaVals);

	for ir=1:nRs
		
		[xRWin yRWin] = mkWinFuncLog(rCenters(ir),rWidth,rTWidth,[0 max(log2(rVals(:)))],0);    
		warning('off')
		rMask = (2.^interp1(xRWin,yRWin,log2(rVals),'linear'));
		rMask(isnan(rMask)) = 0;
		warning('on')

		testMat = thetaMask.*rMask;
		testMat(isnan(testMat)) = 0;
		if ~isequal(testMat,zeros(size(thetaMask)))
			mask(imask,:,:) = testMat;
			sz(imask) = (2^(rCenters(ir)+rWidth+rTWidth) - 2^(rCenters(ir)-rWidth-rTWidth));
			imask = imask + 1;
		end
	end
	if verbose; T = textWaitbar(T,itheta/nThetas); end
end

mask(isnan(mask)) = 0;
