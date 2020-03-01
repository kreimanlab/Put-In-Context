function res = wskew2(mtx,w)

%
%-----------------------------------------
% res = wskew2(mtx,w)
%
% weighted sample skew (third moment / variance^(3/2))
%
% mtx: matrix
% w: weighting function
%
% res: weighted skew
%
% freeman, 4/9/2009
%-----------------------------------------

mn =  wmean2(mtx,w);
v =  wvar2(mtx,w);

if (isreal(mtx))
    w = w/sum(w(:));
    if v == 0
        res = 0;
    else
        tmp = w.*(mtx-mn).^3 / (v^(3/2));
         res = sum(tmp(:));
    end
else
    error('(wskew2) mtx is not real')
end
