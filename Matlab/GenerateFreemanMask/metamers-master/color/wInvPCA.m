function imout = wInvPCA(im0,w,Cclr0,means);

[Nx,Ny,Nclr] = size(im0);

im = reshape(im0,Ny*Nx,Nclr);

wFull = w;
w = w/sum(w);
sqw = sqrt(w);
undow = zeros(size(w));
undow(sqw>0.0001) = 1./sqw(sqw>0.0001);

for icol = 1:Nclr
    tmpmean = wmean2(im(:,icol),w);
    tmpim(:,icol) = (im(:,icol) - tmpmean).*sqw;
end

%tmpcorr = innerProd(tmpim)/(Nx*Ny);
%[Vtmp,Dtmp] = eig(tmpcorr);
%tmpim = tmpim*Vtmp*pinv(sqrt(Dtmp));

[V,D] = eig(Cclr0);

tmpim = tmpim*sqrt(D)*V';

for icol = 1:Nclr
    tmpim(:,icol) = tmpim(:,icol).*undow + means(icol);
    tmpim(:,icol) = tmpim(:,icol).*wFull;
end

imout = reshape(tmpim,Nx,Ny,Nclr);
