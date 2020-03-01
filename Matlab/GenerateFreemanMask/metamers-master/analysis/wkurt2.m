function res = wkurt2(mtx, w)

%
%-----------------------------------------
% res = wkurt2(mtx,w)
%
% weighted sample kurtosis (fourth moment / squared variance)
%
% mtx: matrix
% w: weighting function
%
% res: weighted kurtosis
%
% freeman, 3/14/2009
%-----------------------------------------

mn =  wmean2(mtx,w);
v =  wvar2(mtx,w);

if (isreal(mtx))
    w = w/sum(w(:));
    if v == 0
        res = 0;
    else
        tmp = w.*abs(mtx-mn).^4 / v^2;
        res = sum(tmp(:));
    end    
else
    error('(wkurt2) mtx is not real')
end
