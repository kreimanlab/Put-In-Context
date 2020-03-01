function params = metamerAnalysis(oim,m,opts)

%
%-----------------------------------------
% params = metamerAnalysis(oim,m,opts)
%
% computes statistical parameters of an image
% within a family of overlapping, tiling
% regions defined by windows
% (see metamerParams.m and metamerSynthesis.m)
%
% oim: original image
% m: structure of window functions
% opts: structure of options
%
% params: model statistical parameters
%
% freeman, created 1/21/2009
% freeman, released 3/8/2013
%-----------------------------------------

% get analysis parameters

Nsc = opts.Nsc;
Nor = opts.Nor;
maxNa = opts.maxNa;
Nx = opts.szy; % careful, flipping x and y here
Ny = opts.szx;
[Ny,Nx] = size(oim);

% build complex steerable pyramid in the fourier domain
[pyr0,pind0] = buildSCFpyr(oim,Nsc,Nor-1);

% check to make sure all bands are even
if (any(vector(mod(pind0,2))))
  error('(metamerAnalysis) analysis will fail because some bands have odd dimensions');
end

%% pixel statistics
if opts.verbose; fprintf('(metamerAnalysis) pixel statistics\n'); end
statg0 = zeros(6,m.scale{1}.nMasks);
for imask=1:m.scale{1}.nMasks
  thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
  thisMaskNAN = thisMask;
  thisMaskNAN(thisMaskNAN==0) = NaN;
  thisMaskNAN(thisMaskNAN>0) = 1;
  [mn0 mx0] = range2(oim.*thisMaskNAN);
  mean0 = wmean2(oim,thisMask);
  var0 = wvar2(oim,thisMask);
  skew0 = wskew2(oim,thisMask);
  kurt0 = wkurt2(oim,thisMask);
  statg0(:,imask) = [mean0 var0 skew0 kurt0 mn0 mx0];
end
skew0p.total.full = skew2(oim);
kurt0p.total.full = kurt2(oim);

nband = size(pind0,1);

% compute real parts and magnitudes of subbands
rpyr0 = real(pyr0);
apyr0 = abs(pyr0);

% compute average band magnitudes
for nband = 1:size(pind0,1)
  indices = pyrBandIndices(pind0,nband);
  tempMagMean = mean2(apyr0(indices));
  thisScale = m.bandToMaskScale(nband);
  magMeans0.band{nband} = m.scale{thisScale}.maskNorm'*apyr0(indices);
  apyr0(indices) = apyr0(indices) - tempMagMean;
end

% do some stuff up front before looping through masks
nband = size(pind0,1);
ch = pyrBand(real(pyr0),pind0,nband);
[mpyr,mpind] = buildSFpyr(real(ch),0,0);
im = pyrBand(mpyr,mpind,2);
[Nly Nlx] = size(ch);

