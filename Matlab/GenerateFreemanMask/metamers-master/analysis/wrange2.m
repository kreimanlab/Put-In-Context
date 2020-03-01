function [mn, mx] = wrange2(mtx,w)

%
%-----------------------------------------
% [mn, mx] = wrange2(mtx,w)
%
% range of an image within a binarized
% weighting function
%
% mtx: matrix
% w: weighting function
%
% mn: minimum
% mx: maximum
%
% freeman, 1/24/2009
%-----------------------------------------

wNAN = w;
wNAN(wNAN==0) = NaN;
wNAN(wNAN>0) = 1;

mn = min(min(wNAN.*mtx));
mx = max(max(wNAN.*mtx));
