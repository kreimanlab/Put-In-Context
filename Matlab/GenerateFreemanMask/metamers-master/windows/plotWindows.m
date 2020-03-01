function im = plotWindows(m,opts,vals)

%
%-----------------------------------------
% im = plotWindows(m,opts,vals)
%
% plots window functions as an image,
% can scale grayscale values of each region
% 
% m: structure contining window functions
% opts: structure with options (see metamerOpts.m)
% vals: vector of weights (optional)
% 
% im: image of windows
%
% freeman, 3/7/2013
%-----------------------------------------

nMasks = size(m.scale{1}.maskMat,1);
if ieNotDefined('vals'); vals = ones(nMasks,1); end
vals = vals(:)/max(vals(:));
clrs = bsxfun(@times,ones(nMasks,3),vals);

im = zeros(opts.szy,opts.szx,3);
for imask = 1:nMasks
	tmp = squeeze(m.scale{1}.maskMat(imask,:,:));
	tmp2 = zeros(size(tmp));
	tmp2(tmp>0.75) = 1;
	r = tmp2*clrs(imask,1);
	g = tmp2*clrs(imask,2);
	b = tmp2*clrs(imask,3);
	im(:,:,1) = im(:,:,1) + r;
	im(:,:,2) = im(:,:,2) + g;
	im(:,:,3) = im(:,:,3) + b;
end
im = clip(im,0,1);

set(gcf,'Position',[0 0 650 650]);
image(im);
axis image off
