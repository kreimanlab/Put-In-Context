function chm = wmodmean2(ch,m,W,preCalcInv)

%-----------------------------------------
% chm = wmodmean2(ch,m,W,preCalcInv)
%
% modify the weighted mean of an image matrix 
% with a single update (see wmean2.m)
%
% ch: image
% m: target mean
% W: weighting functions
% preCalcInv: inverse matrix, precalculated for speed
%
% chm: modified image
%
% freeman, 2/16/2009
%-----------------------------------------

lambda = preCalcInv*(m'-W'*ch);
chm = ch + W*lambda;