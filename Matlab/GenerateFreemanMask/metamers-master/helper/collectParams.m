function [out inds] = collectParams(params,opts)

%
%-----------------------------------------
% [out inds] = collectParams(params,opts)
%
% collects parameters from a local statistical
% image model into a matrix and provides
% indices for accessing parameter groups
%
% params: structure with model parameters
% opts: structure containing options
%
% out: matrix of parameters
% inds: structure of parameter indices
%
% freeman, created 1/1/2009
% freeman, released 3/8/13
%-----------------------------------------

s = params;
nMasks = size(s.pixelStats,2);
Nsc = opts.Nsc;
Nor = opts.Nor;
Na = opts.maxNa;

% PROBLEM with some sizes where last mask does not have a full covariance
for iN = 1:numel(s.autoCorrRealFull.scale{Nsc}.mask)
   maskSize(iN) = numel(s.autoCorrRealFull.scale{Nsc}.mask{iN});
end
maskInds = find(maskSize==Na^2);


indStart = 0;

% collect pixel stats
out = s.pixelStats(1:4,maskInds);
for i=1:Nsc
    out = [out; s.LPskew.scale{i}(maskInds)];
end
for i=1:Nsc
    out = [out; s.LPkurt.scale{i}(maskInds)];
end

indEnd = indStart+size(out,1);
inds.pixelStats = indStart+1:indEnd;
indStart = indEnd;

% collect magnitude means
for i=1:Nsc*Nor+2
    out = [out; vector(s.magMeans.band{i}(maskInds))'];
end
indEnd = indStart+size(out,1)-indEnd;
inds.magMeans = indStart+1:indEnd;
indStart = indEnd;

% collect real autocorrelation
for i=1:Nsc
    tmp = [];
    for j=maskInds
        tmp = [tmp vector(s.autoCorrRealFull.scale{i}.mask{j})];
    end
    out = [out; tmp];
end
indEnd = indStart+size(out,1)-indEnd;
inds.autoCorrReal = indStart+1:indEnd;
indStart = indEnd;

% collect magnitude autocorrelations
for i=1:Nsc
    for k=1:Nor
        tmp = [];
        for j=maskInds
            tmp = [tmp vector(s.autoCorrMagFull.scale{i}.ori{k}.mask{j})];
        end
        out = [out; tmp];
    end
end
indEnd = indStart+size(out,1)-indEnd;
inds.autoCorrMag = indStart+1:indEnd;
indStart = indEnd;

% collect cousin magnitude correlations
for i=1:Nsc
    tmp = [];
    for j=maskInds
        tmp = [tmp vector(s.cousinMagCorr.scale{i}.mask{j})];
    end
    out = [out; tmp];
end
indEnd = indStart+size(out,1)-indEnd;
inds.cousinMagCorr = indStart+1:indEnd;
indStart = indEnd;

% collect parent real correlations
for i=1:Nsc-1
    tmp = [];
    for j=maskInds
        tmp = [tmp vector(s.parentRealCorr.scale{i}.mask{j}(1:Nor,:))];
    end
    out = [out; tmp];
end
% out = out(sum(out,2)~=0,:);
indEnd = indStart+size(out,1)-indEnd;
inds.parentRealCorr = indStart+1:indEnd;
indStart = indEnd;

% collect parent magnitude correlations
for i=1:Nsc-1
    tmp = [];
    for j=maskInds
        tmp = [tmp vector(s.parentMagCorr.scale{i}.mask{j})];
    end
    out = [out; tmp];
end
indEnd = indStart+size(out,1)-indEnd;
inds.parentMagCorr = indStart+1:indEnd;
indStart = indEnd;

