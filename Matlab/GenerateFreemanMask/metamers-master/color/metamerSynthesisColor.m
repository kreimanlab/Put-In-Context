function im = metamerSynthesisColor(params,seed,m,opts)

%
%-----------------------------------------
% metamerSynthesisColor(params,seed,m,opts)
%
% generates an image matched to a set of
% statistical parameters computed within
% a set of tiling regions defined by window functions
% (see metamerParams.m and metamerSynthesis.m)
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
  
  % set(0,'currentfigure',H1) % if using multiple figures
  ax(1) = axes('pos',[.01 .5 .48 .48]);
  ax(2) = axes('pos',[.5 .5 .48 .48]);
  ax(3) = axes('pos',[.05 .05 .1 .4]);
  ax(4) = axes('pos',[.17 .05 .1 .4]);
  ax(5) = axes('pos',[.29 .05 .1 .4]);
  ax(6) = axes('pos',[.41 .05 .1 .4]);
  ax(7) = axes('pos',[.53 .05 .1 .4]);
  ax(8) = axes('pos',[.65 .05 .1 .4]);
  ax(9) = axes('pos',[.77 .05 .1 .4]);
  ax(10) = axes('pos',[.89 .05 .1 .4]);
end

if opts.verbose; fprintf('(metamerSynthesisColor) starting...\n'); end

% Make normalized mask matrices
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
tmp = params.pixelStats;
for iw = 1:m.scale{1}.nMasks
  statg0 = squeeze(tmp(:,iw,:));
  mean0(:,iw) = statg0(1,:); var0(:,iw) =  statg0(2,:);
  skew0(:,iw) =  statg0(3,:); kurt0(:,iw) =  statg0(4,:);
  mn0(:,iw) =  statg0(5,:);  mx0(:,iw) = statg0(6,:);
end
clear tmp
skew0 = clip(skew0,-4,4);
kurt0 = clip(kurt0,0,3);
tmp = params.pixelStatsPCA;
for iw = 1:m.scale{1}.nMasks
  statgP = squeeze(tmp(:,iw,:));
  meanP(:,iw) = statgP(1,:); varP(:,iw) =  statgP(2,:);
  skewP(:,iw) =  statgP(3,:); kurtP(:,iw) =  statgP(4,:);
  mnP(:,iw) =  statgP(5,:);  mxP(:,iw) = statgP(6,:);
end
skewP = clip(skewP,-4,4);
kurtP = clip(kurtP,0,3);
skew0p = params.LPskew;
kurt0p = params.LPkurt;
vHPR0 = params.varianceHPR;
vHPR0full = params.varianceHPRfull;
acr0 = params.autoCorrReal;
ace0 = params.autoCorrMag;
magMeans0 = params.magMeans;
C0 = params.cousinMagCorr;
Cr0 = params.cousinRealCorr;
Cx0 = params.parentMagCorr;
Crx0 = params.parentRealCorr;
Cclr0 = params.colorCorr;
Nclr = size(Cclr0,1);
Nsc = length(ace0.scale);
Nor = length(ace0.scale{1}.ori);
for nsc=1:Nsc+1
  nW(nsc) = m.scale{nsc}.nMasks;
  for clr=1:Nclr
    skew0p.scale{nsc}.clr{clr} = clip(skew0p.scale{nsc}.clr{clr},-4,4);
    kurt0p.scale{nsc}.clr{clr} = clip(kurt0p.scale{nsc}.clr{clr},0,3);
  end
end


%% create original PCAed image at each scale
oim.full = params.oim;
[V D] = eig(Cclr0);
Ny = size(oim.full,1);
Nx = size(oim.full,2);
oimPCA = oim.full;
oimPCA = reshape(oimPCA,Ny*Nx,Nclr);
oimPCA = oimPCA - ones(Ny*Nx,Nclr)*diag(mean(oimPCA));
oimPCA = oimPCA*V*pinv(sqrt(D));
oimPCA = reshape(oimPCA,Ny,Nx,Nclr);

for clr = 1:Nclr
  
  [oimpyr, oimpind] = buildSCFpyr(oimPCA(:,:,clr),Nsc,Nor-1);
  roimpyr = real(oimpyr);
  aoimpyr = abs(oimpyr);
  
  nband = size(oimpind,1);
  ch = pyrBand(oimpyr,oimpind,nband);
  [mpyr,mpind] = buildSFpyr(real(ch),0,0);
  im = pyrBand(mpyr,mpind,2);
  oim.clr{clr}.scale{Nsc+1} = im;%.*rMask.scale{Nsc+1}.mask;
  
  for nsc=Nsc:-1:1
    for nor=1:Nor
      oim.mag.clr{clr}.scale{nsc}.or{nor} = pyrBand(aoimpyr,oimpind,nor + (nsc-1)*Nor+1);
    end
  end
  
  for nsc=Nsc:-1:1
    bandNums = [1:Nor] + (nsc-1)*Nor+1;  %ori bands only
    ind1 = pyrBandIndices(oimpind, bandNums(1));
    indN = pyrBandIndices(oimpind, bandNums(Nor));
    bandInds = [ind1(1):indN(length(indN))];
    fakePind = [oimpind(bandNums(1),:);oimpind(bandNums(1):bandNums(Nor)+1,:)];
    fakePyr = [zeros(prod(fakePind(1,:)),1);...
      roimpyr(bandInds); zeros(prod(fakePind(size(fakePind,1),:)),1);];
    ch = reconSFpyr(fakePyr, fakePind, [1]);     % recon ori bands only
    im = real(expand(im,2))/4;
    im = im + ch;
    oim.clr{clr}.scale{nsc} = im;%.*rMask.scale{nsc}.mask;
  end
  oim.clr{clr}.HPR = oimpyr(pyrBandIndices(oimpind,1));
