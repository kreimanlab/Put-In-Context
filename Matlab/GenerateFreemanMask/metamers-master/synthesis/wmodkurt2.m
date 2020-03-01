function [chm skip] = wmodkurt2(ch,kt,W,Wsum,Niter,ep,nsc)

%-----------------------------------------
% chm = wmodkurt2(ch,kt,W,Wsum,Niter,ep,nsc)
%
% modify the weighted kurtosis of an image matrix by taking
% gradient steps (see wkurt2.m)
%
% ch: image
% kt: target kurtosis
% W: weighting functions
% Wsum: sums of weighting functions
% Niter: number of gradient steps
% ep: learning rate
% nsc: number of scales
%
% chm: modified image
%
% freeman, 6/14/2009
%-----------------------------------------

chm = ch;
for niter=1:Niter
    
    mat = bsxfun(@minus,repmat(chm,1,size(W,2)),(W'*chm)');
    m1 = W.*mat;
    m2 = m1.*mat;
    m3 = m2.*mat; 
    vars = sum(m2);
    m4 = m3.*mat;
    mu4 = sum(m4);
    kttmp = mu4 ./ (vars.^2);
    kttmp = clip(kttmp,0,3);
    grad = m3 - bsxfun(@times,m1,mu4./vars);
    diff = kt - kttmp;
    diff(abs(diff)>1) = 0;
    lambda = (diff.*Wsum)*ep*(1/(10^(nsc+3)));
    chg = grad*lambda';
    chm = chm + chg;
end

if var2(chm)/var2(ch) > 1.1
    chm = ch;
    skip = 1;
    %fprintf('\r skipping kurtosis adjustment \r');
else
    skip = 0;
end