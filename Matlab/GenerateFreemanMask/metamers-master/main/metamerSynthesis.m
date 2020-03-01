function im = metamerSynthesis(params,seed,m,opts)

%
%-----------------------------------------
% metamerSynthesis(params,seed,m,opts)
%
% generates an image matched to a set of
% statistical parameters computed within
% a set of tiling regions defined by window functions
% (see metamerParams.m and metamerAnalysis.m)
%
% params: structure of model parameters (see metamerAnalysis.m)
% seed: can specify the size of the synthetic image ([x,y])
%       the size and setting of the random number generator ([x,y,n])
%       or a seed image (2d matrix)
% m: structure of window functions
% opts: structure of options
%
% im: syntheiszed image
%
% freeman, created 1/29/2009
% freeman, released 3/8/2013
%-----------------------------------------

% set gradient rate parameters
NiterperW = 2;
if opts.Nsc == 3
  NiterperW = [NiterperW*2 NiterperW*2 NiterperW*3 NiterperW*20];
end
if opts.Nsc == 4
  NiterperW = [NiterperW*2 NiterperW*2 NiterperW*2 NiterperW*3 NiterperW*20];
end
if opts.Nsc == 5
  NiterperW = [NiterperW*2 NiterperW*2 NiterperW*2 NiterperW*3 NiterperW*20 NiterperW*20];
end

NiterSkew = 20;
NiterKurt = 20;
skewRate = 50;
kurtRate = 0.05;
epPixSkew = repmat(skewRate,[1 opts.Nsc+1]);
epPixKurt = repmat(kurtRate,[1 opts.Nsc+1]);
epPixVar = 1;

rate = 0.5;
epLowVar = rate;
epMagVar = repmat(rate,[1 opts.Nsc]);
epResVar = repmat(rate,[1 opts.Nsc]);

if opts.debugging
  clf;
  colormap gray; set(gcf,'color',[.3 .3 .3],'inverthardcopy','off');
  ax(1) = axes('pos',[.01 .5 .48 .48]);
  ax(2) = axes('pos',[.5 .5 .48 .48]);
  ax(3) = axes('pos',[.05 .05 .08 .4]);
  ax(4) = axes('pos',[.17 .05 .08 .4]);
  ax(5) = axes('pos',[.29 .05 .08 .4]);
  ax(6) = axes('pos',[.41 .05 .08 .4]);
  ax(7) = axes('pos',[.53 .05 .08 .4]);
  ax(8) = axes('pos',[.65 .05 .08 .4]);
  ax(9) = axes('pos',[.77 .05 .08 .4]);
  ax(10) = axes('pos',[.89 .05 .08 .4]);
end

if opts.verbose; fprintf('(metamerSynthesis) starting...\n'); end

% make normalized mask matrices
for iscale=1:length(m.scale)
  W.scale{iscale} = zeros(size(m.scale{iscale}.maskMat,2)*size(m.scale{iscale}.maskMat,3),m.scale{iscale}.nMasks);
  for iw=1:m.scale{iscale}.nMasks
    w = squeeze(m.scale{iscale}.maskMat(iw,:,:));
    W.scaleUnnorm{iscale}(:,iw) = vector(w);
    W.scale{iscale}(:,iw) = vector(w/sum(w(:)));
    W.scaleSq{iscale}(:,:,iw) = w/sum(w(:));
    W.scaleSqrt{iscale}(:,:,iw) = sqrt(w/sum(w(:)));
    W.ind{iscale}(:,iw) = m.scale{iscale}.ind(iw,:);
    W.Na{iscale}(iw) = m.scale{iscale}.Na(iw);
    W.sum{iscale} = sum(W.scaleUnnorm{iscale});
    W.sz{iscale}(iw) = m.scale{iscale}.sz(iw);
  end
  W.full{iscale} = reshape(sum(reshape(m.scale{iscale}.maskMat,size(m.scale{iscale}.maskMat,1),size(m.scale{iscale}.maskMat,2)*size(m.scale{iscale}.maskMat,3)),1),size(m.scale{iscale}.maskMat,2),size(m.scale{iscale}.maskMat,3));
end

% extract parameters
Nsc = opts.Nsc;
Nor = opts.Nor;
for iw = 1:m.scale{1}.nMasks
  statg0 = params.pixelStats(:,iw);
  mean0(iw) = statg0(1);
  var0(iw) = statg0(2);
  skew0(iw) = statg0(3);
  kurt0(iw) = statg0(4);
  mn0(iw) = statg0(5);
  mx0(iw) = statg0(6);