end


% Create noise image (or use starting image)


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

if (length(seed) <= 3 )
  Ny = seedSz(1);
  Nx = seedSz(2);
  for clr = 1:Nclr
    im(:,:,clr) = randn(Ny,Nx);
  end
  im = reshape(im,Ny*Nx,Nclr);
  im = adjustCorr1s(im,Cclr0);
  im = real(im);
  im = im + ones(Ny*Nx,Nclr)*diag(mean(mean0,2));
  im = reshape(im,Ny,Nx,Nclr);
else
  im = seed;
end

prev_im=im;

if opts.printing
  imwrite(uint8(oim.full),fullfile(opts.outputPath,strcat(opts.saveFile,sprintf('_original'),'.png')));
  imwrite(uint8(im),fullfile(opts.outputPath,strcat(opts.saveFile,sprintf('_iter_0'),'.png')));
end

if opts.verbose; T = textWaitbar('(metamerSynthesis) doing iterations'); end

% main loop
for niter=1:opts.nIters
  
  % get PCA color components
  
  im = reshape(im,Ny*Nx,Nclr);
  im = im - ones(Ny*Nx,Nclr)*diag(mean(im));
  im = im*V*pinv(sqrt(D));
  im = reshape(im,Ny,Nx,Nclr);
  
  %% Build the steerable pyramid
  
  for clr = 1:Nclr
    [pyr(:,clr),pind] = buildSCFpyr(im(:,:,clr),Nsc,Nor-1);
  end
  
  apyr = abs(pyr);
  
  if ( any(vector(mod(pind,4))) )
    error('Algorithm will fail: band dimensions are not all multiples of 4!');
  end
  
  % adjust cross correlations across color channels within low band
  nband = size(pind,1);
  
  if 1
    [N1y, N1x] = size(pyrLow(pyr(:,1),pind));
    N1y = 2*N1y; N1x = 2*N1x;
    LPRcross = zeros(N1y*N1x,5,Nclr);
    
    for clr=1:Nclr
      tmp = real(expand(pyrLow(pyr(:,clr),pind),2))/4;
      LPRcross(:,:,clr) = [vector(tmp), vector(shift(tmp,[0 2])), vector(shift(tmp,[0 -2])), ...
        vector(shift(tmp,[2 0])), vector(shift(tmp,[-2 0]))];
    end
    
    Nrp = size(LPRcross,2)*Nclr;
    LPRcross = reshape(LPRcross,[N1y*N1x Nrp]);
    LPRcrossnew = zeros(size(LPRcross));
    
    for iw = 1:nW(Nsc)
      w = W.scale{Nsc}(:,iw);
      sqw = sqrt(w);
      
      for inrp=1:Nrp
        tmpmean(inrp) = wmean2(LPRcross(:,inrp),w);
        LPRcrosstmp(:,inrp) = (LPRcross(:,inrp) - tmpmean(inrp)).*sqw;
      end
      [LPRcrosstmp] = adjustCorr1s(LPRcrosstmp, Cr0.scale{Nsc+1}.mask{iw}(1:Nrp,1:Nrp),2);
      LPRcrosstmp = real(LPRcrosstmp);
      
      undow = zeros(size(w));
      undow(sqw>0.0001) = 1./sqw(sqw>0.0001);
      for inrp=1:Nrp
        LPRcrosstmp(:,inrp) = LPRcrosstmp(:,inrp).*undow + tmpmean(inrp);
        LPRcrosstmp(:,inrp) = LPRcrosstmp(:,inrp).*W.scaleUnnorm{Nsc}(:,iw);
      end
      LPRcrossnew = LPRcrossnew + LPRcrosstmp;
      clear cousinstmp
      clear tmpmean
      clear LPRcrosstmp
    end
    
    LPRcross = reshape(LPRcrossnew,[N1y*N1x 5 Nclr]);
    indices = pyrBandIndices(pind,nband);
    
    for clr=1:Nclr
      LPRcross(:,:,clr) = [LPRcross(:,1,clr), ...
        vector(shift(reshape(LPRcross(:,2,clr),N1y,N1x),[0 -2])),...
        vector(shift(reshape(LPRcross(:,3,clr),N1y,N1x),[0 2])), ...
        vector(shift(reshape(LPRcross(:,4,clr),N1y,N1x),[-2 0])),...
        vector(shift(reshape(LPRcross(:,5,clr),N1y,N1x),[2 0]))];
      aux = mean(LPRcross(:,:,clr),2);
      aux = reshape(aux,N1y,N1x);
      pyr(indices,clr) = 4*vector(real(shrink(aux,2)));
    end
  end
  
  for clr=1:Nclr
    
    
    ch = pyrBand(pyr(:,clr),pind,nband);
    [N1y N1x] = size(ch);
    [mpyr,mpind] = buildSFpyr(real(ch),0,0);
    im(1:N1y,1:N1x,clr) = pyrBand(mpyr,mpind,2);
    
    im(1:N1y,1:N1x,clr) = im(1:N1y,1:N1x,clr).*W.full{Nsc+1} + oim.clr{clr}.scale{Nsc+1}.*(1-W.full{Nsc+1});
    
    % adjust mean and variance of lowband for each mask
    clear meanSNR
    clear varSNR
    clear skewSNR
    clear kurtSNR
    clear acorrSNR
    clear targetMeans
    clear targetVars
    
    tmpim = vector(im(1:N1y,1:N1x,clr));
    
    for iw=1:nW(Nsc+1)
      thisNa = W.Na{Nsc+1}(iw);
      le = floor((thisNa-1)/2);
      targetVars(iw) = acr0.scale{Nsc+1}.clr{clr}.mask{iw}(le+1:le+1,le+1:le+1);
      targetAcorr{iw} = squeeze(acr0.scale{Nsc+1}.clr{clr}.mask{iw});
    end
    
    targetMeans = (W.scale{Nsc+1}'*vector(oim.clr{clr}.scale{Nsc+1}))';
    %targetMeans = (W.scale{Nsc+1}'*vector(tmpim))';
    targetSkew = skew0p.scale{Nsc+1}.clr{clr};
    targetKurt = kurt0p.scale{Nsc+1}.clr{clr};
    preCalcInv = pinv(W.scale{Nsc+1}'*W.scale{Nsc+1});
    
    for niterw=1:NiterperW(Nsc+1)
      
      tmpim = wmodacorr2(tmpim,targetAcorr,W.scaleSq{Nsc+1},W.scaleSqrt{Nsc+1},epLowVar,1,W.Na{Nsc+1},W.ind{Nsc+1},W.sz{Nsc+1},W.scale{Nsc+1});
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{Nsc+1},preCalcInv);
      
      if opts.debugging
        for iw=1:nW(Nsc+1)
          w = W.scale{Nsc+1}(:,iw);
          wSq = W.scaleSq{Nsc+1}(:,:,iw);
          wSqrt = W.scaleSqrt{Nsc+1}(:,:,iw);
          wind = W.ind{Nsc+1}(:,iw);
          na = W.Na{Nsc+1}(iw);
          meanSNR(iw,niterw) = abs(targetMeans(iw)-wmean2(tmpim,w));
          tmptarget = targetAcorr{iw};
          tmpAcorr = wacorr2(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))),wSq,wSqrt,wind,na,0);
          acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
        end
        axes(ax(7)); plot(acorrSNR');
        axes(ax(2)); imagesc(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))));
        axis image off; colormap gray;
        title(sprintf('adjusting lowband variance, %g/%g',niterw,NiterperW(Nsc+1)));
        drawnow;
      end
    end
    
    for niterw=1:NiterKurt
      tmpim = wmodkurt2(tmpim,targetKurt,W.scale{Nsc+1},W.sum{Nsc+1},1,epPixKurt(Nsc+1),Nsc+1);
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{Nsc+1},preCalcInv);
      if opts.debugging
        for iw=1:nW(Nsc+1)
          w = W.scale{Nsc+1}(:,iw);
          kurtSNR(iw,niterw) = (targetKurt(iw)-wkurt2(tmpim,w))^2;
        end
        
        axes(ax(6)); plot(kurtSNR'); drawnow;
        axes(ax(2)); imagesc(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))));
      end
    end
  end
  im(1:N1y,1:N1x,clr) = reshape(tmpim,N1y,N1x);
  clear tmpim
  
  
  % coarse-to-fine loop
  for nsc=Nsc:-1:1
    
    firstBnum = (nsc-1)*Nor+2;
    cousinSz = prod(pind(firstBnum,:));
    ind = pyrBandIndices(pind,firstBnum);
    cousinInd = ind(1) + [0:Nor*cousinSz-1];
    
    cousins = zeros(cousinSz,Nor,Nclr);
    rcousins = zeros(cousinSz,Nor,Nclr);
    parents = zeros(cousinSz,Nor,Nclr);
    rparents = zeros(cousinSz,2*Nor,Nclr);
    
    for clr=1:Nclr
      if nsc < Nsc
        for nor = 1:Nor
          nband = (nsc+1-1)*Nor + nor + 1;
          tmp = expand(pyrBand(pyr(:,clr),pind,nband),2)/4;
          rtmp = real(tmp); itmp = imag(tmp);
          tmp = sqrt(rtmp.^2 + itmp.^2) .* exp(2 * sqrt(-1) * atan2(rtmp,itmp));
          rparents(:,nor,clr) = vector(real(tmp));
          rparents(:,Nor+nor,clr) = vector(imag(tmp));
          tmp = abs(tmp);
          parents(:,nor,clr) = vector(tmp - mean2(tmp));
        end
      else
        tmp = real(expand(pyrLow(pyr(:,clr),pind),2))/4;
        rparents(:,1:5,clr) = [vector(tmp),...
          vector(shift(tmp,[0 2])), vector(shift(tmp,[0 -2])), ...
          vector(shift(tmp,[2 0])), vector(shift(tmp,[-2 0]))];
        %rparents = [];
        parents = [];
      end
      
      cousins(:,:,clr) = reshape(apyr(cousinInd,clr), [cousinSz Nor]);
      rcousins(:,:,clr) = reshape(real(pyr(cousinInd,clr)), [cousinSz Nor]);
      
    end
    
    nc = prod(size(cousins))/cousinSz;
    np = prod(size(parents))/cousinSz;
    
    cousins = reshape(cousins,[cousinSz nc]);
    parents = reshape(parents,[cousinSz np]);
    
    cousinsnew = zeros(size(cousins));
    
    for iw = 1:nW(nsc)
      w = W.scale{nsc}(:,iw);
      sqw = sqrt(w);
      
      if np == 0 % if we're on the coarsest scale
        
        for inc=1:nc
          tmpmean(inc) = wmean2(cousins(:,inc),w);
          cousinstmp(:,inc) = (cousins(:,inc) - tmpmean(inc)).*sqw;
        end
        [cousinstmp] = adjustCorr1s(cousinstmp, C0.scale{nsc}.mask{iw}(:,:),2);
        cousinstmp = real(cousinstmp);
        
      else % otherwise include parents
        
        for inc=1:nc
          tmpmean(inc) = wmean2(cousins(:,inc),w);
          cousinstmp(:,inc) = (cousins(:,inc) - tmpmean(inc)).*sqw;
        end
        for inp=1:np
          parentstmp(:,inp) = (parents(:,inp) - wmean2(parents(:,inp),w)).*sqw;
        end
        
        cousinstmp = adjustCorr2s(cousinstmp, C0.scale{nsc}.mask{iw}(:,:), parentstmp,Cx0.scale{nsc}.mask{iw}(:,:), 3);
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
    
    cousins = reshape(cousinsnew,cousinSz,Nor,Nclr);
    
    
    for clr = 1:Nclr
      
      cou = cousins(:,:,clr);
      apyr(cousinInd,clr) = vector(cou);
      
      for nor = 1:Nor
        clear meanSNR
        clear acorrSNR
        clear targetMeans
        clear targetVars
        clear targetAcorr
        clear ch
        
        nband = (nsc-1)*Nor+nor+1;
        ch = pyrBand(apyr(:,clr),pind,nband);
        [Nly Nlx] = size(ch);
        
        % add in original magnitudes
        ch = ch.*W.full{nsc} + oim.mag.clr{clr}.scale{nsc}.or{nor}.*(1-W.full{nsc});
        
        ch = vector(ch);
        
        for iw=1:nW(nsc)
          thisNa = W.Na{nsc}(iw);
          le = floor((thisNa-1)/2);
          targetVars(iw) = ace0.scale{nsc}.ori{nor}.clr{clr}.mask{iw}(le+1:le+1,le+1:le+1);
          targetAcorr{iw} = squeeze(ace0.scale{nsc}.ori{nor}.clr{clr}.mask{iw});
        end
        
        targetMeans = magMeans0.clr{clr}.band{nband}';
        
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
              tmptarget = targetAcorr{iw};
              tmpAcorr = wacorr2(reshape(ch,sqrt(length(ch)),sqrt(length(ch))),wSq,wSqrt,wind,na,0);
              acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
              
            end
            axes(ax(8)); plot(acorrSNR');
            %axes(ax(5)); plot(meanSNR');
            axes(ax(2)); imagesc(reshape(ch,sqrt(length(ch)),sqrt(length(ch))));
            colormap gray; axis image off;
            title(sprintf('adjusting mag mean and variance, scale %g, ori %g, iteration %g/%g',nsc,nor,niterw,NiterperW(nsc)));
            drawnow;
          end
        end
        
        ch = real(ch);
        ind = pyrBandIndices(pind,nband);
        apyr(ind,clr) = ch;
        mag = apyr(ind,clr);
        mag = mag.*(mag>0);
        pyr(ind,clr) = pyr(ind,clr) .* (mag./(abs(pyr(ind,clr))+(abs(pyr(ind,clr))<eps)));
        
      end
      
      rcousins(:,:,clr) = reshape(real(pyr(cousinInd,clr)), [cousinSz Nor]);
      
    end
    
    
    % adjust cross-correlation of real and imaginary parts at other orientations/scales
    
    if nsc == Nsc
      rparents = rparents(:,1:5,:);
    end
    
    if 0
      Nrp = size(rparents,2);
      Nrc = size(rcousins,2);
      
      rcousinsnew = zeros(size(rcousins));
      
      for clr=1:Nclr
        rcousinsClr = rcousins(:,:,clr);
        rparentsClr = rparents(:,:,clr);
        for iw=1:nW(nsc)
          w = W.scale{nsc}(:,iw);
          sqw = sqrt(w);
          undow = zeros(size(w));
          undow(sqw>0.0001) = 1./sqw(sqw>0.0001);
          for nrc = 1:Nrc
            tmpmean(nrc) = wmean2(rcousinsClr(:,nrc),w);
            rcousinstmp(:,nrc) = (rcousinsClr(:,nrc) - tmpmean(nrc)).*sqw;
          end
          for nrp=1:Nrp
            rparentstmp(:,nrp) = (rparentsClr(:,nrp) - wmean2(rparentsClr(:,nrp),w)).*sqw;
          end
          rcousinstmp = adjustCorr2s(rcousinstmp,Cr0.scale{nsc}.clr{clr}.mask{iw}(1:Nrc,1:Nrc),...
            rparentstmp,Crx0.scale{nsc}.clr{clr}.mask{iw}(1:Nrc,1:Nrp),3);
          for nrc = 1:Nrc
            rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*undow + tmpmean(nrc);
            rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*W.scaleUnnorm{nsc}(:,iw);
          end
          rcousinsnew(:,:,clr) = rcousinsnew(:,:,clr) + rcousinstmp;
        end
        clear rparentstmp
        clear rcousinstmp
        clear tmpmean
      end
      
      rcousins = real(rcousinsnew);
      clear rcousinsnew
    end
    
    
    Nrp = prod(size(rparents))/cousinSz;
    Nrc = prod(size(rcousins))/cousinSz;
    rparents = reshape(rparents,[cousinSz Nrp]);
    rcousins = reshape(rcousins,[cousinSz Nrc]);
    
    goodinds = find((W.sum{nsc}/numel(im))>0.001); %borrowed from B&W code
    
    rcousinsnew = zeros(size(rcousins));
    for iw = 1:nW(nsc)
      if sum(goodinds==iw)
        w = W.scale{nsc}(:,iw);
        sqw = sqrt(w);
        undow = zeros(size(w));
        undow(sqw>0.0001) = 1./sqw(sqw>0.0001);
        for nrc = 1:Nrc
          tmpmean(nrc) = wmean2(rcousins(:,nrc),w);
          rcousinstmp(:,nrc) = (rcousins(:,nrc) - tmpmean(nrc)).*sqw;
        end
        for nrp=1:Nrp
          rparentstmp(:,nrp) = (rparents(:,nrp) - wmean2(rparents(:,nrp),w)).*sqw;
        end
        %rcousinstmp = adjustCorr1s(rcousinstmp,Cr0.scale{nsc}.mask{iw}(1:Nrc,1:Nrc),2);
        rcousinstmp = adjustCorr2s(rcousinstmp,Cr0.scale{nsc}.mask{iw}(1:Nrc,1:Nrc),...
          rparentstmp,Crx0.scale{nsc}.mask{iw}(1:Nrc,1:Nrp),3);
        for nrc = 1:Nrc
          rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*undow + tmpmean(nrc);
          rcousinstmp(:,nrc) = rcousinstmp(:,nrc).*W.scaleUnnorm{nsc}(:,iw);
        end
        rcousinsnew = rcousinsnew + rcousinstmp;
      else
        for nrc = 1:Nrc
          rcousinsnew(:,nrc) = rcousinsnew(:,nrc) + rcousins(:,nrc).*W.scaleUnnorm{nsc}(:,iw);
        end
      end
    end
    clear rparentstmp
    clear rcousinstmp
    clear tmpmean
    
    
    rcousins = reshape(rcousinsnew, cousinSz, Nor, Nclr);
    
    
    for clr = 1:Nclr
      
      pyr(cousinInd,clr) = vector(real(rcousins(:,:,clr)));
      
      %% Re-create analytic subbands
      dims = pind(firstBnum,:);
      ctr = ceil((dims+0.5)/2);
      ang = mkAngle(dims, 0, ctr);
      ang(ctr(1),ctr(2)) = -pi/2;
      for nor = 1:Nor,
        nband = (nsc-1)*Nor+nor+1;
        ind = pyrBandIndices(pind,nband);
        ch = pyrBand(pyr(:,clr), pind, nband);
        ang0 = pi*(nor-1)/Nor;
        xang = mod(ang-ang0+pi, 2*pi) - pi;
        amask = 2*(abs(xang) < pi/2) + (abs(xang) == pi/2);
        amask(ctr(1),ctr(2)) = 1;
        amask(:,1) = 1;
        amask(1,:) = 1;
        amask = fftshift(amask);
        ch = ifft2(amask.*fft2(ch));	% "Analytic" version
        pyr(ind,clr) = vector(ch);
      end
      
      % Combine ori bands
      bandNums = [1:Nor] + (nsc-1)*Nor+1;  %ori bands only
      ind1 = pyrBandIndices(pind, bandNums(1));
      indN = pyrBandIndices(pind, bandNums(Nor));
      bandInds = [ind1(1):indN(length(indN))];
      %% Make fake pyramid, containing dummy hi, ori, lo
      fakePind = pind([bandNums(1), bandNums, bandNums(Nor)+1],:);
      fakePyr = [zeros(prod(fakePind(1,:)),1);...
        real(pyr(bandInds,clr)); zeros(prod(fakePind(size(fakePind,1),:)),1)];
      ch = reconSFpyr(fakePyr, fakePind, [1]);     % recon ori bands only
      [N1y, N1x] = size(ch);
      im(1:N1y,1:N1x,clr) = real(expand(im(1:N1y/2,1:N1x/2,clr),2))/4;
      im(1:N1y,1:N1x,clr) = im(1:N1y,1:N1x,clr) + ch;
      im(1:N1y,1:N1x,clr) = im(1:N1y,1:N1x,clr).*W.full{nsc} + oim.clr{clr}.scale{nsc}.*(1-W.full{nsc});
      
      
      % fix real autocorrelation of lowpass suband
      clear meanSNR
      clear acorrSNR
      clear skewSNR
      clear kurtSNR
      clear targetMeans
      clear targetVars
      
      tmpim = im(1:N1y,1:N1x,clr);
      [Nly Nlx] = size(tmpim);
      
      tmpim = vector(tmpim);
      
      for iw=1:nW(nsc)
        thisNa = W.Na{nsc}(iw);
        le = floor((thisNa-1)/2);
        targetVars(iw) = acr0.scale{nsc}.clr{clr}.mask{iw}(le+1:le+1,le+1:le+1);
        targetAcorr{iw} = squeeze(acr0.scale{nsc}.clr{clr}.mask{iw});
      end
      
      targetMeans = (W.scale{nsc}'*tmpim)'; % keep mean?
      targetSkew = skew0p.scale{nsc}.clr{clr};
      targetKurt = kurt0p.scale{nsc}.clr{clr};
      preCalcInv = pinv(W.scale{nsc}'*W.scale{nsc});
      
      
      for niterw=1:NiterperW(nsc)
        
        
        tmpim = wmodacorr2(tmpim,targetAcorr,W.scaleSq{nsc},W.scaleSqrt{nsc},epResVar(nsc),1,W.Na{nsc},W.ind{nsc},W.sz{nsc},W.scale{nsc});
        tmpim = wmodmean2(tmpim,targetMeans,W.scale{nsc},preCalcInv);
        
        if opts.debugging
          for iw=1:nW(nsc)
            w = W.scale{nsc}(:,iw);
            wSq = W.scaleSq{nsc}(:,:,iw);
            wSqrt = W.scaleSqrt{nsc}(:,:,iw);
            wind = W.ind{nsc}(:,iw);
            na = W.Na{nsc}(iw);
            tmptarget = targetAcorr{iw};
            tmpAcorr = wacorr2(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))),wSq,wSqrt,wind,na,0);
            acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
            
            meanSNR(iw,niterw) = abs(wmean2(tmpim,w) - targetMeans(iw));
            %skewSNR(iw,niterw) = snr(targetSkew(iw),targetSkew(iw) - wskew2(im,w));
          end
          axes(ax(7)); plot(acorrSNR');
          %axes(ax(6)); plot(skewSNR');
          axes(ax(2)); imagesc(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))));
          axis image off; colormap gray;
          title(sprintf('adjusting lowpass variance, scale %g, iteration %g/%g',nsc,niterw,NiterperW(nsc)));
          drawnow;
        end
        
        
      end
      
      tmpim = real(tmpim);
      
      im(1:N1y,1:N1x,clr) = real(reshape(tmpim,N1y,N1x));
      im(1:N1y,1:N1x,clr) = im(1:N1y,1:N1x,clr).*W.full{nsc} + oim.clr{clr}.scale{nsc}.*(1-W.full{nsc});
      % fix skewness and kurtosis of subband...
    end
  end  % END coarse-to-fine loop
  
  
  % adjust variance in HPR
  
  for clr=1:Nclr
    
    %% Adjust variance in HP, if higher than desired
    clear acorrSNR
    ind = pyrBandIndices(pind,1);
    ch = vector(pyr(ind,clr));
    
    ch = ch * sqrt(var2(oim.clr{clr}.HPR)/var2(ch));
    
    for iw=1:nW(nsc)
      thisNa = W.Na{nsc}(iw);
      le = floor((thisNa-1)/2);
      targetAcorr{iw} = squeeze(acr0.vHPR.clr{clr}.mask{iw});
    end
    
    targetMHPR = (W.scale{1}'*vector(oim.clr{clr}.HPR))';
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
          tmpAcorr = wacorr2(reshape(ch,sqrt(length(ch)),sqrt(length(ch))),wSq,wSqrt,wind,na,0);
          acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
          meanSNR(iw,niterw) = abs(wmean2(ch,w) - targetMeans(iw));
        end
        axes(ax(7)); plot(acorrSNR');
        axes(ax(2)); imagesc(reshape(ch,sqrt(length(ch)),sqrt(length(ch))));
        axis image off; colormap gray;
        title(sprintf('adjusting lowpass variance, scale %g, iteration %g/%g',nsc,niterw,NiterperW(nsc)));
        drawnow;
      end
      
    end
    
    
    pyr(ind,clr) = ch;
    newHPR = reconSFpyr(real(pyr(:,clr)),pind,[0]);
    newHPR = newHPR.*W.full{1} + reshape(oim.clr{clr}.HPR,Ny,Nx).*(1-W.full{1});
    im(:,:,clr) = im(:,:,clr) + newHPR;
    clear newHPR
    
    % Pixel statistics
    clear meanSNR
    clear varSNR
    clear acorrSNR
    clear skewSNR
    clear kurtSNR
    clear targetMeans
    clear targetVars
    
    tmpim = im(:,:,clr);
    tmpim = vector(tmpim);
    
    for iw=1:nW(1)
      targetAcorr{iw} = squeeze(acr0.scale{Nsc+2}.clr{clr}.mask{iw});
    end
    
    targetVars = varP(clr,:);
    targetSkew = skewP(clr,:);
    targetKurt = kurtP(clr,:);
    targetMeans = meanP(clr,:);
    preCalcInv = pinv(W.scale{1}'*W.scale{1});
    
    
    
    for niterw=1:10
      
      %tmpim = wmodvar2(tmpim,targetVars,W.scale{1},1,epPixVar);
      tmpim = wmodacorr2(tmpim,targetAcorr,W.scaleSq{1},W.scaleSqrt{1},epResVar(1),1,W.Na{1},W.ind{1},W.sz{1},W.scale{1});
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{1},preCalcInv);
      
      if opts.debugging
        for iw=1:nW(1)
          w = W.scale{1}(:,iw);
          meanSNR(iw,niterw) = abs(wmean2(tmpim,w) - targetMeans(iw));
          wSq = W.scaleSq{1}(:,:,iw);
          wSqrt = W.scaleSqrt{1}(:,:,iw);
          wind = W.ind{1}(:,iw);
          na = W.Na{1}(iw);
          tmptarget = targetAcorr{iw};
          tmpAcorr = wacorr2(reshape(tmpim,sqrt(length(tmpim)),sqrt(length(tmpim))),wSq,wSqrt,wind,na,0);
          acorrSNR(iw,niterw) = snr(tmptarget,tmptarget - tmpAcorr);
        end
        axes(ax(3)); plot(meanSNR');
        axes(ax(4)); plot(acorrSNR');
        %axes(ax(5)); plot(skewSNR');
        title(sprintf('adjusting pixel mean and variance, iteration %g/%g',niterw,NiterperW(1)));
        drawnow;
      end
      
    end
    im(:,:,clr) = reshape(tmpim,pind(1,1),pind(1,2));
    clear tmpim
    
  end
  
  im = reshape(im,Ny*Nx,Nclr);
  im = im - ones(Ny*Nx,Nclr)*diag(mean(im));
  im = adjustCorr1s(im,eye(Nclr));
  im = real(im);
  im = im * sqrt(D) * V';
  im = im + ones(Ny*Nx,Nclr)*diag(mean(mean0,2));
  im = reshape(im,Ny,Nx,Nclr);
  
  
  for clr=1:Nclr
    
    % Pixel statistics
    clear meanSNR
    clear varSNR
    clear skewSNR
    clear kurtSNR
    clear targetMeans
    clear targetVars
    
    tmpim = im(:,:,clr);
    tmpim = vector(tmpim);
    
    targetVars = var0(clr,:);
    targetSkew = skew0(clr,:);
    targetKurt = kurt0(clr,:);
    targetMeans = mean0(clr,:);
    preCalcInv = pinv(W.scale{1}'*W.scale{1});
    
    for niterw=1:20
      
      tmpim = wmodvar2(tmpim,targetVars,W.scale{1},W.sum{1},1,epPixVar);
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{1},preCalcInv);
      
      if opts.debugging
        for iw=1:nW(1)
          w = W.scale{1}(:,iw);
          meanSNR(iw,niterw) = (wmean2(tmpim,w) - targetMeans(iw))^2;
          varSNR(iw,niterw) = (targetVars(iw) - wvar2(tmpim,w))^2;
          %skewSNR(iw,niterw) = snr(targetSkew(iw),targetSkew(iw) - wskew2(im,w));
        end
        axes(ax(3)); plot(meanSNR');
        axes(ax(4)); plot(varSNR');
        %axes(ax(5)); plot(skewSNR');
        title(sprintf('adjusting pixel mean and variance, iteration %g/%g',niterw,NiterperW(1)));
        drawnow;
      end
    end
    
    for niterw=1:NiterSkew
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{1},preCalcInv);
      tmpim = wmodskew2(tmpim,targetSkew,W.scale{1},W.sum{nsc},1,epPixSkew(nsc),1);
      if opts.debugging
        for iw=1:nW(1)
          w = W.scale{1}(:,iw);
          skewSNR(iw,niterw) = (targetSkew(iw) - wskew2(tmpim,w))^2;
        end
        
        axes(ax(5)); plot(skewSNR');
        axes(ax(2)); imagesc(reshape(real(tmpim),sqrt(length(tmpim)),sqrt(length(tmpim))));
        axis image off; colormap gray; drawnow;
      end
    end
    
    for niterw=1:NiterKurt
      tmpim = wmodmean2(tmpim,targetMeans,W.scale{1},preCalcInv);
      tmpim = wmodkurt2(tmpim,targetKurt,W.scale{1},W.sum{nsc},1,epPixKurt(nsc),1);
      if opts.debugging
        for iw=1:nW(1)
          w = W.scale{1}(:,iw);
          kurtSNR(iw,niterw) = (targetKurt(iw) - wkurt2(tmpim,w))^2;
        end
        
        axes(ax(6)); plot(kurtSNR');
        axes(ax(2)); imagesc(reshape(real(tmpim),sqrt(length(tmpim)),sqrt(length(tmpim))));
        axis image off; colormap gray; drawnow;
      end
    end
    
    im(:,:,clr) = reshape(tmpim,pind(1,1),pind(1,2));
    clear tmpim
  end
  
  
  
  for clr=1:Nclr
    im(:,:,clr) = clip(im(:,:,clr),min(mn0(clr,:)),max(mx0(clr,:)));
    im(:,:,clr) = im(:,:,clr).*W.full{1} + oim.full(:,:,clr).*(1-W.full{1});
  end
  
  
  
  
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
    imagesc(uint8(im)); axis image off; title(sprintf('iteration %g/%g',niter,Niter));
    axes(ax(1));
    Mach = max(vector(change));
    Mich = min(vector(change));
    imagesc(uint8(255*(change-Mich)/(Mach-Mich))); drawnow; title(sprintf('range is [%g %g]',max(vector(change)),min(vector(change)))); axis image off;
    
    % compute all statistics on current image
    [tmpparams] = texColorAnlzMask6(im,params,m,rMask);
    
    % compare all statistics to desired ones
    for iw = 1:m.scale{1}.nMasks
      statg0tmp = vector(tmpparams.synthesis.pixelStats(:,iw,:));
      params.snr.pixelStats(niter,iw) = snr(vector(statg0),vector(statg0)-statg0tmp);
    end
    
    for iw = 1:m.scale{1}.nMasks
      statgPtmp = vector(tmpparams.synthesis.pixelStatsPCA(:,iw,:));
      params.snr.pixelStatsPCA(niter,iw) = snr(vector(statgP),vector(statgP)-statgPtmp);
    end
    
    
    for nsc=Nsc+2:-1:1
      
      if nsc == Nsc+2
        nscsz = Nsc+1;
      else
        nscsz = nsc;
      end
      for iw = 1:m.scale{nscsz}.nMasks
        for clr=1:Nclr
          tmpSignal = tmpparams.synthesis.autoCorrReal.scale{nsc}.clr{clr}.mask{iw};
          signal = acr0.scale{nsc}.clr{clr}.mask{iw};
          params.snr.autoCorrReal(niter,iw,nsc,clr) = snr(signal,signal - tmpSignal);
        end
      end
      
    end
    
    for nsc=Nsc:-1:1
      for nor=1:Nor
        for iw=1:m.scale{nsc}.nMasks
          for clr=1:Nclr
            tmpSignal = tmpparams.synthesis.autoCorrMag.scale{nsc}.ori{nor}.clr{clr}.mask{iw};
            signal = ace0.scale{nsc}.ori{nor}.clr{clr}.mask{iw};
            params.snr.autoCorrMag(niter,iw,nsc,nor) = snr(signal,signal - tmpSignal);
          end
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
    
    
    for nsc=Nsc+1:-1:1
      for iw=1:m.scale{nsc}.nMasks
        tmpSignal = tmpparams.synthesis.cousinRealCorr.scale{nsc}.mask{iw};
        signal = Cr0.scale{nsc}.mask{iw};
        params.snr.cousinRealCorr(niter,iw,nsc) = snr(signal,signal - tmpSignal);
      end
    end
    
    
    for nsc=Nsc:-1:1
      for iw=1:m.scale{nsc}.nMasks
        for clr = 1:Nclr
          tmpSignal = tmpparams.synthesis.parentRealCorr.scale{nsc}.clr{clr}.mask{iw};
          signal = Crx0.scale{nsc}.clr{clr}.mask{iw};
          params.snr.parentRealCorr(niter,iw,nsc,clr) = snr(signal,signal - tmpSignal);
        end
      end
    end
    
    for iband=1:size(oimpind,1);
      for clr=1:Nclr
        for iw=1:size(tmpparams.synthesis.magMeans.clr{clr}.band{iband},1)
          tmpSignal = tmpparams.synthesis.magMeans.clr{clr}.band{iband}(iw);
          signal = magMeans0.clr{clr}.band{iband}(iw);
          params.snr.magMeans(niter,nband,iw,clr) = snr(signal,signal - tmpSignal);
        end
      end
    end
    
    
    sz = size(params.snr.autoCorrReal);
    params.snr.autoCorrRealPlot = reshape(params.snr.autoCorrReal,niter,sz(2)*sz(3)*sz(4));
    sz = size(params.snr.autoCorrMag);
    params.snr.autoCorrMagPlot = reshape(params.snr.autoCorrMag,niter,sz(2)*sz(3)*sz(4));
    sz = size(params.snr.magMeans);
    if numel(sz) < 3
      sz(3) = 1;
    end
    params.snr.magMeansPlot = reshape(params.snr.magMeans,niter,sz(2)*sz(3)*sz(4));
    sz = size(params.snr.cousinMagCorr);
    params.snr.cousinMagCorrPlot = reshape(params.snr.cousinMagCorr,niter,sz(2)*sz(3));
    sz = size(params.snr.parentMagCorr);
    params.snr.parentMagCorrPlot = reshape(params.snr.parentMagCorr,niter,sz(2)*sz(3));
    sz = size(params.snr.parentRealCorr);
    params.snr.parentRealCorrPlot = reshape(params.snr.parentRealCorr,niter,sz(2)*sz(3)*sz(4));
    sz = size(params.snr.cousinRealCorr);
    params.snr.cousinRealCorrPlot = reshape(params.snr.cousinRealCorr,niter,sz(2)*sz(3));
    
    
    axes(ax(3)); plot(params.snr.pixelStats); title('pixel mean');
    axes(ax(4)); plot(params.snr.magMeansPlot); title('magnitude means');
    axes(ax(5)); plot(params.snr.autoCorrRealPlot); title('autocorr real');
    axes(ax(6)); plot(params.snr.autoCorrMagPlot); title('autocorr mag');
    axes(ax(7)); plot(params.snr.cousinMagCorrPlot); title('cousin mag corr');
    axes(ax(8)); plot(params.snr.parentMagCorrPlot); title('parent mag corr');
    axes(ax(9)); plot(params.snr.cousinRealCorrPlot); title('cousin real corr');
    axes(ax(10)); plot(params.snr.parentRealCorrPlot); title('parent real corr');
    drawnow;
    
  end
  
end


