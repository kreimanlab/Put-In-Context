function [chm skip] = wmodskew2(ch,sk,W,Wsum,Niter,ep,nsc)

%-----------------------------------------
% chm = wmodskew2(ch,sk,W,Wsum,Niter,ep,nsc)
%
% modify the weighted skew of an image matrix by taking
% gradient steps (see wskew2.m)
%
% ch: image
% sk: target skewness
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
    sktmp = sum(m3) ./ vars.^(3/2);
    sktmp = clip(sktmp,-4,4);
    grad = m2 - bsxfun(@times,m1,(vars.^(1/2)).*sktmp);
    diff = sk - sktmp;
    diff(abs(diff)>1) = 0;
    lambda = (diff.*Wsum)*ep*(1/10^(nsc+3));
    chg = grad*lambda';
    chm = chm + chg;
end

if var2(chm)/var2(ch) > 1.1
    chm = ch;
    skip = 1;
    %fprintf('\r skipping skewness adjustment \r');
else
    skip = 0;
end