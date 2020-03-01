function chm = wmodacorr2(ch,targetAcorr,W,Wsqrt,epw,Niter,Na,Wind,Wsz,Wvec)

%
%-----------------------------------------
% chm = wmodacorr2(ch,targetAcorr,W,Wsqrt,epw,Niter,Na,Wind,Wsz,Wvec)
%
% modify the weighted autocorrelation of an image matrix by taking
% gradient steps (see wacorr2.m)
%
% ch: image
% targetAcorr: target autocorrelation
% W: weighting functions
% Wsum: sums of weighting functions
% epw: learning rate
% Niter: number of gradient steps
% Na: neighborhood
% Wind: wighting function indices
% Wsz: weighting function size
% Wvec: weighting function vectorized
%
% chm: modified image
%
% freeman, 6/24/2009
%-----------------------------------------

tmpmean = Wvec'*ch;
och = reshape(ch,size(Wsqrt,1),size(Wsqrt,2));
chm = och;

for iw=1:size(W,3);

	tmpim = och - tmpmean(iw); 

	tmpacorr2 = wacorr2(tmpim,W(:,:,iw),Wsqrt(:,:,iw),Wind(:,iw),Na(iw),Na(iw),1);
	tmptarget = targetAcorr{iw};    

	diff = tmptarget - tmpacorr2;

	dir = diff/max(abs(diff(:)));

	scale = sum(abs(diff(:)))/sum(abs(tmptarget(:)));

	if scale > 1
		scale = 1;
	end

	tmpConv1 = cconv2(Wsqrt(:,:,iw).*tmpim,dir);
	tmpConv2 = ifft2(fft2(Wsqrt(:,:,iw).*tmpim,size(tmpim,1),size(tmpim,2)).*fft2(dir,size(tmpim,1),size(tmpim,2)));
	tmpConv2 = circshift(tmpConv2,[-floor(size(dir,1)/2) -floor(size(dir,2)/2)]);

	chm = chm + Wsqrt(:,:,iw).*tmpConv2 * epw * (Wsz(iw))/(8^2) * scale;

end

chm = vector(chm);