if opts.verbose; fprintf('(metamerAnalysis) autocorrelation\n'); end
% compute central autoCorr of lowband
for imask=1:m.scale{Nsc+1}.nMasks
  thisMask = squeeze(m.scale{m.bandToMaskScale(nband)}.maskMat(imask,:,:));
  thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
  thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
  thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
  ac = wacorr2(im,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
  acr.scale{Nsc+1}.mask{imask} = ac;
  vari = ac(ceil(size(ac,1)/2),ceil(size(ac,1)/2));
  
  if vari/var0 > 1e-6,
    skew0p.scale{Nsc+1}(imask) = wskew2(im,thisMask);
    kurt0p.scale{Nsc+1}(imask) = wkurt2(im,thisMask);
  else
    skew0p.scale{Nsc+1}(imask) = 0;
    kurt0p.scale{Nsc+1}(imask) = 3;
  end
end
skew0p.total.scale{Nsc+1} = skew2(im);
kurt0p.total.scale{Nsc+1} = kurt2(im);

% compute central autoCorr of each Mag band,
% and the autoCorr of the combined (non-oriented) band.
for nsc = Nsc:-1:1,
  for nor = 1:Nor,
    nband = (nsc-1)*Nor+nor+1;
    ch = pyrBand(apyr0,pind0,nband);
    [Nly, Nlx] = size(ch);
    for imask=1:m.scale{nsc}.nMasks
      thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
      thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
      thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
      thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
      [ac acFull] = wacorr2(ch,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
      ace.scale{nsc}.ori{nor}.mask{imask} = ac;
      aceFull.scale{nsc}.ori{nor}.mask{imask} = acFull;
    end
  end
  
  % combine ori bands
  bandNums = [1:Nor] + (nsc-1)*Nor+1;
  ind1 = pyrBandIndices(pind0, bandNums(1));
  indN = pyrBandIndices(pind0, bandNums(Nor));
  bandInds = [ind1(1):indN(length(indN))];

  % make fake pyramid, containing dummy hi, ori, lo
  fakePind = [pind0(bandNums(1),:);pind0(bandNums(1):bandNums(Nor)+1,:)];
  fakePyr = [zeros(prod(fakePind(1,:)),1);...
    rpyr0(bandInds); zeros(prod(fakePind(size(fakePind,1),:)),1);];
  ch = reconSFpyr(fakePyr, fakePind, [1]);     % recon ori bands only
  im = real(expand(im,2))/4;
  im = im + ch;
  for imask=1:m.scale{nsc}.nMasks
    thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
    thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
    thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
    thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
    [ac acFull] = wacorr2(im,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
    acr.scale{nsc}.mask{imask} = ac;
    acrFull.scale{nsc}.mask{imask} = acFull;
    vari = ac(ceil(size(ac,1)/2),ceil(size(ac,1)/2));
    if vari/var0 > 1e-6, % don't understand this check!
      skew0p.scale{nsc}(imask) = wskew2(im,thisMask);
      kurt0p.scale{nsc}(imask) = wkurt2(im,thisMask);
    else
      skew0p.scale{nsc}(imask) = 0;
      kurt0p.scale{nsc}(imask) = 3;
    end
  end
  skew0p.total.scale{nsc} = skew2(im);
  kurt0p.total.scale{nsc} = kurt2(im);
end

if opts.verbose; fprintf('(metamerAnalysis) cross correlations\n'); end
% compute cross-correlation matrices of the coefficient magnitudes
% at the different levels and orientations

% preallocate matrices
for nsc=1:Nsc+1
  for imask = 1:m.scale{nsc}.nMasks
    if nsc < Nsc+1
      C0.scale{nsc}.mask{imask} = zeros(Nor,Nor);
      Cr0.scale{nsc}.mask{imask} = zeros(2*Nor,2*Nor);
    end
    Cx0.scale{nsc}.mask{imask} = zeros(Nor,Nor);
    Crx0.scale{nsc}.mask{imask} = zeros(2*Nor,2*Nor);
  end
end

% compute the correlations
for nsc = 1:Nsc,
  firstBnum = (nsc-1)*Nor+2;
  cousinSz = prod(pind0(firstBnum,:));
  ind = pyrBandIndices(pind0,firstBnum);
  cousinInd = ind(1) + [0:Nor*cousinSz-1];
  
  if (nsc<Nsc)
    parents = zeros(cousinSz,Nor);
    rparents = zeros(cousinSz,Nor*2);
    for nor=1:Nor,
      nband = (nsc-1+1)*Nor+nor+1;
      tmp = expand(pyrBand(pyr0, pind0, nband),2)/4;
      rtmp = real(tmp); itmp = imag(tmp);
      tmp = sqrt(rtmp.^2 + itmp.^2) .* exp(2 * sqrt(-1) * atan2(rtmp,itmp));
      rparents(:,nor) = vector(real(tmp));
      rparents(:,Nor+nor) = vector(imag(tmp));
      tmp = abs(tmp);
      parents(:,nor) = vector(tmp - mean2(tmp));
    end
  else
    tmp = real(expand(pyrLow(rpyr0,pind0),2))/4;
    rparents = [vector(tmp),...
      vector(shift(tmp,[0 1])), vector(shift(tmp,[0 -1])), ...
      vector(shift(tmp,[1 0])), vector(shift(tmp,[-1 0]))];
    parents = [];
  end
  
  cousins = reshape(apyr0(cousinInd), [cousinSz Nor]);
  nc = size(cousins,2);   np = size(parents,2);
  
  for imask = 1:m.scale{nsc}.nMasks;
    clear cousinstmp
    clear parentstmp
    thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
    for inc=1:nc
      cousinstmp(:,inc) = (cousins(:,inc) - wmean2(cousins(:,inc),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
    end
    for inp=1:np
      parentstmp(:,inp) = (parents(:,inp) - wmean2(parents(:,inp),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
    end
    C0.scale{nsc}.mask{imask}(1:nc,1:nc) = innerProd(cousinstmp)/cousinSz;
    if (np > 0)
      Cx0.scale{nsc}.mask{imask}(1:nc,1:np) = (cousinstmp'*parentstmp)/cousinSz;
      if (nsc==Nsc)
        C0.scale{Nsc+1}.mask{imask}(1:np,1:np) = innerProd(parentstmp)/(cousinSz/4); % divide by 1/4?;
      end
    end
    
  end
  
  cousins = reshape(real(pyr0(cousinInd)), [cousinSz Nor]);
  nrc = size(cousins,2);   nrp = size(rparents,2);
  
  for imask = 1:m.scale{nsc}.nMasks;
    clear cousinstmp
    clear rparentstmp
    thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
    for inc=1:nc
      cousinstmp(:,inc) = (cousins(:,inc) - wmean2(cousins(:,inc),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
    end
    for inrp=1:nrp
      rparentstmp(:,inrp) = (rparents(:,inrp) - wmean2(rparents(:,inrp),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
    end
    Cr0.scale{nsc}.mask{imask}(1:nrc,1:nrc) = innerProd(cousinstmp)/cousinSz;
    if (nrp > 0)
      Crx0.scale{nsc}.mask{imask}(1:nrc,1:nrp) = (cousinstmp'*rparentstmp)/cousinSz;
      if (nsc==Nsc)
        Cr0.scale{Nsc+1}.mask{imask}(1:nrp,1:nrp) = innerProd(rparentstmp)/cousinSz; % divide by 1/4?
      end
    end
  end
end

% calculate the mean, range and variance of the LF and HF residuals' energy.
channel = pyr0(pyrBandIndices(pind0,1));
channel = reshape(channel,Ny,Nx);

for imask=1:m.scale{1}.nMasks
  thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
  thisInd = m.scale{1}.ind(imask,:);
  thisNa = m.scale{1}.Na(imask);
  thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
  
  ac = wacorr2(channel,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
  acr.vHPR.mask{imask} = ac;
end

channel = vector(channel);
vHPR0 = zeros(1,m.scale{1}.nMasks);

for imask=1:m.scale{1}.nMasks
  thisMask = m.scale{1}.maskMat(imask,:,:);
  vHPR0(imask) = wvar2(channel,thisMask(:));
end

% store parameters in a structure
params = struct('pixelStats', statg0, ...
  'LPskew', skew0p, ...
  'LPkurt',kurt0p,...
  'autoCorrReal', acr, ...
  'autoCorrRealFull', acrFull, ...
  'autoCorrMag', ace, ...
  'autoCorrMagFull', aceFull, ...
  'magMeans', magMeans0, ...
  'cousinMagCorr', C0, ...
  'parentMagCorr', Cx0, ...
  'cousinRealCorr', Cr0, ...
  'parentRealCorr', Crx0, ...
  'varianceHPR', vHPR0);

% store the original image
params.oim = oim;