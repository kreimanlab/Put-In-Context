function [imout Cclr0 means] = wPCA(im0,w,Cclr0);

[Nx,Ny,Nclr] = size(im0);

im = reshape(im0,Nx*Ny,Nclr);

wFull = w;
w = w/sum(w);
sqw = sqrt(w);
undow = zeros(size(w));
undow(sqw>0.0001) = 1./sqw(sqw>0.0001);

for icol = 1:Nclr
    means(icol) = wmean2(im(:,icol),w);
    tmpim(:,icol) = (im(:,icol) - means(icol)).*sqw;
end

if ~exist('Cclr0','var')
Cclr0 = innerProd(tmpim)/(Ny*Nx);
end

[V,D] = eig(Cclr0);

tmpim = tmpim*V*pinv(sqrt(D));

for icol = 1:Nclr
    tmpim(:,icol) = tmpim(:,icol).*undow;
    tmpim(:,icol) = tmpim(:,icol).*wFull;
end

imout = reshape(tmpim,Nx,Ny,Nclr);