end
skew0 = clip(skew0,-4,4);
kurt0 = clip(kurt0,0,3);
skew0p = params.LPskew;
kurt0p = params.LPkurt;
vHPR0 = params.varianceHPR;
acr0 = params.autoCorrReal;
ace0 = params.autoCorrMag;
magMeans0 = params.magMeans;
C0 = params.cousinMagCorr;
Cr0 = params.cousinRealCorr;
Cx0 = params.parentMagCorr;
Crx0 = params.parentRealCorr;
for nsc=1:Nsc+1
  nW(nsc) = m.scale{nsc}.nMasks;
  skew0p.scale{nsc} = clip(skew0p.scale{nsc},-4,4);
  kurt0p.scale{nsc} = clip(kurt0p.scale{nsc},0,3);
end

% create original image at each scale
oim.full = params.oim;
[oimpyr, oimpind] = buildSCFpyr(params.oim,Nsc,Nor-1);
roimpyr = real(oimpyr);
aoimpyr = abs(oimpyr);
nband = size(oimpind,1);
ch = pyrBand(oimpyr,oimpind,nband);
[mpyr,mpind] = buildSFpyr(real(ch),0,0);
im = pyrBand(mpyr,mpind,2);
oim.scale{Nsc+1} = im;
for nsc=Nsc:-1:1
  for nor=1:Nor
    oim.mag.scale{nsc}.or{nor} = pyrBand(aoimpyr,oimpind,nor + (nsc-1)*Nor+1);
  end
end
for nsc=Nsc:-1:1
  bandNums = [1:Nor] + (nsc-1)*Nor+1;
  ind1 = pyrBandIndices(oimpind, bandNums(1));
  indN = pyrBandIndices(oimpind, bandNums(Nor));
  bandInds = [ind1(1):indN(length(indN))];
  fakePind = [oimpind(bandNums(1),:);oimpind(bandNums(1):bandNums(Nor)+1,:)];
  fakePyr = [zeros(prod(fakePind(1,:)),1);...
    roimpyr(bandInds); zeros(prod(fakePind(size(fakePind,1),:)),1);];
  ch = reconSFpyr(fakePyr, fakePind, [1]);
  im = real(expand(im,2))/4;
  im = im + ch;
  oim.scale{nsc} = im;
end
oim.HPR = oimpyr(pyrBandIndices(oimpind,1));

% initialize image depending on the seed

if isempty(seed)
  seedSz = [opts.szx, opts.szy];
  randn('state',sum(100*clock));
  if opts.verbose; fprintf('(metamerOpts) setting rand seed from clock\n'); end
elseif length(seed) == 2
  seedSz = seed;
  randn('state',sum(100*clock));;
  if opts.verbose; fprintf('(metamerOpts) setting rand seed from clock\n'); end
elseif length(seed) == 3
  seedSz = seed(1:2);
  randn('state',seed(3));
  if opts.verbose; fprintf('(metamerOpts) setting rand seed to %g\n',seed(3)); end
else
  if opts.verbose; fprintf('(metamerOpts) using user-provided seed\n'); end
end

% create initial noise image (or use provided seed image)
if (length(seed) <= 3 )
  im = mean(mean0) + sqrt(mean(var0))*randn(seedSz);
else
  im = seed;
end

[Ny,Nx] = size(im);

prev_im=im;

if opts.printing
  imwrite(uint8(oim.full),fullfile(opts.outputPath,strcat(opts.saveFile,sprintf('_original'),'.png')));
  imwrite(uint8(im),fullfile(opts.outputPath,strcat(opts.saveFile,sprintf('_iter_0'),'.png')));
end


