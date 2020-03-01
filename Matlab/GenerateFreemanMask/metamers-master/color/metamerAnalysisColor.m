function params = metamerAnalysisColor(oim,m,opts)

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

% get size of image
[Ny,Nx,Nclr] = size(oim);
oim = double(oim);

% build complex steerable pyramid in the fourier domain
[pyr0,pind0] = buildSCFpyr(oim(:,:,1),Nsc,Nor-1);

% check to make sure all bands are even
if (any(vector(mod(pind0,2))))
  error('(metamerAnalysisColor) algorithm will fail, some bands have odd dimensions');
end

clear pyr0
clear pind0

% apply PCA to RGB vals
imPCA = reshape(oim,Ny*Nx,Nclr);
tmpmean = mean(imPCA)';
imPCA = imPCA - ones(Ny*Nx,Nclr)*diag(tmpmean);
Cclr0 = innerProd(imPCA)/(Ny*Nx);
[V,D] = eig(Cclr0);
imPCA = imPCA*V*pinv(sqrt(D));
imPCA = reshape(imPCA,Ny,Nx,Nclr);

% pixel statistics
if opts.verbose; fprintf('(metamerAnalysisColor) pixel statistics\n'); end
statg0 = zeros(6,m.scale{1}.nMasks,Nclr);
for imask=1:m.scale{1}.nMasks
    thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
    thisMaskNAN = thisMask;
    thisMaskNAN(thisMaskNAN==0) = NaN;
    thisMaskNAN(thisMaskNAN>0) = 1;
    for iclr=1:Nclr
        [mn0 mx0] = range2(oim(:,:,iclr).*thisMaskNAN);
        mean0 = wmean2(oim(:,:,iclr),thisMask);
        var0 = wvar2(oim(:,:,iclr),thisMask);
        skew0 = wskew2(oim(:,:,iclr),thisMask);
        kurt0 = wkurt2(oim(:,:,iclr),thisMask);
        statg0(:,imask,iclr) = [mean0 var0 skew0 kurt0 mn0 mx0];
    end
end

% PCA pixel statistics
statgP = zeros(6,m.scale{1}.nMasks,Nclr);
for imask=1:m.scale{1}.nMasks
    thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
    thisMaskNAN = thisMask;
    thisMaskNAN(thisMaskNAN==0) = NaN;
    thisMaskNAN(thisMaskNAN>0) = 1;
    for iclr=1:Nclr
        [mn0 mx0] = range2(imPCA(:,:,iclr).*thisMaskNAN);
        mean0 = wmean2(imPCA(:,:,iclr),thisMask);
        var0 = wvar2(imPCA(:,:,iclr),thisMask);
        skew0 = wskew2(imPCA(:,:,iclr),thisMask);
        kurt0 = wkurt2(imPCA(:,:,iclr),thisMask);
        statgP(:,imask,iclr) = [mean0 var0 skew0 kurt0 mn0 mx0];
    end
end

% central autoCorr of the PCA bands
if opts.verbose; fprintf('(metamerAnalysisColor) autocorrelation\n'); end

