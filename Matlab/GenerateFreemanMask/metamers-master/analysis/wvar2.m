function res = wvar2(mtx,w)

%
%-----------------------------------------
% res = wvar2(mtx,w)
%
% weighted variance
%
% mtx: matrix
% w: weighting function
%
% res: weighted mean
%
% freeman, 1/25/2009
%-----------------------------------------

mn =  wmean2(mtx,w);

if (isreal(mtx))
    w = w/sum(w(:));
    tmp = w.*abs(mtx-mn).^2;
    res = sum(tmp(:));   
else
    error('(nanvar2) mtx is not real')
end
 