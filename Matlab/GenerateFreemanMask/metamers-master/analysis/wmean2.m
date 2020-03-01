function res = wmean2(mtx,w)

%
%-----------------------------------------
% res = wmean2(mtx,w)
%
% weighted mean
%
% mtx: matrix
% w: weighting function
%
% res: weighted mean
%
% freeman, 3/1/2009
%-----------------------------------------

w = w/sum(w(:));
wmtx = mtx.*w;
res = sum(wmtx(:));
