function chm = wmodrange2(ch,rng,W)

%-----------------------------------------
% chm = wmodrange2(ch,rng,w)
%
% modify the weighted range of an image matrix
% (see wmodrange2.m)
%
% ch: image
% rng: target range
% W: weighting functions
% 
% chm: modified image
%
% freeman, 1/24/2009
%-----------------------------------------

wNAN = W;
wNAN(wNAN==0) = NaN;
wNAN(wNAN>0) = 1;

chm = ch;

chm((wNAN.*ch)<rng(1)) = rng(1);
chm((wNAN.*ch)>rng(2)) = rng(2);
