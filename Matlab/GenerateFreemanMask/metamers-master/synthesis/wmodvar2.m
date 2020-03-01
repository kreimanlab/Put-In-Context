function chm = wmodvar2(ch,v,W,Wsum,Niter,ep)

%-----------------------------------------
% chm = wmodvar2(ch,kt,W,Wsum,Niter,ep,nsc)
%
% modify the weighted variance of an image matrix by taking
% gradient steps (see wvar2.m)
%
% ch: image
% v: target variance
% W: weighting functions
% Wsum: sums of weighting functions
% Niter: number of gradient steps
% ep: learning rate
%
% chm: modified image
%
% freeman, 4/22/2009
%-----------------------------------------

chm = ch;
for niter=1:Niter
    
    mat = bsxfun(@minus,repmat(chm,1,size(W,2)),(W'*chm)');
    grad = W.*mat;
    vars = sum(grad.*mat);
    diff = v - vars;
    
    lambda = diff.*(Wsum/numel(ch))*ep;
    chm = chm + grad*lambda';

end
