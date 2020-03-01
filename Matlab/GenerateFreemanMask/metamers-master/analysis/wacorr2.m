function [acSub acFull] = wacorr2(im,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,meanSubtracted)

%
%-----------------------------------------
% [acSub acFull] = wacorr2(im,thisMask,thisMaskSqrt,thisInd,thisNa,maxNa,meanSubtracted)
%
% compute a weighted 2D autocorrelation
%
% im: image
% thisMask: weighting function
% thisMaskSqrt: square root of weighting function
% thisInd: indices into relavant region of image
% thisNa: neighboorhood (for this window)
% maxNa: max neighboorhood
% meanSubtracted: subtract the mean?
% 
% acSub: autocorrelation restricted by neighborhood
% acFull: full autocorrelation
%
% freeman, 6/24/2009
%-----------------------------------------


if exist('thisInd','var')
    im = im(thisInd(1):thisInd(2),thisInd(3):thisInd(4));
    thisMask = thisMask(thisInd(1):thisInd(2),thisInd(3):thisInd(4));
    thisMaskSqrt = thisMaskSqrt(thisInd(1):thisInd(2),thisInd(3):thisInd(4));
end

[Nly Nlx] = size(im);
cy = Nly/2+1;
cx = Nlx/2+1;
le = floor((thisNa-1)/2);
leFull = floor((maxNa-1)/2);

if meanSubtracted
    ac = fftshift(real(ifft2(abs(fft2((im).*thisMaskSqrt)).^2)));
else
    ac = fftshift(real(ifft2(abs(fft2((im-wmean2(im,thisMask)).*thisMaskSqrt)).^2)));
end

acSub = ac(cy-le:cy+le,cx-le:cx+le);
try
	acFull = ac(cy-leFull:cy+leFull,cx-leFull:cx+leFull);
catch
	acFull = acSub;
end


