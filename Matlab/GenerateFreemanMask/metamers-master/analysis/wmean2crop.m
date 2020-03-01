function res = wmean2crop(mtx,w,wind)

%
%-----------------------------------------
% res = wmean2crop(mtx,w,wind)
%
% weighted mean within a cropped region
%
% mtx: matrix
% w: weighting function
% wind: indices for cropping
%
% res: weighted mean
%
% freeman, 3/1/2009
%-----------------------------------------

mtx = mtx(wind(1):wind(2),wind(3):wind(4));
w = w(wind(1):wind(2),wind(3):wind(4));

wmtx = mtx.*w;
res = sum(wmtx(:));