if opts.verbose; T = textWaitbar('(metamerSynthesis) doing iterations'); end
% main loop
for niter=1:opts.nIters
  
  % build the steerable pyramid
  [pyr,pind] = buildSCFpyr(im,Nsc,Nor-1);
  apyr = abs(pyr);
  
  if ( any(vector(mod(pind,4))) )
    error('(metamerSynthesis) band dimensions must be multiples of 4');
  end
  
  % initialize reconstructured image to lowband
  nband = size(pind,1);
  ch = pyrBand(pyr,pind,nband);
  im = real(ch);
  [mpyr,mpind] = buildSFpyr(im,0,0);
  im = pyrBand(mpyr,mpind,2);
  
  [Nly Nlx] = size(im);
  
  im = im.*W.full{Nsc+1} + oim.scale{Nsc+1}.*(1-W.full{Nsc+1});
  
  % adjust mean and variance of lowband for each mask
  clear meanSNR
  clear varSNR
  clear skewSNR
  clear kurtSNR
  clear acorrSNR
  clear targetMeans
  clear targetVars
  im = vector(im);
  for iw=1:nW(Nsc+1)
    thisNa = W.Na{Nsc+1}(iw);
    le = floor((thisNa-1)/2);
    targetVars(iw) = acr0.scale{Nsc+1}.mask{iw}(le+1:le+1,le+1:le+1);
    targetAcorr{iw} = squeeze(acr0.scale{Nsc+1}.mask{iw});
  end
  targetMeans = (W.scale{Nsc+1}'*vector(oim.scale{Nsc+1}))';
  targetSkew = skew0p.scale{Nsc+1};
  targetKurt = kurt0p.scale{Nsc+1};
  preCalcInv = pinv(W.scale{Nsc+1}'*W.scale{Nsc+1});
  
  if niter == 1
    im = im * sqrt(var2(oim.scale{Nsc+1})/var2(im));
  end
  
  for niterw=1:NiterperW(Nsc+1)
    
    im = wmodacorr2(im,targetAcorr,W.scaleSq{Nsc+1},W.scaleSqrt{Nsc+1},epLowVar,1,W.Na{Nsc+1},W.ind{Nsc+1},W.sz{Nsc+1},W.scale{Nsc+1});
    im = wmodmean2(im,targetMeans,W.scale{Nsc+1},preCalcInv);
    
    if opts.debugging
      for iw=1:nW(Nsc+1)
        w = W.scale{Nsc+1}(:,iw);
        wSq = W.scaleSq{Nsc+1}(:,:,iw);
        wSqrt = W.scaleSqrt{Nsc+1}(:,:,iw);
        wind = W.ind{Nsc+1}(:,iw);
        na = W.Na{Nsc+1}(iw);
        meanSNR(iw,niterw) = (targetMeans(iw)-wmean2(im,w))^2;
        tmptarget = targetAcorr{iw};
        tmpAcorr = wacorr2(reshape(im,sqrt(length(im)),sqrt(length(im))),wSq,wSqrt,wind,na,na,0);
        acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
      end
      axes(ax(7)); plot(acorrSNR');
      axes(ax(2)); imagesc(reshape(im,sqrt(length(im)),sqrt(length(im))));
      axis image off; colormap gray;
      title(sprintf('lowband var, %g/%g',niterw,NiterperW(Nsc+1)));
      drawnow;
    end
  end
  
  goodinds = find((W.sum{Nsc+1}/numel(im))>0.01);
  Wtmp = W.scale{Nsc+1}(:,goodinds);
  Wsumtmp = W.sum{Nsc+1}(goodinds);
  
  for niterw=1:NiterSkew
    im = wmodskew2(im,targetSkew(goodinds),Wtmp,Wsumtmp,1,epPixSkew(Nsc+1),Nsc+1);
    im = wmodmean2(im,targetMeans,W.scale{Nsc+1},preCalcInv);
    if opts.debugging
      for iw=1:nW(Nsc+1)
        w = W.scale{Nsc+1}(:,iw);
        skewSNR(iw,niterw) = (targetSkew(iw)-wskew2(im,w))^2;
      end
      axes(ax(5)); plot(skewSNR'); drawnow;
      axes(ax(2)); imagesc(reshape(im,sqrt(length(im)), sqrt(length(im))));
    end
  end    
  
  for niterw=1:NiterKurt
    im = wmodkurt2(im,targetKurt(goodinds),Wtmp,Wsumtmp,1,epPixKurt(Nsc+1),Nsc+1);
    im = wmodmean2(im,targetMeans,W.scale{Nsc+1},preCalcInv);
    if opts.debugging
      for iw=1:nW(Nsc+1)
        w = W.scale{Nsc+1}(:,iw);
        kurtSNR(iw,niterw) = (targetKurt(iw)-wkurt2(im,w))^2;
      end
      
      axes(ax(6)); plot(kurtSNR'); drawnow;
      axes(ax(2)); imagesc(reshape(im,sqrt(length(im)),sqrt(length(im))));
    end
  end
  
  im = reshape(im,pind(nband,1),pind(nband,2));
  
  % coarse-to-fine loop
  for nsc=Nsc:-1:1
    
    firstBnum = (nsc-1)*Nor+2;
    nband = (nsc-1)*Nor+2;
    cousinSz = prod(pind(firstBnum,:));
    ind = pyrBandIndices(pind,firstBnum);
    cousinInd = ind(1) + [0:Nor*cousinSz-1];
    
    % interpolate parents
    if nsc < Nsc
      parents = zeros(cousinSz,Nor);
      rparents = zeros(cousinSz,Nor*2);
      for nor = 1:Nor
        nband = (nsc+1-1)*Nor + nor + 1;
        tmp = expand(pyrBand(pyr,pind,nband),2)/4;
        rtmp = real(tmp); itmp = imag(tmp);
        tmp = sqrt(rtmp.^2 + itmp.^2) .* exp(2 * sqrt(-1) * atan2(rtmp,itmp));
        rparents(:,nor) = vector(real(tmp));
        rparents(:,Nor+nor) = vector(imag(tmp));
        tmp = abs(tmp);
        parents(:,nor) = vector(tmp - mean2(tmp));
      end
    else
      tmp = real(expand(pyrLow(pyr,pind),2))/4;
      rparents = [vector(tmp),vector(shift(tmp,[0 1])),vector(shift(tmp,[0 -1])), ...
        vector(shift(tmp,[1 0])), vector(shift(tmp,[-1 0]))];
      parents = [];
    end
    
    cousins = reshape(apyr(cousinInd), [cousinSz Nor]);
    nc = size(cousins,2); np = size(parents,2);
    cousinsnew = zeros(size(cousins));
    
    for iw = 1:nW(nsc)
      w = W.scale{nsc}(:,iw);
      sqw = sqrt(w);
      
      if np == 0
        for inc=1:nc
          tmpmean(inc) = wmean2(cousins(:,inc),w);
          cousinstmp(:,inc) = (cousins(:,inc) - tmpmean(inc)).*sqw;
        end
        [cousinstmp] = adjustCorr1s(cousinstmp, C0.scale{nsc}.mask{iw}(1:nc,1:nc),2);
        cousinstmp = real(cousinstmp);
      else
        for inc=1:nc
          tmpmean(inc) = wmean2(cousins(:,inc),w);
          cousinstmp(:,inc) = (cousins(:,inc) - tmpmean(inc)).*sqw;
        end
        for inp=1:np
          parentstmp(:,inp) = (parents(:,inp) - wmean2(parents(:,inp),w)).*sqw;
        end
        warning('off');
        cousinstmp = adjustCorr2s(cousinstmp, C0.scale{nsc}.mask{iw}(1:nc,1:nc), parentstmp,Cx0.scale{nsc}.mask{iw}(1:nc,1:np), 3);
        warning('on');
        cousinstmp = real(cousinstmp);
      end

      undow = zeros(size(w));
      undow(sqw>0.0001) = 1./sqw(sqw>0.0001);
      for inc=1:nc
        cousinstmp(:,inc) = cousinstmp(:,inc).*undow + tmpmean(inc);
        cousinstmp(:,inc) = cousinstmp(:,inc).*W.scaleUnnorm{nsc}(:,iw);
      end
      cousinsnew = cousinsnew + cousinstmp;
      clear cousinstmp
      clear tmpmean
      clear parentstmp
    end
    
    cousinsnew = real(cousinsnew);
    ind = cousinInd;
    apyr(ind) = vector(cousinsnew);
    
    for nor = 1:Nor
      clear meanSNR
      clear acorrSNR
      clear skewSNR
      clear kurtSNR
      clear targetMeans
      clear targetVars
      clear targetAcorr
      clear ch
      
      nband = (nsc-1)*Nor+nor+1;
      ch = pyrBand(apyr,pind,nband);
      [Nly Nlx] = size(ch);
      
      % add in original magnitudes
      ch = ch.*W.full{nsc} + oim.mag.scale{nsc}.or{nor}.*(1-W.full{nsc});
      
      ch = vector(ch);
      
      for iw=1:nW(nsc)
        thisNa = W.Na{nsc}(iw);
        le = floor((thisNa-1)/2);
        targetVars(iw) = ace0.scale{nsc}.ori{nor}.mask{iw}(le+1:le+1,le+1:le+1);
        targetAcorr{iw} = squeeze(ace0.scale{nsc}.ori{nor}.mask{iw});
      end
      
      targetMeans = magMeans0.band{nband}';
      
      preCalcInv = pinv(W.scale{nsc}'*W.scale{nsc});
      
      for niterw=1:NiterperW(nsc)
        
        ch = wmodacorr2(ch,targetAcorr,W.scaleSq{nsc},W.scaleSqrt{nsc},epMagVar(nsc),1,W.Na{nsc},W.ind{nsc},W.sz{nsc},W.scale{nsc});
        ch = wmodmean2(ch,targetMeans,W.scale{nsc},preCalcInv);
        
        if opts.debugging
          for iw=1:nW(nsc)
            w = W.scale{nsc}(:,iw);
            wSq = W.scaleSq{nsc}(:,:,iw);
            wSqrt = W.scaleSqrt{nsc}(:,:,iw);
            wind = W.ind{nsc}(:,iw);
            na = W.Na{nsc}(iw);
            %meanSNR(iw,niterw) = snr(targetMeans(iw),wmean2(ch,w) - targetMeans(iw));
            
            tmptarget = targetAcorr{iw};
            tmpAcorr = wacorr2(reshape(ch,sqrt(length(ch)),sqrt(length(ch))),wSq,wSqrt,wind,na,na,0);
            acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
            
            signal = targetVars(iw);
            noise = signal - wvar2(ch,w);
            acorrSNR(iw,niterw) = snr(signal,noise);
            
          end
          axes(ax(8)); plot(acorrSNR');
          %axes(ax(5)); plot(meanSNR');
          axes(ax(2)); imagesc(reshape(real(ch),sqrt(length(ch)),sqrt(length(ch))));
          colormap gray; axis image off;
          title(sprintf('(metamerSynthesis) mag mean and var, scale %g, ori %g, iteration %g/%g',nsc,nor,niterw,NiterperW(nsc)));
          drawnow;
        end
      end
      
      ch = real(ch);
      ch = reshape(ch,pind(nband,1),pind(nband,2));
      
      ind = pyrBandIndices(pind,nband);
      apyr(ind) = ch;
      mag = apyr(ind);
      mag = mag.*(mag>0);
      pyr(ind) = pyr(ind) .* (mag./(abs(pyr(ind))+(abs(pyr(ind))<eps)));
      
    end
    
    
    % adjust cross-correlation of real and imaginary parts at other orientations/scales
    cousins = reshape(real(pyr(cousinInd)), [cousinSz Nor]);
    Nrc = size(cousins,2); Nrp = size(rparents,2);
    
    if Nrp ~= 0
      
      goodinds = find((W.sum{nsc}/numel(im))>0.001);
      
      cousinsnew = zeros(size(cousins));
      for iw = 1:nW(nsc)
        
        if sum(goodinds==iw)
          
          w = W.scale{nsc}(:,iw);
          sqw = sqrt(w);
          undow = zeros(size(w));
          undow(sqw>0.0001) = 1./sqw(sqw>0.0001);
          for inrp=1:Nrp
            rparentstmp(:,inrp) =  (rparents(:,inrp) - wmean2(rparents(:,inrp),w)).*sqw;
          end
          for nrc = 1:Nrc
            tmpmean(nrc) = wmean2(cousins(:,nrc),w);
            rcousinstmp(:,nrc) = (cousins(:,nrc) - tmpmean(nrc)).*sqw;
          end
          rcousinstmp = adjustCorr2s(rcousinstmp,Cr0.scale{nsc}.mask{iw}(1:Nrc,1:Nrc),...
            rparentstmp,Crx0.scale{nsc}.mask{iw}(1:Nrc,1:Nrp),3);
          for nrc = 1:Nrc
            rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*undow + tmpmean(nrc);
            rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*W.scaleUnnorm{nsc}(:,iw);
          end
          cousinsnew = cousinsnew + rcousinstmp;
        else
          for nrc = 1:Nrc
            cousinsnew(:,nrc) = cousinsnew(:,nrc) + cousins(:,nrc).*W.scaleUnnorm{nsc}(:,iw);
          end
        end
        
      end
      
      clear rparentstmp
      clear rcousinstmp
    end
    
    pyr(cousinInd) = vector(cousinsnew(1:Nor*cousinSz));
    
    % re-create analytic subbands
    dims = pind(firstBnum,:);
    ctr = ceil((dims+0.5)/2);
    ang = mkAngle(dims, 0, ctr);
    ang(ctr(1),ctr(2)) = -pi/2;
    for nor = 1:Nor,
      nband = (nsc-1)*Nor+nor+1;
      ind = pyrBandIndices(pind,nband);
      ch = pyrBand(pyr, pind, nband);
      ang0 = pi*(nor-1)/Nor;
      xang = mod(ang-ang0+pi, 2*pi) - pi;
      amask = 2*(abs(xang) < pi/2) + (abs(xang) == pi/2);
      amask(ctr(1),ctr(2)) = 1;
      amask(:,1) = 1;
      amask(1,:) = 1;
      amask = fftshift(amask);
      ch = ifft2(amask.*fft2(ch));	% "Analytic" version
      pyr(ind) = ch;
    end
    
    % combine ori bands
    bandNums = [1:Nor] + (nsc-1)*Nor+1;  %ori bands only
    ind1 = pyrBandIndices(pind, bandNums(1));
    indN = pyrBandIndices(pind, bandNums(Nor));
    bandInds = [ind1(1):indN(length(indN))];
    %% Make fake pyramid, containing dummy hi, ori, lo
    fakePind = pind([bandNums(1), bandNums, bandNums(Nor)+1],:);
    fakePyr = [zeros(prod(fakePind(1,:)),1);...
      real(pyr(bandInds)); zeros(prod(fakePind(size(fakePind,1),:)),1)];
    ch = reconSFpyr(fakePyr, fakePind, [1]);     % recon ori bands only
    im = real(expand(im,2))/4;
    im = im + ch;
    im = im.*W.full{nsc} + oim.scale{nsc}.*(1-W.full{nsc});
    
    % fix real autocorrelation of lowpass suband
    clear meanSNR
    clear acorrSNR
    clear skewSNR
    clear kurtSNR
    clear targetMeans
    clear targetVars
    
    [Nly Nlx] = size(im);
    
    im = vector(im);
    
    for iw=1:nW(nsc)
      thisNa = W.Na{nsc}(iw);
      le = floor((thisNa-1)/2);
      targetVars(iw) = acr0.scale{nsc}.mask{iw}(le+1:le+1,le+1:le+1);
      targetAcorr{iw} = squeeze(acr0.scale{nsc}.mask{iw});
    end
    
    if niter == 1
      im = im * sqrt(var2(oim.scale{nsc})/var2(im));
    end
    
    targetMeans = (W.scale{nsc}'*im)'; % keep mean?
    targetSkew = skew0p.scale{nsc};
    targetKurt = kurt0p.scale{nsc};
    preCalcInv = pinv(W.scale{nsc}'*W.scale{nsc});
    
    for niterw=1:NiterperW(nsc)
      
      im = wmodacorr2(im,targetAcorr,W.scaleSq{nsc},W.scaleSqrt{nsc},epResVar(nsc),1,W.Na{nsc},W.ind{nsc},W.sz{nsc},W.scale{nsc});
      im = wmodmean2(im,targetMeans,W.scale{nsc},preCalcInv);
      
      if opts.debugging
        for iw=1:nW(nsc)
          w = W.scale{nsc}(:,iw);
          wSq = W.scaleSq{nsc}(:,:,iw);
          wSqrt = W.scaleSqrt{nsc}(:,:,iw);
          wind = W.ind{nsc}(:,iw);
          na = W.Na{nsc}(iw);
          
          tmptarget = targetAcorr{iw};
          tmpAcorr = wacorr2(reshape(im,sqrt(length(im)),sqrt(length(im))),wSq,wSqrt,wind,na,na,0);
          acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
          meanSNR(iw,niterw) = abs(wmean2(im,w) - targetMeans(iw));
          %skewSNR(iw,niterw) = (targetSkew(iw) - wskew2(im,w))^2;
          %kurtSNR(iw,niterw) = (targetKurt(iw) - wkurt2(im,w))^2;
        end
        axes(ax(7)); plot(acorrSNR');
        %axes(ax(5)); plot(skewSNR');
        %axes(ax(6)); plot(kurtSNR');
        axes(ax(2)); imagesc(reshape(real(im),sqrt(length(im)),sqrt(length(im))));
        axis image off; colormap gray;
        title(sprintf('lowpass var, scale %g, iteration %g/%g',nsc,niterw,NiterperW(nsc)));
        drawnow;
      end      
    end
    
    im = real(im);
    
    if nsc>1

      for niterw=1:NiterSkew
        [im skip] = wmodskew2(im,targetSkew,W.scale{nsc},W.sum{nsc},1,epPixSkew(nsc),nsc);
        im = wmodmean2(im,targetMeans,W.scale{nsc},preCalcInv);
        if opts.debugging
          for iw=1:nW(nsc)
            w = W.scale{nsc}(:,iw);
            skewSNR(iw,niterw) = (targetSkew(iw)-wskew2(im,w))^2;
          end
          axes(ax(5)); plot(skewSNR'); drawnow;
          axes(ax(2)); imagesc(reshape(im,sqrt(length(im)),sqrt(length(im)))); axis image off; drawnow;
        end
      end
      
      for niterw=1:NiterKurt
        [im skip] = wmodkurt2(im,targetKurt,W.scale{nsc},W.sum{nsc},1,epPixKurt(nsc),nsc);
        im = wmodmean2(im,targetMeans,W.scale{nsc},preCalcInv);
        if opts.debugging
          for iw=1:nW(nsc)
            w = W.scale{nsc}(:,iw);
            kurtSNR(iw,niterw) = (targetKurt(iw)-wkurt2(im,w))^2;
          end
          axes(ax(6)); plot(kurtSNR'); drawnow;
          axes(ax(2)); imagesc(reshape(im,sqrt(length(im)),sqrt(length(im)))); axis image off; drawnow;
        end
      end
      
    end
    
    im = reshape(im,pind(nband,1),pind(nband,2));
    
    im = real(im);
    im = im.*W.full{nsc} + oim.scale{nsc}.*(1-W.full{nsc});
  end
  
  % adjust HPR
  clear acorrSNR
  ind = pyrBandIndices(pind,1);
  ch = vector(pyr(ind));
  ch = ch * sqrt(var2(oim.HPR)/var2(ch));
  for iw=1:nW(nsc)
    thisNa = W.Na{nsc}(iw);
    le = floor((thisNa-1)/2);
    targetAcorr{iw} = squeeze(acr0.vHPR.mask{iw});
  end
  targetMHPR = (W.scale{1}'*vector(oim.HPR))';
  preCalcInv = pinv(W.scale{1}'*W.scale{1});
  for niterw=1:10
    ch = wmodacorr2(ch,targetAcorr,W.scaleSq{1},W.scaleSqrt{1},epResVar(1),1,W.Na{1},W.ind{1},W.sz{1},W.scale{1});
    ch = wmodmean2(ch,targetMHPR,W.scale{1},preCalcInv);
    if opts.debugging
      for iw=1:nW(1)
        w = W.scale{1}(:,iw);
        wSq = W.scaleSq{1}(:,:,iw);
        wSqrt = W.scaleSqrt{1}(:,:,iw);
        wind = W.ind{1}(:,iw);
        na = W.Na{1}(iw);
        tmptarget = targetAcorr{iw};
        tmpAcorr = wacorr2(reshape(ch,size(wSq,1),size(wSq,2)),wSq,wSqrt,wind,na,na,0);
        acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
        meanSNR(iw,niterw) = abs(wmean2(ch,w) - targetMeans(iw));
      end
      axes(ax(7)); plot(acorrSNR');
      axes(ax(2)); imagesc(reshape(real(ch),sqrt(length(ch)),sqrt(length(ch))));
      axis image off; colormap gray;
      title(sprintf('lowpass variance, scale %g, iteration %g/%g',nsc,niterw,NiterperW(nsc)));
      drawnow;
    end
  end
  
  pyr(ind) = ch;
  newHPR = reconSFpyr(real(pyr),pind,[0]);
  newHPR = newHPR.*W.full{1} + reshape(oim.HPR,Ny,Nx).*(1-W.full{1});
  im = im + newHPR;
  
  % pixel statistics
  clear meanSNR
  clear varSNR
  clear skewSNR
  clear kurtSNR
  clear targetMeans
  clear targetVars
  im = vector(im);
  
  targetVars = var0;
  targetSkew = skew0;
  targetKurt = kurt0;
  targetMeans = mean0;
  preCalcInv = pinv(W.scale{1}'*W.scale{1});
  
  for niterw=1:20
    
    im = wmodvar2(im,targetVars,W.scale{1},W.sum{1},1,epPixVar);
    im = wmodmean2(im,targetMeans,W.scale{1},preCalcInv);
    
    if opts.debugging
      for iw=1:nW(1)
        w = W.scale{1}(:,iw);
        meanSNR(iw,niterw) = (wmean2(im,w) - targetMeans(iw))^2;
        varSNR(iw,niterw) = (targetVars(iw) - wvar2(im,w))^2;
      end
      axes(ax(3)); plot(meanSNR');
      axes(ax(4)); plot(varSNR');
      axes(ax(2)); imagesc(reshape(real(im),sqrt(length(im)),sqrt(length(im))));
      axis image off; colormap gray; drawnow;
      title(sprintf('pixel mean and var, iteration %g/%g',niterw,NiterperW(1)));
      drawnow;
    end
  end

  for niterw=1:NiterSkew
    [im skip] = wmodskew2(im,targetSkew,W.scale{1},W.sum{nsc},1,epPixSkew(nsc),1);
    im = wmodmean2(im,targetMeans,W.scale{1},preCalcInv);
    if opts.debugging
      for iw=1:nW(1)
        w = W.scale{1}(:,iw);
        skewSNR(iw,niterw) = (targetSkew(iw) - wskew2(im,w))^2;
      end
      
      axes(ax(5)); plot(skewSNR');
      axes(ax(2)); imagesc(reshape(real(im),sqrt(length(im)),sqrt(length(im))));
      axis image off; colormap gray; drawnow;
    end
  end
  
  for niterw=1:NiterKurt
    [im skip] = wmodkurt2(im,targetKurt,W.scale{1},W.sum{nsc},1,epPixKurt(nsc),1);
    im = wmodmean2(im,targetMeans,W.scale{1},preCalcInv);
    if opts.debugging
      for iw=1:nW(1)
        w = W.scale{1}(:,iw);
        kurtSNR(iw,niterw) = (targetKurt(iw) - wkurt2(im,w))^2;
      end
      
      axes(ax(6)); plot(kurtSNR');
      axes(ax(2)); imagesc(reshape(real(im),sqrt(length(im)),sqrt(length(im))));
      axis image off; colormap gray; drawnow;
    end
  end
  
  % clip to range
  im(im>max(mx0)) = max(mx0);
  im(im<min(mn0)) = min(mn0);
  
  im = reshape(im,pind(1,1),pind(1,2));
  tmp = prev_im;
  prev_im=im;
  change = im - tmp;
  alpha = 0.8;
  im = im + alpha*(change);
  
  if opts.verbose; T = textWaitbar(T,niter/opts.nIters); end

  if opts.printing
    imwrite(uint8(im),fullfile(opts.outputPath,strcat(opts.saveFile,sprintf('_iter_%g',niter),'.png')));
  end

  if opts.debugging
    axes(ax(2));
    imagesc(im); axis image off; title(sprintf('iteration %g/%g',niter,opts.nIters));
    axes(ax(1));
    imagesc(change); drawnow; title(sprintf('range is [%g %g]',max(vector(change)),min(vector(change)))); axis image off;
    
    % compute all statistics on current image
    [tmpparams] = metamerAnalysis(opts,m,im);
    
    % compare all statistics to desired ones
    for iw = 1:m.scale{1}.nMasks
      statg0tmp = tmpparams.synthesis.pixelStats(:,iw);
      margl = [mean0(iw) var0(iw) skew0(iw) kurt0(iw)];
      margltmp = [statg0tmp(1) statg0tmp(2) statg0tmp(3) statg0tmp(4)];
      params.snr.margl(niter,iw) = snr(margl,margltmp-margl);
    end
    
    for nsc=Nsc+1:-1:1
      for iw = 1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.autoCorrReal.scale{nsc}.mask{iw};
        signal = acr0.scale{nsc}.mask{iw};
        params.snr.autoCorrReal(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    for nsc=Nsc:-1:1
      for nor=1:Nor
        for iw=1:m.scale{nsc}.nMasks
          tmpSignal = tmpparams.synthesis.autoCorrMag.scale{nsc}.ori{nor}.mask{iw};
          signal = ace0.scale{nsc}.ori{nor}.mask{iw};
          params.snr.autoCorrMag(niter,iw,nsc,nor) = snr(signal,signal - tmpSignal);
        end
      end
    end
    
    for nsc=Nsc:-1:1
      for iw = 1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.cousinMagCorr.scale{nsc}.mask{iw};
        signal = C0.scale{nsc}.mask{iw};
        params.snr.cousinMagCorr(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    for nsc=Nsc-1:-1:1
      for iw = 1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.parentMagCorr.scale{nsc}.mask{iw};
        signal = Cx0.scale{nsc}.mask{iw};
        params.snr.parentMagCorr(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    for nsc=Nsc:-1:1
      for iw=1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.parentRealCorr.scale{nsc}.mask{iw};
        signal = Crx0.scale{nsc}.mask{iw};
        params.snr.parentRealCorr(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    for nsc=Nsc:-1:1
      for iw=1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.cousinRealCorr.scale{nsc}.mask{iw};
        signal = Cr0.scale{nsc}.mask{iw};
        params.snr.cousinRealCorr(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    
    for iband=1:size(oimpind,1);
      for iw=1:size(tmpparams.synthesis.magMeans.band{iband},1)
        tmpSignal = tmpparams.synthesis.magMeans.band{iband}(iw);
        signal = magMeans0.band{iband}(iw);
        params.snr.magMeans(niter,nband,iw) = snr(signal,signal - tmpSignal);
      end
    end
    
    sz = size(params.snr.autoCorrReal);
    params.snr.autoCorrRealPlot = reshape(params.snr.autoCorrReal,niter,sz(2)*sz(3));
    sz = size(params.snr.autoCorrMag);
    params.snr.autoCorrMagPlot = reshape(params.snr.autoCorrMag,niter,sz(2)*sz(3)*sz(4));
    sz = size(params.snr.magMeans);
    if numel(sz) < 3
      sz(3) = 1;
    end
    params.snr.magMeansPlot = reshape(params.snr.magMeans,niter,sz(2)*sz(3));
    sz = size(params.snr.cousinMagCorr);
    params.snr.cousinMagCorrPlot = reshape(params.snr.cousinMagCorr,niter,sz(2)*sz(3));
    sz = size(params.snr.parentMagCorr);
    params.snr.parentMagCorrPlot = reshape(params.snr.parentMagCorr,niter,sz(2)*sz(3));
    sz = size(params.snr.parentRealCorr);
    params.snr.parentRealCorrPlot = reshape(params.snr.parentRealCorr,niter,sz(2)*sz(3));
    sz = size(params.snr.cousinRealCorr);
    params.snr.cousinRealCorrPlot = reshape(params.snr.cousinRealCorr,niter,sz(2)*sz(3));
    
    axes(ax(3)); plot(params.snr.margl); title('pixel mrgls');
    axes(ax(4)); plot(params.snr.magMeansPlot); title('mag means');
    axes(ax(5)); plot(params.snr.autoCorrRealPlot); title('autocorr real');
    axes(ax(6)); plot(params.snr.autoCorrMagPlot); title('autocorr mag');
    axes(ax(7)); plot(params.snr.cousinMagCorrPlot); title('cousin mag corr');
    axes(ax(8)); plot(params.snr.parentMagCorrPlot); title('parent mag corr');
    axes(ax(9)); plot(params.snr.cousinRealCorrPlot); title('cousin real corr');
    axes(ax(10)); plot(params.snr.parentRealCorrPlot); title('parent real corr');
    drawnow;
    
  end

end