for imask=1:m.scale{1}.nMasks
    for iclr=1:Nclr
        % compute autocorrelation on subband with 0s
        thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
        thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
        thisInd = m.scale{1}.ind(imask,:);
        thisNa = m.scale{1}.Na(imask);
        ac = wacorr2(imPCA(:,:,iclr),thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
        acr.scale{Nsc+2}.clr{iclr}.mask{imask} = ac;
    end
end

% build pyramid
for iclr = 1:Nclr
    [pyr0(:,iclr),pind0] = buildSCFpyr(imPCA(:,:,iclr),Nsc,Nor-1);
end

% Compute real parts and magnitudes of subbands
rpyr0 = real(pyr0);
apyr0 = abs(pyr0);

for iclr=1:Nclr
    for nband = 1:size(pind0,1)
        indices = pyrBandIndices(pind0,nband);
        tempMagMean = mean2(apyr0(indices,iclr));
        thisScale = m.bandToMaskScale(nband);
        magMeans0.clr{iclr}.band{nband} = m.scale{thisScale}.maskNorm'*apyr0(indices,iclr);
        apyr0(indices,iclr) = apyr0(indices,iclr) - tempMagMean;
    end
end

% Compute central autoCorr of lowband

for iclr=1:Nclr
    
    % do some stuff up front before looping through masks
    nband = size(pind0,1);
    ch = pyrBand(real(pyr0(:,iclr)),pind0,nband);
    [mpyr,mpind] = buildSFpyr(real(ch),0,0);
    [N1y N1x] = size(ch);
    im(1:N1y,1:N1x,iclr) = pyrBand(mpyr,mpind,2);
    
    for imask=1:m.scale{Nsc+1}.nMasks
        % compute autocorrelation on subband with 0s
        thisMask = squeeze(m.scale{m.bandToMaskScale(nband)}.maskMat(imask,:,:));
        thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
        thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
        thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
        ac = wacorr2(im(1:N1y,1:N1x,iclr),thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
        acr.scale{Nsc+1}.clr{iclr}.mask{imask} = ac;
        vari = ac(ceil(size(ac,1)/2),ceil(size(ac,1)/2));
        
        if vari/var0 > 1e-6, % don't understand this check!
            skew0p.scale{Nsc+1}.clr{iclr}(imask) = wskew2(im(1:N1y,1:N1x,iclr),thisMask);
            kurt0p.scale{Nsc+1}.clr{iclr}(imask) = wkurt2(im(1:N1y,1:N1x,iclr),thisMask);
        else
            skew0p.scale{Nsc+1}.clr{iclr}(imask) = 0;
            kurt0p.scale{Nsc+1}.clr{iclr}(imask) = 3;
        end
        
    end
end


% compute central autoCorr of each Mag band, and the autoCorr of the combined (non-oriented) band.
for iclr=1:Nclr
    for nsc = Nsc:-1:1,
        for nor = 1:Nor,
            nband = (nsc-1)*Nor+nor+1;
            ch = pyrBand(apyr0(:,iclr),pind0,nband);
            [N1y, N1x] = size(ch);
            
            for imask=1:m.scale{nsc}.nMasks
                thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
                thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
                thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
                thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
                ac = wacorr2(ch,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
                ace.scale{nsc}.ori{nor}.clr{iclr}.mask{imask} = ac;
            end
        end

        %% Combine ori bands
        
        bandNums = [1:Nor] + (nsc-1)*Nor+1;  %ori bands only
        ind1 = pyrBandIndices(pind0, bandNums(1));
        indN = pyrBandIndices(pind0, bandNums(Nor));
        bandInds = [ind1(1):indN(length(indN))];
        % Make fake pyramid, containing dummy hi, ori, lo
        fakePind = [pind0(bandNums(1),:);pind0(bandNums(1):bandNums(Nor)+1,:)];
        fakePyr = [zeros(prod(fakePind(1,:)),1);...
            rpyr0(bandInds,iclr); zeros(prod(fakePind(size(fakePind,1),:)),1);];
        ch = reconSFpyr(fakePyr, fakePind, [1]);     % recon ori bands only
        im(1:N1y,1:N1x,iclr) = real(expand(im(1:N1y/2,1:N1x/2,iclr),2))/4;
        im(1:N1y,1:N1x,iclr) = im(1:N1y,1:N1x,iclr) + ch;
        for imask=1:m.scale{nsc}.nMasks
            thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
            thisInd = m.scale{m.bandToMaskScale(nband)}.ind(imask,:);
            thisNa = m.scale{m.bandToMaskScale(nband)}.Na(imask);
            thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
            ac = wacorr2(im(1:N1y,1:N1x,iclr),thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
            acr.scale{nsc}.clr{iclr}.mask{imask} = ac;
            vari = ac(ceil(size(ac,1)/2),ceil(size(ac,1)/2));
            if vari/var0 > 1e-6, % don't understand this check!
                skew0p.scale{nsc}.clr{iclr}(imask) = wskew2(im(1:N1y,1:N1x,iclr),thisMask);
                kurt0p.scale{nsc}.clr{iclr}(imask) = wkurt2(im(1:N1y,1:N1x,iclr),thisMask);
            else
                skew0p.scale{nsc}.clr{iclr}(imask) = 0;
                kurt0p.scale{nsc}.clr{iclr}(imask) = 3;
            end
        end
    end
end

if opts.verbose; fprintf('(metamerAnalysisColor) cross correlations\n'); end

%% Compute the cross-correlation matrices of the coefficient magnitudes
%% pyramid at the different levels and orientations

% preallocate matrices for all masks

for nsc=1:Nsc
    for imask=1:m.scale{nsc}.nMasks
        Crx0.scale{nsc}.mask{imask} = zeros(Nclr*Nor,2*Nor*Nclr);
        C0.scale{nsc}.mask{imask} = zeros(Nor*Nclr,Nor*Nclr);
    end    
end

for nsc=1:Nsc-1    
    for imask=1:m.scale{nsc}.nMasks
        Cx0.scale{nsc}.mask{imask} = zeros(Nor*Nclr,Nor*Nclr);
    end    
end

for nsc=1:Nsc+1    
    for imask=1:m.scale{nsc}.nMasks
        Cr0.scale{nsc}.mask{imask} = zeros(2*Nor*Nclr,2*Nor*Nclr);
    end   
end

for nsc = 1:Nsc,
    firstBnum = (nsc-1)*Nor+2;
    cousinSz = prod(pind0(firstBnum,:));
    ind = pyrBandIndices(pind0,firstBnum);
    cousinInd = ind(1) + [0:Nor*cousinSz-1];
    
    cousins = zeros(cousinSz,Nor,Nclr);
    rcousins = zeros(cousinSz,Nor,Nclr);
    parents = zeros(cousinSz,Nor,Nclr);
    rparents = zeros(cousinSz,2*Nor,Nclr);
    
    for iclr=1:Nclr
        
        if (nsc<Nsc)
            
            for nor=1:Nor,
                nband = (nsc-1+1)*Nor+nor+1;
                
                tmp = expand(pyrBand(pyr0(:,iclr), pind0, nband),2)/4;
                rtmp = real(tmp); itmp = imag(tmp);
                %% Double phase:
                tmp = sqrt(rtmp.^2 + itmp.^2) .* exp(2 * sqrt(-1) * atan2(rtmp,itmp));
                rparents(:,nor,iclr) = vector(real(tmp));
                rparents(:,Nor+nor,iclr) = vector(imag(tmp));
                
                tmp = abs(tmp);
                parents(:,nor,iclr) = vector(tmp - mean2(tmp));
            end
        else
            tmp = real(expand(pyrLow(rpyr0(:,iclr),pind0),2))/4;
            rparents(:,1:5,iclr) = [vector(tmp),...
                vector(shift(tmp,[0 2])), vector(shift(tmp,[0 -2])), ...
                vector(shift(tmp,[2 0])), vector(shift(tmp,[-2 0]))];
            parents = [];
        end
        
        cousins(:,:,iclr) = reshape(apyr0(cousinInd,iclr), [cousinSz Nor]);
        rcousins(:,:,iclr) = reshape(real(pyr0(cousinInd,iclr)), [cousinSz Nor]);
        
    end
    
    nc = size(cousins,2)*Nclr;   np = size(parents,2)*Nclr;
    cousins = reshape(cousins,[cousinSz nc]);
    parents = reshape(parents,[cousinSz np]);
    
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
        C0.scale{nsc}.mask{imask} = innerProd(cousinstmp)/cousinSz;
        if (np > 0)
            Cx0.scale{nsc}.mask{imask} = (cousinstmp'*parentstmp)/cousinSz;
        end   
    end
    
    if nsc == Nsc
        rparents = rparents(:,1:5,:);
    end
    
    nrp = size(rparents,2);
    nrc = size(rcousins,2);
    
    for iclr=1:Nclr
        rcousinsClr = squeeze(rcousins(:,:,iclr));
        rparentsClr = squeeze(rparents(:,:,iclr));
        for imask = 1:m.scale{nsc}.nMasks;
            clear rcousinstmp
            clear rparentstmp
            thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
            for inrc=1:nrc
                rcousinstmp(:,inrc) = (rcousinsClr(:,inrc) - wmean2(rcousinsClr(:,inrc),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
            end
            for inrp=1:nrp
                rparentstmp(:,inrp) = (rparentsClr(:,inrp) - wmean2(rparentsClr(:,inrp),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
            end
            Crx0.scale{nsc}.clr{iclr}.mask{imask}(1:nrc,1:nrp) = (rcousinstmp'*rparentstmp)/cousinSz;
            Cr0.scale{nsc}.clr{iclr}.mask{imask}(1:nrc,1:nrc) = innerProd(rcousinstmp)/cousinSz;
        end
        clear rcousinsClr
        clear rparentsClr
    end
    
    nrp = size(rparents,2)*Nclr;
    nrc = size(rcousins,2)*Nclr;
    
    rcousins = reshape(rcousins,[cousinSz nrc]);
    rparents = reshape(rparents,[cousinSz nrp]);
    
    for imask = 1:m.scale{nsc}.nMasks;
        clear rcousinstmp
        clear rparentstmp
        thisMask = squeeze(m.scale{nsc}.maskMat(imask,:,:));
        for inrc=1:nrc
            rcousinstmp(:,inrc) = (rcousins(:,inrc) - wmean2(rcousins(:,inrc),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
        end
        for inrp=1:nrp
            rparentstmp(:,inrp) = (rparents(:,inrp) - wmean2(rparents(:,inrp),vector(thisMask))).*sqrt(vector(thisMask)/sum(thisMask(:)));
        end
        Cr0.scale{nsc}.mask{imask}(1:nrc,1:nrc) = innerProd(rcousinstmp)/cousinSz;
        if (nrp > 0)
            Crx0.scale{nsc}.mask{imask}(1:nrc,1:nrp) = (rcousinstmp'*rparentstmp)/cousinSz;
            if (nsc==Nsc)
                Cr0.scale{Nsc+1}.mask{imask}(1:nrp,1:nrp) = innerProd(rparentstmp)/cousinSz;
            end
        end
    end
end


% Calculate the mean, range and variance of the LF and HF residuals' energy.
vHPR0 = zeros(Nclr,m.scale{1}.nMasks);
for iclr=1:Nclr
    
    channel = pyr0(pyrBandIndices(pind0,1),iclr);
    channel = reshape(channel,Ny,Nx);
    
    for imask=1:m.scale{1}.nMasks
        thisMask = squeeze(m.scale{1}.maskMat(imask,:,:));
        thisInd = m.scale{1}.ind(imask,:);
        thisNa = m.scale{1}.Na(imask);
        thisMaskSqrt = sqrt(thisMask/sum(thisMask(:)));
        ac = wacorr2(channel,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,0);
        acr.vHPR.clr{iclr}.mask{imask} = ac;
    end
    
    channel = vector(channel);
    
    for imask=1:m.scale{1}.nMasks
        thisMask = m.scale{1}.maskMat(imask,:,:);
        vHPR0(iclr,imask) = wvar2(channel,thisMask(:));
    end
    vHPR0full = var2(channel);
    
    
end

params = struct('pixelStats', statg0, ...
                'pixelStatsPCA', statgP, ...
                'LPskew', skew0p, ...
                'LPkurt',kurt0p,...
                'autoCorrReal', acr, ...
                'autoCorrMag', ace, ...
		'magMeans', magMeans0, ...
                'cousinMagCorr', C0, ...
                'parentMagCorr', Cx0, ...
 		'cousinRealCorr', Cr0, ...
 		'parentRealCorr', Crx0, ...
		'varianceHPR', vHPR0,...
        'varianceHPRfull',vHPR0full,...
        'colorCorr', Cclr0);

params.oim = oim;